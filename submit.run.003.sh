#!/bin/bash
#SBATCH --partition=long-24core
#SBATCH --time=32:00:00
#SBATCH --nodes=3
#SBATCH --ntasks=24
#SBATCH --job-name=sph03
#SBATCH --output=zyy.03.sph_CYXREDO.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/CYX.txt`;do
echo "Running " $pdb
   srun --exclusive -N1 -n1 bash run.003.rec_dms_sph.sh  ${pdb} &> zzz.outfiles/${pdb}.003.sph.out &
done

wait
