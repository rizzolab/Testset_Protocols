#!/bin/bash
#SBATCH --partition=rn-long-40core
#SBATCH --time=32:00:00
#SBATCH --nodes=9
#SBATCH --ntasks=40
#SBATCH --job-name=mgr05
#SBATCH --output=zyy.05.mgr_redo.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/2024_11_04_rerun.dat `;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.005.multigrids.sh  ${pdb} &> zzz.outfiles/${pdb}.005.mgr.out &
done

wait
#bash run.005.multigrids.sh  ${pdb} &> zzz.outfiles/${pdb}.005.mgr.out
