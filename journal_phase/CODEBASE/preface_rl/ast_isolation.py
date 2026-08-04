"""Cross-process isolation for the Dafny AST extractor's fixed output file.

The extractor currently writes one shared path:
  journal_phase/ast_json/dafny-ast-output.json

All four Slurm array tasks share the filesystem, so concurrent extractor calls can
otherwise overwrite or read each other's JSON.  This module installs a wrapper
around DafnyEnv.run_ast_plugin_and_analyzer that holds an advisory filesystem
lock across deletion, plugin execution, JSON read, and archival.
"""

import fcntl
import json
import os
import shutil
import time
from pathlib import Path
from typing import Any, Dict


DEFAULT_LOCK_PATH = (
    "/u/mjha1/Proof2Silicon/journal_phase/ast_json/"
    ".dafny_ast_extractor.lock"
)


def _safe_component(value: Any) -> str:
    text = str(value if value is not None else "unknown")
    return "".join(c if c.isalnum() or c in "._-" else "_" for c in text)


def install_ast_isolation(env_class) -> None:
    """Patch one DafnyEnv class exactly once."""
    if getattr(env_class, "_ast_isolation_installed", False):
        return

    original = env_class.run_ast_plugin_and_analyzer

    def isolated(self, dafny_file_path):
        lock_path = Path(os.environ.get("DAFNY_AST_LOCK_PATH", DEFAULT_LOCK_PATH))
        lock_path.parent.mkdir(parents=True, exist_ok=True)

        with lock_path.open("a+") as lock_handle:
            fcntl.flock(lock_handle.fileno(), fcntl.LOCK_EX)
            try:
                shared_ast = Path(self.ast_json_path)

                # Never allow a successful command to accidentally consume a
                # stale JSON left by an earlier job.
                try:
                    shared_ast.unlink()
                except FileNotFoundError:
                    pass

                features, parse_status = original(self, dafny_file_path)

                # Preserve the exact extractor output for paper/debug audit,
                # while the lock still guarantees it belongs to this call.
                if shared_ast.exists():
                    run_dir = Path(
                        os.environ.get(
                            "PROOF2SILICON_RUN_DIR",
                            "/u/mjha1/Proof2Silicon/journal_phase/journal_runs/unscoped",
                        )
                    )
                    archive_dir = run_dir / "artifacts" / "ast"
                    archive_dir.mkdir(parents=True, exist_ok=True)
                    task_name = Path(dafny_file_path).parent.name
                    filename = (
                        "ast_epoch_{}_iter_{}_task_{}_job_{}_{}.json".format(
                            _safe_component(getattr(self, "current_epoch", "unknown")),
                            _safe_component(getattr(self, "current_iteration", "unknown")),
                            _safe_component(task_name),
                            _safe_component(os.environ.get("SLURM_JOB_ID")),
                            time.time_ns(),
                        )
                    )
                    destination = archive_dir / filename
                    shutil.copy2(str(shared_ast), str(destination))

                    index_record: Dict[str, Any] = {
                        "timestamp_ns": time.time_ns(),
                        "study_id": os.environ.get("PROOF2SILICON_STUDY_ID"),
                        "experiment": os.environ.get("PROOF2SILICON_EXPERIMENT"),
                        "slurm_job_id": os.environ.get("SLURM_JOB_ID"),
                        "slurm_array_task_id": os.environ.get("SLURM_ARRAY_TASK_ID"),
                        "task_name": task_name,
                        "dafny_file": str(dafny_file_path),
                        "epoch": getattr(self, "current_epoch", None),
                        "iteration": getattr(self, "current_iteration", None),
                        "parse_status": parse_status,
                        "ast_artifact": str(destination),
                        "features": features,
                    }
                    index_path = run_dir / "audit" / "ast_extractions.jsonl"
                    index_path.parent.mkdir(parents=True, exist_ok=True)
                    with index_path.open("a", encoding="utf-8") as handle:
                        handle.write(json.dumps(index_record, ensure_ascii=False) + "\n")
                        handle.flush()
                        os.fsync(handle.fileno())

                return features, parse_status
            finally:
                fcntl.flock(lock_handle.fileno(), fcntl.LOCK_UN)

    env_class.run_ast_plugin_and_analyzer = isolated
    env_class._ast_isolation_installed = True
