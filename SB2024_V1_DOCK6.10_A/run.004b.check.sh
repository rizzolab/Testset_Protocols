system_file="zzz.lists/clean.systems.all"

if ls -l | grep "zyy.04.grd_missing.dat"; then
   rm zyy.04.grd_missing.dat
fi

for system in `cat ${system_file}`; do  

if ! ls -l ${system}/004.grid |grep -q -w "${system}.rec.bmp"
then
   echo ${system}>> zyy.04.grd_missing.dat
fi


done

