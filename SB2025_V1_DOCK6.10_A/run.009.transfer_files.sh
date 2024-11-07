#!/bin/sh
#SBATCH --partition=long-28core
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name=Whaddup
#SBATCH --output=boop
system_file="zzz.lists/clean.systems.all"
mkdir zzz.testsetname
cd zzz.testsetname

for system in `cat ../${system_file}`; do  
mkdir $system


cp ../${system}/004.grid/${system}.rec* ${system}
cp ../${system}/001.lig-prep/${system}.lig.am1bcc.mol2 $system
cp -r ../${system}/004.multigrids/  $system
#cp ../${system}/002.rec-prep/${system}.rec.clean.mol2 $system


echo $system

done

