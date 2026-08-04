"""Runtime isolation for parallel journal-training processes.

The four Slurm array tasks read the same immutable dataset but must never write
candidate Dafny code, verifier output, weighted records, or iteration artifacts
into the shared dataset folders. This module replaces the trainer's DafnyEnv
constructor with a run-scoped version.
"""

import logging
import os
import re
from pathlib import Path


def _slug(value: str) -> str:
    text = re.sub(r"[^A-Za-z0-9_.-]+", "_", str(value or "task"))
    return text.strip("_") or "task"


def install_parallel_environment_isolation() -> None:
    import preface_rl.envs as envs_module
    import preface_rl.slm as slm_module

    base_env = envs_module.DafnyEnv
    run_dir_value = os.environ.get("PROOF2SILICON_RUN_DIR")
    if not run_dir_value:
        raise RuntimeError(
            "PROOF2SILICON_RUN_DIR is required for parallel journal training"
        )
    run_dir = Path(run_dir_value)
    workspace_root = run_dir / "workspaces"
    workspace_root.mkdir(parents=True, exist_ok=True)

    class RunScopedDafnyEnv(base_env):
        def __init__(self, prompt: str, tmp_path: str, error_path: str):
            source_tmp = Path(tmp_path)
            source_error = Path(error_path)
            source_subfolder = source_tmp.parent
            task_name = _slug(source_subfolder.name)
            task_workspace = workspace_root / task_name
            task_workspace.mkdir(parents=True, exist_ok=True)

            isolated_tmp = task_workspace / source_tmp.name
            isolated_error = task_workspace / source_error.name
            super().__init__(
                prompt=prompt,
                tmp_path=str(isolated_tmp),
                error_path=str(isolated_error),
            )
            self.source_subfolder_path = str(source_subfolder)
            self.task_name = task_name
            self.run_workspace_path = str(task_workspace)

    # slm.py imported DafnyEnv by value, so replace both references.
    envs_module.DafnyEnv = RunScopedDafnyEnv
    slm_module.DafnyEnv = RunScopedDafnyEnv
    logging.info("Parallel Dafny workspaces enabled under %s", workspace_root)
