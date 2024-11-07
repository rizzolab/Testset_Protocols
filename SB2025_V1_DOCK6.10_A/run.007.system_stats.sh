#!/bin/sh
#SBATCH --partition=short-28core
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --job-name=testset
#SBATCH --output=zyy.07.testset.out
echo "Lig Rot Bonds,Lig MW,Lig Charge,Cofactor Present Prep, Cofactor Present Rec , Cofactor Present Grid, Lig/Cof Antechamber Clean,Protein Residues,Protein Charge Sngl Grid,# of Spheres, Sngl Grid Points,Minimized Lig RMSDh,DCEsum,DCEvdw,DCEes" > tmp1.csv
for sys in `cat zzz.lists/clean.systems.all`; do
rb=`grep "DOCK_Rotatable_Bonds:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2| awk '{print $3}' `
mw=`grep "Molecular_Weight:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`
fc_lig=`grep "Formal_Charge:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`
if ls -l zzz.master | grep -q ${sys}.cof.moe.mol2; then
   cof="Yes"
   if grep -q COF $sys/002.rec-prep/$sys.rec.clean.mol2;then
     cof_rec="Yes"
   else
     cof_rec="Missing" 
   fi

   if grep -q COF $sys/004.grid/grid.out;then
     cof_grd="Yes"
   else
     cof_grd="Missing"
   fi

else
   cof="No"
   cof_rec="No"
   cof_grd="No"
fi

if grep -q "Fatal Error" ${sys}/001.lig-prep/ac.lig.log; then
   lig_cof_ac="No"
else
   lig_cof_ac="Yes"
fi

num_res=`grep -A2 "@<TRIPOS>MOLECULE" ${sys}/002.rec-prep/${sys}.rec.clean.mol2 | awk '{print $3}'| tail -n1`

fc_res=`grep "Total charge on " ${sys}/004.grid/grid.out | awk '{print $6}'`

sph=`awk '{print $8}' ${sys}/003.spheres/${sys}.rec.clust.close.sph | head -n1`
grd_pnt=`grep "Total number of grid points   " ${sys}/004.grid/grid.out | awk '{print $7}'`

RMSDh_min=`grep "HA_RMSDh:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`
DCEsum=`grep "Continuous_Score:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`
DCEvdw=`grep "Continuous_vdw_energy:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`
DCEes=`grep "Continuous_es_energy:" ${sys}/004.multigrids/${sys}.lig.python.min.mol2 | awk '{print $3}'`

echo $rb "," $mw "," $fc_lig "," $cof "," $cof_rec "," $cof_grd "," $lig_cof_ac "," $num_res "," $fc_res "," $sph "," $grd_pnt "," $RMSDh_min "," $DCEsum "," $DCEvdw "," $DCEes >> tmp1.csv

done
