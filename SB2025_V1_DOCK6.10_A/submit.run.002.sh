#!/bin/bash
#SBATCH --partition=rn-long-40core
#SBATCH --time=32:00:00
#SBATCH --nodes=5
#SBATCH --ntasks=40
#SBATCH --job-name=rec02
#SBATCH --output=zyy.02.rec.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/2024_11_04_rerun.dat  `;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.002.rec_runleap.sh     ${pdb} &> zzz.outfiles/${pdb}.002.rec.out &
done

wait
