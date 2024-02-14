#!/bin/bash
#SBATCH --partition=long-24core
#SBATCH --time=32:00:00
#SBATCH --nodes=5
#SBATCH --ntasks=24
#SBATCH --job-name=mgr05
#SBATCH --output=zyy.05.mgr.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/CYX.txt`;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.005.multigrids.sh  ${pdb} &> zzz.outfiles/${pdb}.005.mgr.out &
done

wait
