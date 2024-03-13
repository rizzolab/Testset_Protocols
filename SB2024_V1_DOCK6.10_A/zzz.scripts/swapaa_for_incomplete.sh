module load chimera/1.13.1
sys="6WJC"

rm ${sys}_swapaa.com

echo "open zzz.master/${sys}.rec.foramber.pdb" >> ${sys}_swapaa.com
echo "sel 0"  >> ${sys}_swapaa.com
echo "resrenumber 1 sel"  >> ${sys}_swapaa.com
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "SER" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "SER" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 6 ]];
then
echo "swapaa ser :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "THR" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "THR" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 7 ]];
then
echo "swapaa thr :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "TYR" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "TYR" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 12 ]];
then
echo "swapaa tyr :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ASN" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ASN" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 8 ]];
then
echo "swapaa asn :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "GLN" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "GLN" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 9 ]];
then
echo "swapaa gln :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "CYS" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "CYS" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 6 ]];
then
echo "swapaa cys :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "VAL" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "VAL" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 7 ]];
then
echo "swapaa val :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "LEU" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "LEU" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 8 ]];
then
echo "swapaa leu :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ILE" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ILE" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 8 ]];
then
echo "swapaa ile :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "MET" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "MET" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 8 ]];
then
echo "swapaa met :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "PHE" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "PHE" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 11 ]];
then
echo "swapaa phe :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "TRP" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "TRP" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res; 
do 
if [[ $count -lt 14 ]]; 
then 
echo "swapaa trp :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi 
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ASP" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ASP" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 8 ]];
then
echo "swapaa asp :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "GLU" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "GLU" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 9 ]];
then
echo "swapaa glu :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "LYS" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "LYS" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 9 ]];
then
echo "swapaa lys :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ARG" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "ARG" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 11 ]];
then
echo "swapaa arg :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "HIS" | awk '{print $6}' | uniq > tmp.txt
grep "ATOM" zzz.master/${sys}.rec.foramber.pdb| grep -v "REMARK"  | grep "HIS" | awk '{print $6}' > tmp1.txt
grep -o -w -f tmp.txt tmp1.txt | sort | uniq -c > tmp2.txt
while read count res;
do
if [[ $count -lt 10 ]];
then
echo "swapaa his :" $res  >> ${sys}_swapaa.com
sed -i 's/: /:/g' ${sys}_swapaa.com
fi
done < "tmp2.txt"

echo "write format pdb 0  zzz.master/${sys}.rec.foramber.pdb" >> ${sys}_swapaa.com

chimera --nogui ${sys}_swapaa.com >& chimera.out
