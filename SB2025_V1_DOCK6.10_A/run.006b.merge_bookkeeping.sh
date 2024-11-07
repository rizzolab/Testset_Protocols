#!/bin/sh
#SBATCH --partition=short-28core
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name=bkp
#SBATCH --output=zyy.06b.bkp.out

if ls -l | grep -q "atmcounts_all.csv";then
   rm atmcounts_all.csv
fi

echo "Ligand Formula, Receptor Formula, Final Count Receptor - Initial Count Receptor,Final Count Receptor - Initial Count Receptor Magnitude, Heavy Atoms Added to Incomplete Residues,Dual Occupancy Atoms, Atoms Deleted In Defined Mutation, Overall Balance" >>atmcounts_all.csv

for sys in `cat zzz.lists/clean.systems.all`;do
   echo $sys
   cd $sys/zzz.dat
   paste -d ',' atom_forml.txt atom_forml_rec.txt atom_diff_rec.txt atom_diff_rec_mag.txt  heavy_atoms_added_sum.txt duplicate_remove_sum.txt heavy_atoms_deleted_mutation.txt overall_balance.dat> atmcounts.csv
   cat atmcounts.csv >> ../../atmcounts_all.csv
   cd ../../
done
