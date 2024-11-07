system_file="zzz.lists/clean.systems.all"

if ls -l | grep "zyy.01.lig_missing.dat"; then
   rm zyy.01.lig_missing.dat
fi

for system in `cat ${system_file}`; do  

if ! ls -l ${system}/001.lig-prep | grep -q "${system}.lig.am1bcc.mol2"
then
   echo ${system}>> zyy.01.lig_missing.dat
fi

if ls -l zzz.master | grep "$system.cof.moe.mol2";then

   if ! ls -l ${system}/001.lig-prep | grep -q "${system}.cof.am1bcc.mol2"
   then
      echo ${system}>> zyy.01.cof_missing.dat
   fi

fi 
done

