#!/bin/bash
#SBATCH --job-name=my_job_gemini2flash               # Job name
#SBATCH --output=my_job_gemini2flash.out            # Output file (stdout)
#SBATCH --error=my_job_gemini2flash.err             # Error file (stderr)
#SBATCH --ntasks=1                     # Number of tasks (1 for most programs)
#SBATCH --time=18:00:00                # Time limit (e.g., 2 hours)
#SBATCH --mail-type=END,FAIL           # Notifications for job done & fail
#SBATCH --mail-user=drprofmjha@gmail.com  # Where to send email notifications
#SBATCH --partition=gpu-a30

# Run your program
source dafny/bin/activate
python3 /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/finetune.py
