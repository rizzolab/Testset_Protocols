mkdir zzz.testset

for sys in `cat zzz.lists/testset_cases.dat `;do

   cp $sys/002.rec-prep/$sys.rec.clean.mol2 zzz.testset
 
done
