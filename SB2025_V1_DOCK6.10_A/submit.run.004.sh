#!/bin/bash
#SBATCH --partition=rn-long-40core
#SBATCH --time=32:00:00
#SBATCH --nodes=9
#SBATCH --ntasks=40
#SBATCH --job-name=grd04
#SBATCH --output=zyy.04.grd.out

source run.000.set_env_vars.sh 
for pdb in `cat zzz.lists/2024_11_04_rerun.dat `;do
echo "Running " $pdb
   srun --mem=1000 --exclusive -N1 -n1 bash run.004.rec_grid_cluster.sh  ${pdb} &> zzz.outfiles/${pdb}.004.grd.out &
done

wait
#bash run.004.rec_grid_cluster.sh  ${pdb} &> zzz.outfiles/${pdb}.004.grd.out 
