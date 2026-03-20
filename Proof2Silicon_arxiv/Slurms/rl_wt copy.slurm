#!/bin/bash
#SBATCH --job-name=test             # Job name
#SBATCH --output=test.out         # Output file with job ID
#SBATCH --error=test.err          # Error file with job ID
#SBATCH --ntasks=2                      # Run a single task
#SBATCH --partition=gpu-h100-dchen       # Specify L40 GPU partition
#SBATCH --mail-type=BEGIN,END,FAIL      # Mail events
#SBATCH --mail-user=drprofmjha@gmail.com # Where to send emai

echo "Job $SLURM_JOB_NAME (ID $SLURM_JOB_ID) started at $(date)"
sleep 120
echo "Job completed at $(date)"

