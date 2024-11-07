#!/bin/sh
#SBATCH --partition=long-28core
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name=Transfer
#SBATCH --output=zyy.009.out
system_file="zzz.lists/clean.systems.all"
mkdir zzz.SB20XX_Testset
cd zzz.SB20XX_Testset

for system in `cat ../${system_file}`; do  
mkdir $system


cp ../${system}/004.grid/${system}.rec* ${system}
cp ../${system}/001.lig-prep/${system}.lig.am1bcc.mol2 $system
cp -r ../${system}/004.multigrids/  $system


echo $system

done

