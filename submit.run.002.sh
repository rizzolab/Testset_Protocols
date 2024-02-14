#!/bin/bash
#SBATCH --partition=long-24core
#SBATCH --time=32:00:00
#SBATCH --nodes=2
#SBATCH --ntasks=24
#SBATCH --job-name=rec02
#SBATCH --output=zyy.02.rec.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/CYX.txt`;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.002.rec_runleap.sh     ${pdb} &> zzz.outfiles/${pdb}.002.rec.out &
done

wait
