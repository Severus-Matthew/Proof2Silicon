"""Journal PPO update override.

The legacy trainer rejected every individual rollout sample whose absolute
sequence log-ratio exceeded 0.20.  That is overly aggressive for sequence-level
PPO and can discard a large fraction of expensive trajectories.  This override
keeps PPO clipping for every finite sample, measures an aggregate approximate KL
across a complete update pass, and only stops *future PPO passes* when the mean
KL for the completed pass exceeds the configured target.

This module intentionally does not change the separate base-policy drift signal
used by the reward/audit path.  `ppo/approx_kl` means current policy vs rollout
policy; `journal/base_policy_sampled_logratio` means current policy vs frozen base.
"""

import logging
import os

import torch


def install(slmmodule) -> None:
    """Replace ``slmmodule.ppo_update_sequence_level`` with the journal version."""

    target_kl = float(os.environ.get("PPO_TARGET_MEAN_KL", "0.15"))
    min_samples_before_kl_stop = int(os.environ.get("PPO_MIN_KL_SAMPLES", "8"))

    def ppo_update_sequence_level(
        slm_pg,
        optimizer,
        rollouts,
        clip_eps: float = 0.2,
        value_coef: float = 0.5,
        entropy_coef: float = 0.01,
        num_update_epochs: int = 4,
    ):
        slm_pg.train()
        device = slmmodule.device

        advantages = torch.tensor(
            [r.advantage for r in rollouts],
            dtype=torch.float32,
            device=device,
        )
        returns = torch.tensor(
            [r.return_ for r in rollouts],
            dtype=torch.float32,
            device=device,
        )
        old_logprobs = torch.stack([r.old_logprob for r in rollouts]).to(device)
        old_values = torch.stack([r.old_value for r in rollouts]).to(device)

        if len(advantages) > 1:
            advantages = (advantages - advantages.mean()) / (
                advantages.std(unbiased=False) + 1e-8
            )
        advantages = torch.clamp(advantages, -5.0, 5.0)

        stats = {
            "policy_loss": 0.0,
            "value_loss": 0.0,
            "entropy": 0.0,
            "total_loss": 0.0,
            "approx_kl": 0.0,
            "update_epochs_completed": 0.0,
            "optimizer_steps": 0.0,
            "kl_early_stopped": 0.0,
        }
        total_steps = 0
        all_kl_values = []

        for update_epoch in range(num_update_epochs):
            pass_kl_values = []
            pass_steps = 0

            for i, r in enumerate(rollouts):
                new_logprob, new_value, entropy = slmmodule.compute_sequence_logprob_and_value(
                    slm_pg,
                    r.prompt_ids.to(device),
                    r.generated_ids.to(device),
                )
                new_value = new_value.squeeze()

                if not (
                    torch.isfinite(new_logprob).all()
                    and torch.isfinite(new_value).all()
                    and torch.isfinite(entropy).all()
                ):
                    logging.warning(
                        "Skipping PPO sample because new_logprob/new_value/entropy is non-finite."
                    )
                    continue

                log_ratio = torch.clamp(
                    new_logprob - old_logprobs[i],
                    min=-20.0,
                    max=20.0,
                )
                if not torch.isfinite(log_ratio).all():
                    logging.warning("Skipping PPO sample because log_ratio is non-finite.")
                    continue

                ratio = torch.exp(log_ratio)

                # Schulman-style non-negative approximate KL estimator for the
                # sampled action/sequence: (r - 1) - log(r).  Because the SLM
                # sequence log-probability is a mean over generated tokens, this
                # remains on a token-averaged scale rather than growing with
                # output length.
                approx_kl = (ratio - 1.0) - log_ratio
                approx_kl_value = float(torch.clamp(approx_kl.detach(), min=0.0).item())
                pass_kl_values.append(approx_kl_value)
                all_kl_values.append(approx_kl_value)

                unclipped = ratio * advantages[i]
                clipped = torch.clamp(
                    ratio, 1.0 - clip_eps, 1.0 + clip_eps
                ) * advantages[i]
                policy_loss = -torch.min(unclipped, clipped)

                value_pred_clipped = old_values[i] + torch.clamp(
                    new_value - old_values[i],
                    -clip_eps,
                    clip_eps,
                )
                value_loss_unclipped = (new_value - returns[i]) ** 2
                value_loss_clipped = (value_pred_clipped - returns[i]) ** 2
                value_loss = 0.5 * torch.max(value_loss_unclipped, value_loss_clipped)

                total_loss = policy_loss + value_coef * value_loss - entropy_coef * entropy
                if not (
                    torch.isfinite(policy_loss).all()
                    and torch.isfinite(value_loss).all()
                    and torch.isfinite(total_loss).all()
                ):
                    logging.warning("Skipping PPO sample because loss is non-finite.")
                    continue

                optimizer.zero_grad(set_to_none=True)
                total_loss.backward()

                bad_grad = False
                for name, parameter in slm_pg.named_parameters():
                    if parameter.grad is not None and not torch.isfinite(parameter.grad).all():
                        logging.warning(
                            "Non-finite gradient detected in %s; skipping optimizer step.",
                            name,
                        )
                        bad_grad = True
                        break
                if bad_grad:
                    optimizer.zero_grad(set_to_none=True)
                    continue

                grad_norm = torch.nn.utils.clip_grad_norm_(slm_pg.parameters(), 0.5)
                grad_norm_value = float(grad_norm.item()) if torch.is_tensor(grad_norm) else float(grad_norm)
                if not torch.isfinite(torch.tensor(grad_norm_value)):
                    logging.warning("Gradient norm is non-finite; skipping optimizer step.")
                    optimizer.zero_grad(set_to_none=True)
                    continue

                optimizer.step()

                stats["policy_loss"] += float(policy_loss.item())
                stats["value_loss"] += float(value_loss.item())
                stats["entropy"] += float(entropy.item())
                stats["total_loss"] += float(total_loss.item())
                total_steps += 1
                pass_steps += 1

            if pass_steps > 0:
                stats["update_epochs_completed"] += 1.0

            pass_mean_kl = (
                sum(pass_kl_values) / len(pass_kl_values)
                if pass_kl_values
                else 0.0
            )
            logging.info(
                "PPO update pass %s/%s complete | optimizer_steps=%s | mean_approx_kl=%.6f | target=%.6f",
                update_epoch + 1,
                num_update_epochs,
                pass_steps,
                pass_mean_kl,
                target_kl,
            )

            # Crucially, no individual sample is discarded because its KL is
            # large.  We only stop additional passes after observing the mean KL
            # for a completed pass.
            if (
                target_kl > 0.0
                and len(pass_kl_values) >= min_samples_before_kl_stop
                and pass_mean_kl > target_kl
            ):
                stats["kl_early_stopped"] = 1.0
                logging.warning(
                    "Stopping remaining PPO update passes after pass %s because mean_approx_kl=%.6f exceeded target=%.6f. No rollout samples were discarded by KL.",
                    update_epoch + 1,
                    pass_mean_kl,
                    target_kl,
                )
                break

        if total_steps > 0:
            for key in ("policy_loss", "value_loss", "entropy", "total_loss"):
                stats[key] /= total_steps
        stats["approx_kl"] = (
            sum(all_kl_values) / len(all_kl_values)
            if all_kl_values
            else 0.0
        )
        stats["optimizer_steps"] = float(total_steps)

        return stats

    slmmodule.ppo_update_sequence_level = ppo_update_sequence_level
    logging.info(
        "Installed aggregate PPO-KL guard: target_mean_kl=%.4f, min_samples=%d; per-sample KL rejection disabled.",
        target_kl,
        min_samples_before_kl_stop,
    )
