#!/bin/bash
#SBATCH --job-name=my_job_gemini2flash1              # Job name
#SBATCH --output=my_job_gemini2flash1.out            # Output file (stdout)
#SBATCH --error=my_job_gemini2flash1.err             # Error file (stderr)
#SBATCH --ntasks=1                     # Number of tasks (1 for most programs)
#SBATCH --mail-type=END,FAIL           # Notifications for job done & fail
#SBATCH --mail-user=drprofmjha@gmail.com  # Where to send email notifications
#SBATCH --partition=gpu-h100-dchen 

# Run your program
source dafny/bin/activate
python3 /mnt/shared/gpfs/home/manvij2/Preface_RL_1.py
