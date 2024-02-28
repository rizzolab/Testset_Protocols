#!/bin/bash
#SBATCH --partition=long-24core
#SBATCH --time=32:00:00
#SBATCH --nodes=3
#SBATCH --ntasks=24
#SBATCH --job-name=sph03
#SBATCH --output=zyy.03.sph.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/clean.systems.all`;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.003.rec_dms_sph.sh  ${pdb} &> zzz.outfiles/${pdb}.003.sph.out &
done

wait
