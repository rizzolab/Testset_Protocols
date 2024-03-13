system_file="zzz.lists/clean.systems.all"

if ls -l | grep "zyy.03.sph_missing.dat"; then
   rm zyy.03.sph_missing.dat
fi

for system in `cat ${system_file}`; do  

if ! grep -q "" ${system}/003.spheres/${system}.rec.sph 
then
   echo ${system}>> zyy.03.sph_missing.dat
fi


done

