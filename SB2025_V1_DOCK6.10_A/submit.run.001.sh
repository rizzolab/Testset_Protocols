#!/bin/bash
#SBATCH --partition=long-28core
#SBATCH --time=12:00:00
#SBATCH --nodes=6
#SBATCH --ntasks=28
#SBATCH --job-name=lig01
#SBATCH --output=zyy.01.lig.out
pwd
source run.000.set_env_vars.sh
mkdir zzz.outfiles
for pdb in `cat zzz.lists/clean.systems.all`; do
echo "Running " $pdb
   srun --exclusive -N1 -n1 bash run.001.lig_clean_am1bcc.sh  ${pdb} &> zzz.outfiles/${pdb}.001.lig.out &
done

wait
