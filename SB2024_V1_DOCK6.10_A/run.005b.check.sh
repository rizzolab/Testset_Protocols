system_file="zzz.lists/clean.systems.all"

if ls -l | grep "zyy.05.mgr_missing.dat"; then
   rm zyy.05.mgr_missing.dat
fi

for system in `cat ${system_file}`; do  

if ! ls -l ${system}/004.multigrids |grep -q -w "${system}.resid_remaining.bmp"
then
   echo ${system}>> zyy.05.mrg_missing.dat
fi


done

