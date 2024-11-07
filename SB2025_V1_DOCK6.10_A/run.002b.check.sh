system_file="zzz.lists/clean.systems.all"

if ls -l | grep "zyy.02.rec_missing.dat"; then
   rm zyy.02.rec_missing.dat
fi

for system in `cat ${system_file}`; do  

if ! grep -q "" ${system}/002.rec-prep/${system}.rec.clean.mol2
then
   echo ${system}>> zyy.02.rec_missing.dat
fi


done

