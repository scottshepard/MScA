#!/bin/bash

#SBATCH --account=mscagpu
#SBATCH --job-name=rcc_example
#SBATCH --output=%j_out.log
#SBATCH --error=%j_err.log
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=mscagpu
#SBATCH --gres=gpu:1
#SBATCH --mem-per-cpu=20000


# Load modules:
module load Anaconda3/5.0.1 cuda/9.0

# Activate conda environment:
source activate z11

# GPU-based executable:
python RCC_Example_copy.py
