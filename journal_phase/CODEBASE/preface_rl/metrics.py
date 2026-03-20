import json
import os
import time
from collections import defaultdict
from datetime import datetime
from typing import Any, DefaultDict, Dict, List, Optional


class MetricsTracker:
    def __init__(self, save_dir: str):
        self.save_dir = save_dir
        os.makedirs(self.save_dir, exist_ok=True)

        # Step-level metrics
        self.episode_rewards: List[float] = []
        self.cumulative_rewards: List[float] = []
        self.success_rates: List[float] = []
        self.error_counts: List[int] = []
        self.iteration_counts: List[int] = []

        # Epoch-level metrics
        self.average_rewards_per_epoch: List[float] = []
        self.policy_loss_per_epoch: List[float] = []
        self.value_loss_per_epoch: List[float] = []
        self.success_rate_per_epoch: List[float] = []

        # Training stats
        self.training_loss: List[float] = []
        self.validation_loss: List[float] = []
        self.model_perplexity: List[float] = []
        self.error_types: DefaultDict[str, List[int]] = defaultdict(list)
        self.verification_success_rate: List[float] = []
        self.proof_obligation_counts: List[int] = []

        self.start_time = time.time()
        self.epoch_times: List[float] = []

        # Step-level reward breakdown
        self.outcome_rewards: List[float] = []
        self.progress_rewards: List[float] = []
        self.structure_rewards: List[float] = []
        self.efficiency_rewards: List[float] = []
        self.stability_rewards: List[float] = []

        # Extra diagnostics
        self.prompt_token_increases: List[int] = []
        self.kl_values: List[float] = []

        # Epoch-level reward breakdown
        self.avg_outcome_rewards_per_epoch: List[float] = []
        self.avg_progress_rewards_per_epoch: List[float] = []
        self.avg_structure_rewards_per_epoch: List[float] = []
        self.avg_efficiency_rewards_per_epoch: List[float] = []
        self.avg_stability_rewards_per_epoch: List[float] = []

    def update_rl_metrics(
        self,
        reward: float,
        success: bool,
        error_count: int,
        iterations: int,
    ) -> None:
        self.episode_rewards.append(float(reward))
        cumulative = (
            self.cumulative_rewards[-1] + float(reward)
            if self.cumulative_rewards
            else float(reward)
        )
        self.cumulative_rewards.append(cumulative)
        self.success_rates.append(float(success))
        self.error_counts.append(int(error_count))
        self.iteration_counts.append(int(iterations))

    def update_reward_breakdown(
        self,
        reward_breakdown: Dict[str, float],
        prompt_token_increase: int = 0,
        kl_value: float = 0.0,
    ) -> None:
        self.outcome_rewards.append(float(reward_breakdown.get("outcome_reward", 0.0)))
        self.progress_rewards.append(float(reward_breakdown.get("progress_reward", 0.0)))
        self.structure_rewards.append(float(reward_breakdown.get("structure_reward", 0.0)))
        self.efficiency_rewards.append(float(reward_breakdown.get("efficiency_reward", 0.0)))
        self.stability_rewards.append(float(reward_breakdown.get("stability_reward", 0.0)))

        self.prompt_token_increases.append(int(prompt_token_increase))
        self.kl_values.append(float(kl_value))

    def update_epoch_metrics(
        self,
        avg_reward: float,
        training_loss: Optional[float] = None,
        val_loss: Optional[float] = None,
        avg_outcome_reward: Optional[float] = None,
        avg_progress_reward: Optional[float] = None,
        avg_structure_reward: Optional[float] = None,
        avg_efficiency_reward: Optional[float] = None,
        avg_stability_reward: Optional[float] = None,
        avg_policy_loss: Optional[float] = None,
        avg_value_loss: Optional[float] = None,
        epoch_success_rate: Optional[float] = None,
    ) -> None:
        self.average_rewards_per_epoch.append(float(avg_reward))

        if training_loss is not None:
            self.training_loss.append(float(training_loss))
        if val_loss is not None:
            self.validation_loss.append(float(val_loss))

        if avg_policy_loss is not None:
            self.policy_loss_per_epoch.append(float(avg_policy_loss))
        if avg_value_loss is not None:
            self.value_loss_per_epoch.append(float(avg_value_loss))
        if epoch_success_rate is not None:
            self.success_rate_per_epoch.append(float(epoch_success_rate))

        if avg_outcome_reward is not None:
            self.avg_outcome_rewards_per_epoch.append(float(avg_outcome_reward))
        if avg_progress_reward is not None:
            self.avg_progress_rewards_per_epoch.append(float(avg_progress_reward))
        if avg_structure_reward is not None:
            self.avg_structure_rewards_per_epoch.append(float(avg_structure_reward))
        if avg_efficiency_reward is not None:
            self.avg_efficiency_rewards_per_epoch.append(float(avg_efficiency_reward))
        if avg_stability_reward is not None:
            self.avg_stability_rewards_per_epoch.append(float(avg_stability_reward))

        self.epoch_times.append(time.time() - self.start_time)

    def update_error_analysis(
        self,
        error_type: str,
        verification_success: bool,
        proof_obligations: int,
    ) -> None:
        self.error_types[error_type].append(1)
        self.verification_success_rate.append(float(verification_success))
        self.proof_obligation_counts.append(int(proof_obligations))

    def _get_folder_name(self) -> str:
        parent = os.path.basename(os.path.dirname(self.save_dir))
        if parent:
            return parent
        return os.path.basename(self.save_dir) or "run"

    def plot_learning_curves(self) -> None:
        import matplotlib.pyplot as plt

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = self._get_folder_name()

        def save_plot(
            y_values,
            title: str,
            ylabel: str,
            filename: str,
            labels: Optional[List[str]] = None,
        ) -> None:
            if not y_values:
                return

            plt.figure(figsize=(12, 6))

            if isinstance(y_values[0], list):
                plotted = False
                for idx, vals in enumerate(y_values):
                    if vals:
                        label = labels[idx] if labels and idx < len(labels) else None
                        plt.plot(vals, label=label)
                        plotted = True
                if not plotted:
                    plt.close()
                    return
                if labels:
                    plt.legend()
            else:
                if not y_values:
                    plt.close()
                    return
                plt.plot(y_values)

            plt.xlabel("Step/Epoch")
            plt.ylabel(ylabel)
            plt.title(f"{title} - {folder_name}")
            plt.grid(True)
            plt.tight_layout()
            plt.savefig(
                os.path.join(
                    self.save_dir,
                    f"{filename}_{folder_name}_{timestamp}.png",
                )
            )
            plt.close()

        # Step-level plots
        save_plot(self.episode_rewards, "Episode Rewards", "Reward", "episode_rewards")
        save_plot(
            self.cumulative_rewards,
            "Cumulative Rewards",
            "Cumulative Reward",
            "cumulative_rewards",
        )
        save_plot(self.success_rates, "Success Rate", "Success Rate", "success_rate")
        save_plot(
            self.prompt_token_increases,
            "Prompt Token Increase",
            "Token Increase",
            "prompt_token_increase",
        )
        save_plot(self.kl_values, "KL Drift", "KL(pi_t || pi_t-1)", "kl_drift")

        # Error analysis
        if self.error_types:
            plt.figure(figsize=(12, 6))
            plotted = False
            for etype, counts in self.error_types.items():
                if counts:
                    plt.plot(counts, label=etype)
                    plotted = True
            if plotted:
                plt.xlabel("Step")
                plt.ylabel("Error Count")
                plt.title(f"Error Analysis - {folder_name}")
                plt.grid(True)
                plt.legend()
                plt.tight_layout()
                plt.savefig(
                    os.path.join(
                        self.save_dir,
                        f"error_analysis_{folder_name}_{timestamp}.png",
                    )
                )
            plt.close()

        # Loss plots
        if self.training_loss or self.validation_loss:
            plt.figure(figsize=(12, 6))
            if self.training_loss:
                plt.plot(self.training_loss, label="Training Loss")
            if self.validation_loss:
                plt.plot(self.validation_loss, label="Validation Loss")
            plt.xlabel("Epoch")
            plt.ylabel("Loss")
            plt.title(f"Training Loss - {folder_name}")
            plt.grid(True)
            plt.legend()
            plt.tight_layout()
            plt.savefig(
                os.path.join(
                    self.save_dir,
                    f"training_loss_{folder_name}_{timestamp}.png",
                )
            )
            plt.close()

        # Step-level reward breakdown
        reward_components = [
            self.outcome_rewards,
            self.progress_rewards,
            self.structure_rewards,
            self.efficiency_rewards,
            self.stability_rewards,
        ]
        reward_labels = ["Outcome", "Progress", "Structure", "Efficiency", "Stability"]

        if any(len(x) > 0 for x in reward_components):
            save_plot(
                reward_components,
                "Reward Breakdown (Step)",
                "Reward Component",
                "reward_breakdown_step",
                reward_labels,
            )

        # Epoch-level plots
        save_plot(
            self.average_rewards_per_epoch,
            "Average Reward per Epoch",
            "Avg Reward",
            "avg_reward_per_epoch",
        )
        save_plot(
            self.policy_loss_per_epoch,
            "Policy Loss per Epoch",
            "Policy Loss",
            "policy_loss_per_epoch",
        )
        save_plot(
            self.value_loss_per_epoch,
            "Value Loss per Epoch",
            "Value Loss",
            "value_loss_per_epoch",
        )
        save_plot(
            self.success_rate_per_epoch,
            "Success Rate per Epoch",
            "Success Rate",
            "success_rate_per_epoch",
        )

        epoch_reward_components = [
            self.avg_outcome_rewards_per_epoch,
            self.avg_progress_rewards_per_epoch,
            self.avg_structure_rewards_per_epoch,
            self.avg_efficiency_rewards_per_epoch,
            self.avg_stability_rewards_per_epoch,
        ]
        if any(len(x) > 0 for x in epoch_reward_components):
            save_plot(
                epoch_reward_components,
                "Reward Breakdown (Epoch)",
                "Avg Reward Component",
                "reward_breakdown_epoch",
                reward_labels,
            )

    def _build_step_metrics(self) -> Dict[str, Any]:
        return {
            "episode_rewards": self.episode_rewards,
            "cumulative_rewards": self.cumulative_rewards,
            "success_rates": self.success_rates,
            "error_counts": self.error_counts,
            "iteration_counts": self.iteration_counts,
            "outcome_rewards": self.outcome_rewards,
            "progress_rewards": self.progress_rewards,
            "structure_rewards": self.structure_rewards,
            "efficiency_rewards": self.efficiency_rewards,
            "stability_rewards": self.stability_rewards,
            "prompt_token_increases": self.prompt_token_increases,
            "kl_values": self.kl_values,
            "verification_success_rate": self.verification_success_rate,
            "proof_obligation_counts": self.proof_obligation_counts,
            "error_types": dict(self.error_types),
        }

    def _build_epoch_metrics(self) -> Dict[str, Any]:
        return {
            "epoch_rewards": self.average_rewards_per_epoch,
            "training_losses": self.training_loss,
            "validation_losses": self.validation_loss,
            "policy_losses": self.policy_loss_per_epoch,
            "value_losses": self.value_loss_per_epoch,
            "success_rate_per_epoch": self.success_rate_per_epoch,
            "avg_outcome_rewards": self.avg_outcome_rewards_per_epoch,
            "avg_progress_rewards": self.avg_progress_rewards_per_epoch,
            "avg_structure_rewards": self.avg_structure_rewards_per_epoch,
            "avg_efficiency_rewards": self.avg_efficiency_rewards_per_epoch,
            "avg_stability_rewards": self.avg_stability_rewards_per_epoch,
            "epoch_times": self.epoch_times,
        }

    def _build_full_metrics(self) -> Dict[str, Any]:
        return {
            "step_metrics": self._build_step_metrics(),
            "epoch_metrics": self._build_epoch_metrics(),
            "model_perplexity": self.model_perplexity,
            "total_time": time.time() - self.start_time,
            "saved_at": datetime.now().isoformat(),
        }

    def save_metrics(self) -> None:
        """
        Writes:
        1. step_metrics.json          -> stable path for step-level inspection
        2. epoch_metrics.json         -> stable path for parent W&B logger
        3. metrics_<folder>_<ts>.json -> archival full snapshot
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = self._get_folder_name()

        step_metrics = self._build_step_metrics()
        epoch_metrics = self._build_epoch_metrics()
        full_metrics = self._build_full_metrics()

        step_metrics_path = os.path.join(self.save_dir, "step_metrics.json")
        epoch_metrics_path = os.path.join(self.save_dir, "epoch_metrics.json")
        snapshot_path = os.path.join(
            self.save_dir,
            f"metrics_{folder_name}_{timestamp}.json",
        )

        with open(step_metrics_path, "w", encoding="utf-8") as f:
            json.dump(step_metrics, f, indent=2)

        with open(epoch_metrics_path, "w", encoding="utf-8") as f:
            json.dump(epoch_metrics, f, indent=2)

        with open(snapshot_path, "w", encoding="utf-8") as f:
            json.dump(full_metrics, f, indent=2)


_metrics_tracker: Optional[MetricsTracker] = None


def get_metrics_tracker() -> Optional[MetricsTracker]:
    return _metrics_tracker


def set_metrics_tracker(tracker: MetricsTracker) -> None:
    global _metrics_tracker
    _metrics_tracker = tracker