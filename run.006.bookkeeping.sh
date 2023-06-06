#!/bin/bash
#SBATCH --partition=long-24core
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --job-name=atmcnt
#SBATCH --output=zyy.06.atmcnt.out
#This script checks if atom elements change from original lig.moe.mol2 to lig.am1bcc.mol2. Assumes Sybyl atom types

source run.000.set_env_vars.sh

rootdir="${VS_ROOTDIR}"
scriptdir="${rootdir}/zzz.scripts"
masterdir="${rootdir}/zzz.master"

module load anaconda/2
module load chimera/1.13.1
####################################
#Compile a list of defined residues from script fix_nonstandard_res.pl
rm zzz.lists/nonstandard_def.txt 
numfields=`grep "%amino"  zzz.scripts/fix_nonstandard_res.pl | awk -F"'" '{print $NF}'| tr -d ',;)'`

for i in `seq 1 $numfields`;do
num=$(( i*2 ))
grep "%amino"  zzz.scripts/fix_nonstandard_res.pl | awk -v val=$num -F"'" '{print $val}'| tr -d ',;)' >>zzz.lists/nonstandard_def.txt
done

grep 'if ($rec_resname' zzz.scripts/fix_nonstandard_res.pl | awk -F'"' '{print $2}'>>zzz.lists/nonstandard_def.txt

####################################
#Ligand
for system in `cat zzz.lists/CYX.txt`;
do
echo $system
rm -r $system/zzz.dat
mkdir $system/zzz.dat
cd $system/zzz.dat

sed -n "/ATOM/,/BOND/p" ../001.lig-prep/${system}.lig.am1bcc.mol2 | awk '{print $6}' | awk -F '.' '{print $1}'>tmp1.txt
sed -n "/ATOM/,/BOND/p" ${masterdir}/${system}.lig.moe.mol2 | awk '{print $6}' | awk -F '.' '{print $1}'>tmp2.txt

python ${scriptdir}/run.006v5.py > py.out
head -n1 py.out > atom_forml.txt
tail -n2 py.out | head -n1 > atom_diff.txt

######################################
#Receptor
rm tmp1.txt tmp2.txt py.out

#Use chimera to convert pdb to mol2 for ease of comparing receptor
cat << EOF > chimera.com
open ${masterdir}/${system}.rec.foramber.pdb 
write format mol2 0  ${system}.rec.foramber.mol2
EOF
#############################################
chimera --nogui chimera.com >& chimera.out

sed -n "/ATOM/,/BOND/p" ../002.rec-prep/${system}.rec.clean.mol2 | awk '{print $6}' | awk -F '.' '{print $1}' > tmp1.txt
sed -n "/ATOM/,/BOND/p" ${system}.rec.foramber.mol2 | awk '{print $6}' | awk -F '.' '{print $1}'>tmp2.txt
sed -n "/ATOM/,/BOND/p" ${masterdir}/${system}.cof.moe.mol2 | awk '{print $6}' | awk -F '.' '{print $1}'>>tmp2.txt

python ${scriptdir}/run.006v5.py > py.out
head -n1 py.out > atom_forml_rec.txt
tail -n2 py.out| head -n1 | awk -F'#' '{for (i=2;i<NF; i++) printf $i " "; print $NF}' > atom_diff_rec.txt
tail -n1 py.out > atom_diff_rec_mag.txt

rm tmp1.txt tmp2.txt py.out
#####################################
#End of atom counts

#Bookkeeping atoms added or deleted
#Heavy atoms added by amber
echo "0" > heavy_atoms_added.txt
grep "Heavy" ../002.rec-prep/leap.log | awk '{print $1}' > heavy_atoms_added.txt
awk '{ sum += $1; n++ }  END {print sum; }' heavy_atoms_added.txt >> heavy_atoms_added_sum.txt

#Atoms added or deleted in defined mutation
CME=`grep "CME" ${masterdir}/${system}.rec.foramber.pdb  | grep "ATOM" | awk '{print $6}'| uniq| wc -l`
CSD=`grep "CSD" ${masterdir}/${system}.rec.foramber.pdb  | grep "ATOM" | awk '{print $6}'| uniq| wc -l`
CSO=`grep "CSO" ${masterdir}/${system}.rec.foramber.pdb  | grep "ATOM" | awk '{print $6}'| uniq| wc -l`
SME=`grep "SME" ${masterdir}/${system}.rec.foramber.pdb  | grep "ATOM" | awk '{print $6}'| uniq| wc -l`
MHO=`grep "MHO" ${masterdir}/${system}.rec.foramber.pdb  | grep "ATOM" | awk '{print $6}'| uniq| wc -l`

#Keep track of heavy atoms added or deleted
count=0
tmp=$(( CME * 2 ))
count=$(( tmp + count ))

tmp=$(( CSD * 2 ))
count=$(( tmp + count ))

tmp=$(( CSO * 1 ))
count=$(( tmp + count ))

tmp=$(( SME * 1 ))
count=$(( tmp + count ))

tmp=$(( MHO * 1 ))
count=$(( tmp + count ))

#Heavy atom removed from dual occupancy residue
echo $count > heavy_atoms_deleted_mutation.txt
echo "0" > duplicate_remove.txt
grep ": duplicate" ../002.rec-prep/leap.log | awk -F'(' '{print $2}' | awk '{print $2}' | tr -d ')' >> duplicate_remove.txt
awk '{ sum += $1; n++ }  END {print sum; }' duplicate_remove.txt >>duplicate_remove_sum.txt

cd ../../
done
