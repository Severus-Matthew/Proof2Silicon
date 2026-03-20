#!/bin/bash
#SBATCH --job-name=dafny_rl              # Job name
#SBATCH --output=dafny_rl_%j.out         # Output file with job ID
#SBATCH --error=dafny_rl_%j.err          # Error file with job ID
#SBATCH --ntasks=2                      # Run a single task
#SBATCH --partition=gpu-a30-dchen       # Specify L40 GPU partition
#SBATCH --mail-type=BEGIN,END,FAIL      # Mail events
#SBATCH --mail-user=drprofmjha@gmail.com # Where to send email

# Set environment variables for better output handling
export PYTHONUNBUFFERED=1
export CUDA_VISIBLE_DEVICES=0,1
# Activate virtual environment
source dafny/bin/activate

# Print some debug information
echo "Starting job at $(date)"
echo "Running on host: $(hostname)"
echo "Python path: $(which python3)"
echo "GPU information: $(nvidia-smi)"

python3 /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_new.py 2>&1 | tee testing_output.log 






# Run the script with explicit output redirection
# python3 /mnt/shared/gpfs/home/manvij2/Preface_RL.py 2>&1 | tee training_output.log 
