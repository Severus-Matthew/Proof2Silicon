#!/bin/bash
#SBATCH --job-name=my_job_chatgpt5_1codexMax             # Job name
#SBATCH --output=my_job_chatgpt5_1codexMax.out               # Output file (stdout)
#SBATCH --error=my_job_chatgpt5_1codexMax.err             # Error file (stderr)
#SBATCH --ntasks=1                     # Number of tasks (1 for most programs)
#SBATCH --time=6:00:00                # Time limit (e.g., 2 hours)
#SBATCH --mail-type=END,FAIL           # Notifications for job done & fail
#SBATCH --mail-user=drprofmjha@gmail.com  # Where to send email notifications
#SBATCH --partition=gpu-h100-dchen


# Run your program
source /mnt/shared/gpfs/home/manvij2/dafny/bin/activate
export OPENAI_API_KEY="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"
python3 /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Baseline_feedback_Deepseekv32.py --temperature 0.25
