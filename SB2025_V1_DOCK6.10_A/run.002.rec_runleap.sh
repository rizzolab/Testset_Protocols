#!/bin/bash 

#
# This script prepares the receptor. Input required is ${system}.rec.foramber.pdb, which was
# prepared in MOE by removing everything except the protein and saving as a PDB. (no hydrogens or
# charges needed).
#
# Note that the environment variable $AMBERHOME should be externally to this script.
#

id| awk '{print $1}'| awk -F'(' '{print $2}'

### Set some paths
dockdir="${DOCKHOMEWORK}/bin"
amberdir="${AMBERHOMEWORK}/bin"
moedir="${MOEHOMEWORK}/bin"
rootdir="${VS_ROOTDIR}"
masterdir="${rootdir}/zzz.master"
paramdir="${rootdir}/zzz.parameters"
scriptdir="${rootdir}/zzz.scripts"
zincdir="${rootdir}/zzz.zinclibs"
system=${1}
vendor="${VS_VENDOR}"


### Check to see that if a cofactor exists, a corresponding am1bcc.mol2 also exists
if ls -l ${masterdir} | grep -q ${system}.cof.moe.mol2 ; then
	if  !  ls -l ${rootdir}/${system}/001.lig-prep | grep "${system}.cof.am1bcc.mol2" ; then
		echo "Cofactor expected for ${system} could not be found. Exiting."
		exit
	fi
fi


### Make the rec-prep directory
rm -fr ${rootdir}/${system}/002.rec-prep/
mkdir -p ${rootdir}/${system}/002.rec-prep/
cd ${rootdir}/${system}/002.rec-prep/


### Check to see if the protein file is present, and prepare it for amber
if  ! ls -l  ${masterdir} | grep -q "${system}.rec.foramber.pdb" ; then
	echo "Receptor file does not seem to exist. Exiting."
	exit
else
	# Hand-made rec.foramber.pdb file exists, so copy it over
	cp ${masterdir}/${system}.rec.foramber.pdb ./${system}.rec.foramber.pdb
fi

#Following step deletes unexpected HETATM residues so give a warning what is being deleted
if  grep HETATM $system.rec.foramber.pdb| grep -v -E "REMARK|REVDAT"  | grep -q -v -E " CA| MG | NA |ZN | K | CL | HEM | Y2P ";then
   echo "WARNING!!! The following residues are being deleted due to unexpected HETATM"
   grep HETATM *pdb| grep -v -E "REMARK|REVDAT"  | grep -v -E " CA| MG | NA |ZN | K | CL | HEM | Y2P "
fi


#Change all accepted HETATM lines to ATOM and delete all other lines
${scriptdir}/hetatm.sed -i ${system}.rec.foramber.pdb 




# Some sodium and chlorine come with names incompatible with vdw parm file. Also NA is already a Nitrogen in Heme
if  egrep -w 'ATOM|HETATM' ${system}.rec.foramber.pdb | egrep -w 'ZIN|MAG|CAL|CHL|SOD|POT' ; then
 echo "3 letter ion codes not accepted. Change Atom Name and Residue Name to ZN,MG,CA,CL,NA or K"
 exit
fi

### Remove unusual newlines from receptor
perl -pi -e 's/\r\n/\n/g' ${system}.rec.foramber.pdb


### Track the number of alpha carbons and TERs in the protein, warn if it changes
num_CA=`grep -c " CA " ${system}.rec.foramber.pdb`
num_TER=`grep -c "TER" ${system}.rec.foramber.pdb`
echo "${system}.rec.foramber.pdb has ${num_CA} alpha carbons and ${num_TER} TERS" | tee ${system}.report.txt


### Deal with non-standard residues
${scriptdir}/fix_nonstandard_res.pl ${system}.rec.foramber.pdb ../001.lig-prep/${system}.lig.am1bcc.mol2 out.pdb | tee ${system}.report.txt
mv ${system}.rec.foramber.pdb ${system}.rec.foramber.pdb.old
mv out.pdb ${system}.rec.foramber.pdb

### Change atom names O1P, O2P, O3Pin Y2P because they clash with old amber atom type names
if grep -q "Y2P" ${system}.rec.foramber.pdb;then
sed -i 's/O1P/O1Z/g' ${system}.rec.foramber.pdb 
sed -i 's/O2P/O2Z/g' ${system}.rec.foramber.pdb 
sed -i 's/O3P/O3Z/g' ${system}.rec.foramber.pdb
fi

### Copy some parameter files over that leap will need
cp -fr ${paramdir}/ions.frcmod ./
cp -fr ${paramdir}/ions.lib ./
cp -fr ${paramdir}/gaff_cz_mass_fix.frcmod ./
cp -fr ${paramdir}/heme.frcmod ./
cp -fr ${paramdir}/heme.prep ./
cp -fr ${paramdir}/y2p.frcmod ./
cp -fr ${paramdir}/y2p.off ./
cp -fr ${paramdir}/vdw_AMBER_parm99.defn ./vdw.defn
cp -fr ${paramdir}/chem.defn ./
touch box.pdb    # Needed for dock grid program


###
### Naming convention from here on is PRO = protein; COF = cofactor; REC = receptor = PRO + COF
###


### Read protein in with leap to renumber residues from 1
echo "Using AMBER version located at $AMBERHOME"
echo "------------ LEAP RUN_000 SUMMARY -------------" 
echo "Purpose: Split residues, renumber residues from 1"
echo "Removing hydrogens from rec.foramber.pdb --> pro.noH.pdb"
${scriptdir}/remove_hydrogens.pl ${system}.rec.foramber.pdb > pro.noH.pdb
echo -n "atoms in pro.noH.pdb = "
grep -c ATOM pro.noH.pdb
echo "Running leap.000 (Renumbering): pro.noH.pdb -> ${system}.pro.parm+pro.crd = pro.000.pdb"

##################################################
cat  > pro.leap.in<<EOF
set default PBradii mbondi2
source oldff/leaprc.ff14SB
loadoff ions.lib
loadamberparams ions.frcmod
loadamberparams heme.frcmod
loadamberparams frcmod.ions234lm_126_tip3p
loadamberparams frcmod.ions1lm_126_tip3p
loadamberparams frcmod.tip3p
loadamberprep heme.prep
loadoff y2p.off
loadamberparams y2p.frcmod
REC = loadpdb pro.noH.pdb
saveamberparm REC ${system}.pro.parm pro.crd
charge REC
quit
EOF
##################################################

${amberdir}/tleap -s -f pro.leap.in >& ${system}.pro.000.leap.log
${amberdir}/ambpdb -p ${system}.pro.parm -tit "pdb.000" -c pro.crd > pro.000.pdb
echo -n "atoms in pro.000.pdb (protonated) = "
grep -c ATOM pro.000.pdb

### Check to see if there were any errors with leap
num_CA=`grep -c " CA " pro.000.pdb`
num_TER=`grep -c "TER" pro.000.pdb`
echo "pro.000.pdb has ${num_CA} alpha carbons and ${num_TER} TERs"
echo -n "Number of missing heavy atoms added : "
grep -c "Added missing heavy atom" ${system}.pro.000.leap.log  
grep -A1 "WARNING"              ${system}.pro.000.leap.log 
#grep -A3 "Splitting"            ${system}.pro.000.leap.log  
if  grep  "FATAL" ${system}.pro.000.leap.log  >> ${system}.report.txt  ;then
        echo "Leap run had fatal errors. Exiting." ${system}.report.txt
        exit
fi
### Remake the pro.noH.pdb with the fixed receptor structure
echo "Removing hydrogens pro.000.pdb --> pro.noH.pdb"
${scriptdir}/remove_hydrogens.pl pro.000.pdb > pro.noH.pdb
echo -n "atoms in pro.noH.pdb = "
grep -c ATOM pro.noH.pdb

### Run leap an extra time to get correct residue numbers for long bonds
echo "------------ LEAP RUN_001 SUMMARY -------------"
echo "Purpose: Get correct residue numbers for long bonds, ss bonds" 
${amberdir}/tleap -s -f pro.leap.in >& ${system}.pro.001.leap.log
${amberdir}/ambpdb -p ${system}.pro.parm -tit "pdb.001" -c pro.crd > pro.001.pdb
echo -n "atoms in pro.001.pdb = "
grep -c ATOM pro.001.pdb
num_CA=`grep -c " CA " pro.001.pdb`
num_TER=`grep -c "TER" pro.001.pdb`
echo "pro.001.pdb has ${num_CA} alpha carbons and ${num_TER} TERs"


### Generate SS bonds, fix HIE/HID, remove hydrogens
echo "Running fix_long_bonds.pl: ssbonds.txt, hie/hid, del hydrogens" 
${scriptdir}/fix_long_bonds.pl pro.001.pdb ${system}.pro.001.leap.log pro.noH.pdb
echo -n "atoms in pro.noH.pdb = "
grep -c ATOM pro.noH.pdb
if ls -l | grep -q "ssbonds.txt" ;then
	numss=`wc -l ssbonds.txt | awk '{print $1}'`
	echo "${numss} disulphide bonds are required"
else
	echo "0 disulphide bonds are required"
fi
echo "--------------------------------------------------------"


### Preapre the ligand file with antechamber
echo "Creating ligand prep file with antechamber"
${amberdir}/antechamber -i ../001.lig-prep/${system}.lig.am1bcc.mol2 -fi mol2  -o ${system}.lig.ante.mol2 -fo mol2 -dr n
#echo "Creating ligand pdb file with antechamber"
#${amberdir}/antechamber -i ../001.lig-prep/${system}.lig.am1bcc.mol2 -fi mol2  -o ${system}.lig.ante.pdb -fo pdb -dr n
echo "Creating ligand prep file with parmchk2"
${amberdir}/parmchk2 -i ${system}.lig.ante.mol2 -f mol2 -o ${system}.lig.ante.frcmod

### Prepare the cofactor file with antechamber, if it exists
if ls -l ../001.lig-prep | grep -q "${system}.cof.am1bcc.mol2" ;then
        echo "Creating cofactor prep file with antechamber" 
        $amberdir/antechamber -fi mol2 -fo prepi -i ../001.lig-prep/$system.cof.am1bcc.mol2 -o $system.cof.ante.prepi -at gaff2 -j 5 -rn COF -dr no
        echo "Creating cofactor pdb file with antechamber" 
         ${amberdir}/antechamber -fi mol2 -fo pdb -i ../001.lig-prep/${system}.cof.am1bcc.mol2 -o ${system}.cof.ante.pdb -at sybyl -j 5 -rn COF -dr no

        echo "Creating cofactor frcmod file with parmchk2" 
        ${amberdir}/parmchk2 -i ${system}.cof.ante.prepi -f prepi -o ${system}.cof.ante.frcmod
fi

### Make tleap input for Complex
##################################################
cat > com.leap.in<<EOF
set default PBradii mbondi2
source oldff/leaprc.ff14SB
source leaprc.gaff
loadoff ions.lib
loadamberparams ions.frcmod
loadamberparams frcmod.ions234lm_126_tip3p
loadamberparams frcmod.ions1lm_126_tip3p
loadamberparams frcmod.tip3p
loadamberparams heme.frcmod
loadamberprep heme.prep
loadoff y2p.off
loadamberparams y2p.frcmod
loadamberparams gaff_cz_mass_fix.frcmod
PRO = loadpdb pro.noH.pdb
EOF
cat ssbonds.txt >> com.leap.in
cat  >> com.leap.in<<EOF
loadamberparams ${system}.lig.ante.frcmod
LIG = loadmol2 ${system}.lig.ante.mol2
EOF
##################################################


if ls -l ${masterdir} | grep -q "${system}.cof.moe.mol2" ;then
	echo "Generating complex = pro+lig+cof"
	echo "loadamberparams ${system}.cof.ante.frcmod" >> com.leap.in
	echo "loadamberprep ${system}.cof.ante.prepi" >> com.leap.in
	echo "COF = loadpdb ${system}.cof.ante.pdb" >> com.leap.in
	echo "REC = combine { PRO COF }" >> com.leap.in
	echo "saveamberparm COF ${system}.cof.parm ${system}.cof.ori.crd"  >> com.leap.in
else
	echo "Generating complex = pro+lig (no cof)"
	echo "REC = combine { PRO }" >> com.leap.in
fi
echo "COM = combine { REC LIG }" >> com.leap.in
echo "saveamberparm LIG ${system}.lig.parm ${system}.lig.ori.crd"  >> com.leap.in
echo "saveamberparm PRO ${system}.pro.parm ${system}.pro.ori.crd"  >> com.leap.in
echo "saveamberparm REC ${system}.rec.parm ${system}.rec.ori.crd"  >> com.leap.in
echo "saveamberparm COM ${system}.com.parm ${system}.com.ori.crd"  >> com.leap.in
echo "fixatomorder" >>com.leap.in
echo "quit" >> com.leap.in


### Use leap to generate complex
echo "------------ LEAP RUN_002 SUMMARY -------------"
echo "Purpose: Generate complex with ssbonds"
${amberdir}/tleap -s -f com.leap.in >& ${system}.com.leap.log
${amberdir}/ambpdb -p ${system}.lig.parm -tit "lig" -c ${system}.lig.ori.crd > ${system}.lig.ori.pdb
${amberdir}/ambpdb -p ${system}.pro.parm -tit "pro" -c ${system}.pro.ori.crd > ${system}.pro.ori.pdb
${amberdir}/ambpdb -p ${system}.rec.parm -tit "rec" -c ${system}.rec.ori.crd > ${system}.rec.ori.pdb
${amberdir}/ambpdb -p ${system}.com.parm -tit "com" -c ${system}.com.ori.crd > ${system}.com.ori.pdb
echo -n "atoms in ${system}.lig.ori.pdb = "
grep -c ATOM ${system}.lig.ori.pdb
echo -n "atoms in ${system}.pro.ori.pdb = "
grep -c ATOM ${system}.pro.ori.pdb
echo -n "atoms in ${system}.rec.ori.pdb = "
grep -c ATOM ${system}.rec.ori.pdb
echo -n "atoms in ${system}.com.ori.pdb = "
grep -c ATOM ${system}.com.ori.pdb


### Run sander to minimize hydrogen positions
echo "Creating ori.mol2 files before minimization"

${amberdir}/ambpdb -p ${system}.lig.parm -c ${system}.lig.ori.crd -mol2 -sybyl > ${system}.lig.ori.mol2 
${amberdir}/ambpdb -p ${system}.pro.parm -c ${system}.pro.ori.crd -mol2 -sybyl > ${system}.pro.ori.mol2 
${amberdir}/ambpdb -p ${system}.rec.parm -c ${system}.rec.ori.crd -mol2 -sybyl > ${system}.rec.ori.mol2 
${amberdir}/ambpdb -p ${system}.com.parm -c ${system}.com.ori.crd -mol2 -sybyl > ${system}.com.ori.mol2

#${amberdir}/antechamber -i ${system}.lig.ori.0.mol2 -fi mol2 -at sybyl -o ${system}.lig.ori.mol2 -fo mol2 -dr n
#${amberdir}/antechamber -i ${system}.pro.ori.0.mol2 -fi mol2 -at sybyl -o ${system}.pro.ori.mol2 -fo mol2 -dr n
#${amberdir}/antechamber -i ${system}.rec.ori.0.mol2 -fi mol2 -at sybyl -o ${system}.rec.ori.mol2 -fo mol2 -dr n
#${amberdir}/antechamber -i ${system}.com.ori.0.mol2 -fi mol2 -at sybyl -o ${system}.com.ori.mol2 -fo mol2 -dr n
 
if ls -l ${masterdir} | grep -q "${system}.cof.moe.mol2" ;then
	${amberdir}/ambpdb -p ${system}.cof.parm -c ${system}.cof.ori.crd -mol2 -sybyl > ${system}.cof.ori.mol2 
fi

##################################################
cat  >sander.in<<EOF
01mi minimization
 &cntrl
    imin = 1, maxcyc = 100,
    ntpr = 10, ntx=1,
    ntb = 0, cut = 10.0,
    ntr = 1, drms=0.1,
    restraintmask = "!@H=",
    restraint_wt  = 1000.0
&end
EOF
##################################################

echo "---------------------------------------------------------"
echo "Minimizing complex with sander"
${amberdir}/sander -O -i sander.in -o sander.out -p ${system}.com.parm -c ${system}.com.ori.crd -ref ${system}.com.ori.crd -r ${system}.com.min.rst
${amberdir}/ambpdb -p ${system}.com.parm -tit "${system}.com.min" -c ${system}.com.min.rst > ${system}.com.min.pdb
grep -A1 "NSTEP" sander.out | tail -2

if ! ls -l | grep -q "${system}.com.min.rst"; then
	echo "Complex minimizaton failed! Terminating."
	exit
fi


### Run sander on ligand alone to see if gaff screwed up anything
echo "---------------------------------------------------------"

##################################################
cat  >sander.lig.in <<EOF1
01mi minimization
 &cntrl
    imin = 1, maxcyc = 1000,
    ntpr = 10, ntx=1,
    ntb = 0, cut = 10.0,
    ntr = 0, drms=0.1,
&end
EOF1
##################################################

echo "Minimizing unrestrained gas-phase ligand alone with sander"
${amberdir}/sander -O -i sander.lig.in -o sander.lig.out -p ${system}.lig.parm -c ${system}.lig.ori.crd -r ${system}.lig.only.min.rst
${amberdir}/ambpdb -p ${system}.lig.parm -c ${system}.lig.only.min.rst -mol2 -sybyl > ${system}.lig.only.min.mol2
#${amberdir}/antechamber -i ${system}.lig.only.min.0.mol2 -fi mol2 -at sybyl -o ${system}.lig.only.min.mol2 -fo mol2 -dr n 
#${amberdir}/top2mol2 -p ${system}.lig.parm -c ${system}.lig.only.min.rst -o ${system}.lig.only.min.mol2 -at sybyl -bt sybyl

grep "SANDER BOMB" sander.lig.out
grep -A1 NSTEP sander.lig.out | tail -2
echo -n "Minimizing Ligand 1000 steps alone rmsd "
python ${scriptdir}/calc_rmsd_mol2.py ${system}.lig.ori.mol2 ${system}.lig.only.min.mol2


### Run sander on cofactor alone (if it exists) to see if gaff screwed up anything
if ls -l ${masterdir} | grep -q "${system}.cof.moe.mol2" ;then
	echo "---------------------------------------------------------"
	echo "Minimizing unrestrained gas-phase cofactor alone with sander"
	cp sander.lig.in sander.cof.in
	${amberdir}/sander -O -i sander.cof.in -o sander.cof.out -p ${system}.cof.parm -c ${system}.cof.ori.crd -r ${system}.cof.only.min.rst
	${amberdir}/ambpdb -p ${system}.cof.parm -c ${system}.cof.only.min.rst -mol2 -sybyl > ${system}.cof.only.min.mol2
	#${amberdir}/top2mol2 -p ${system}.cof.parm -c ${system}.cof.only.min.rst -o ${system}.cof.only.min.mol2 -at sybyl -bt sybyl
	grep "SANDER BOMB" sander.cof.out
	grep -A1 NSTEP sander.cof.out | tail -2
	echo -n "Minimizing Cofactor 1000 steps alone rmsd "
	python ${scriptdir}/calc_rmsd_mol2.py ${system}.cof.ori.mol2 ${system}.cof.only.min.mol2
else
	echo "No cofactor present to minimize"
fi


### Extract some files from the minimized complex
echo "---------------------------------------------------------"
echo "Extracting receptor with cpptraj"
echo "trajin ${system}.com.min.rst" > rec.ptraj.in
echo "strip :LIG" >> rec.ptraj.in
echo "trajout ${system}.rec.min.rst restart"  >> rec.ptraj.in
${amberdir}/cpptraj ${system}.com.parm rec.ptraj.in >& rec.ptraj.out
grep STRIP rec.ptraj.out 
echo "Writing receptor mol2"

#Yuzhang modification made for multiple ligands aka waters etc.
${amberdir}/ambpdb -p ${system}.rec.parm -c ${system}.rec.min.rst -mol2 -sybyl > ${system}.rec.min.mol2
#${amberdir}/antechamber -i ${system}.rec.min.0.mol2 -fi mol2 -at sybyl -o ${system}.rec.min.mol2 -fo mol2 -dr n 

#${amberdir}/top2mol2 -p ${system}.rec.parm -c ${system}.rec.min.rst -o ${system}.rec.min.mol2 -at sybyl -bt sybyl
echo "Creating ligand mol2 file"
echo "trajin ${system}.com.min.rst" > lig.ptraj.in
echo "strip !(:LIG)" >> lig.ptraj.in
echo "trajout ${system}.lig.min.rst restart"  >> lig.ptraj.in
${amberdir}/cpptraj ${system}.com.parm lig.ptraj.in >& lig.ptraj.out
grep STRIP lig.ptraj.out
${amberdir}/ambpdb -p ${system}.lig.parm -c ${system}.lig.min.rst -mol2 > ${system}.lig.min.0.mol2 
${amberdir}/ambpdb -p ${system}.com.parm -c ${system}.com.min.rst -mol2 -sybyl > ${system}.com.min.mol2
${amberdir}/antechamber -i ${system}.lig.min.0.mol2 -fi mol2 -at sybyl -o ${system}.lig.min.mol2 -fo mol2 -dr n
#${amberdir}/antechamber -i ${system}.com.min.0.mol2 -fi mol2 -at sybyl -o ${system}.com.min.mol2 -fo mol2 -dr n 
#${amberdir}/top2mol2 -p ${system}.lig.parm -c ${system}.lig.min.rst -o ${system}.lig.min.mol2 -at sybyl -bt sybyl 
#${amberdir}/top2mol2 -p ${system}.com.parm -c ${system}.com.min.rst -o ${system}.com.min.mol2 -at sybyl -bt sybyl


### Compute some RMSDs to check for consistency
echo -n "Minimized Ligand rmsd "
python ${scriptdir}/calc_rmsd_mol2.py ${system}.lig.ori.mol2 ${system}.lig.min.mol2
echo -n "Minimized Receptor rmsd "
python ${scriptdir}/calc_rmsd_mol2.py ${system}.rec.ori.mol2 ${system}.rec.min.mol2
echo -n "Minimized Complex rmsd "
python ${scriptdir}/calc_rmsd_mol2.py ${system}.com.ori.mol2 ${system}.com.min.mol2
python ${scriptdir}/clean_mol2.py ${system}.rec.min.mol2 ${system}.rec.python.mol2 
python ${scriptdir}/clean_mol2.py ${system}.lig.min.mol2 ${system}.lig.python.mol2

### Create the pdb that will be used for MD simulations 
### Now this pdb matches the mol2 used for docking
${amberdir}/ambpdb -p ${system}.rec.parm -c ${system}.rec.min.rst > ${system}.rec.clean.pdb



### Run check grid
##################################################
cat  >grid.in<< EOF
compute_grids                  no
output_molecule                yes
box_file                       box.pdb
receptor_file                  ${system}.rec.python.mol2
receptor_out_file              ${system}.rec.clean.mol2
EOF
##################################################

${dockdir}/grid -v -i grid.in -o grid.out
echo -n "CHECK GRID: " 
grep "Total charge on" grid.out  


### Remove some extra files
rm -f showbox vdw.defn chem.defn box.pdb
rm -f antechamber tleap teLeap parmchk ambpdb sander
rm -f ANTE* ATOMTYPE.INF NEWPDB.PDB PREP.INF
rm -f ions.frcmod ions.lib parm.e16.dat gaff*frcmod y2p.* heme.*
#rm -f ${system}.rec.min.mol2 ${system}.rec.nomin.mol2 ${system}.rec.foramber.pdb 
#rm -f ${system}.com.* ${system}.lig.* ${system}.rec.leap* ${system}.rec.gas*
#rm -f mdinfo grid.in sander.* ssbonds.txt

### ambpdb not writing out sybyl atom type for ion. (Calcium, Sodium, Magnesium, Zinc, Chlorine)
### Need to make them suitable for GRID (HEME cofactor contains Nitrogen NA)
#It should be ensured there are no atom types in the 6th field which match the uppercase strings other than intended ions
perl -pe 's{^\s*(\S+\s+){5}\K\S+}{$& =~ s/CA/Ca/gr}e' $system.rec.clean.mol2 > tmp1
perl -pe 's{^\s*(\S+\s+){5}\K\S+}{$& =~ s/NA/Na/gr}e unless /HEM/' tmp1 > tmp2
perl -pe 's{^\s*(\S+\s+){5}\K\S+}{$& =~ s/MG/Mg/gr}e' tmp2 > tmp3
perl -pe 's{^\s*(\S+\s+){5}\K\S+}{$& =~ s/ZN/Zn/gr}e' tmp3 > tmp4
perl -pe 's{^\s*(\S+\s+){5}\K\S+}{$& =~ s/CL/Cl/gr}e' tmp4 > tmp5



#Save the unedited version
mv ${system}.rec.clean.mol2 $system.rec.before_ion_edit.mol2
mv tmp5 ${system}.rec.clean.mol2 

rm tmp1 tmp2 tmp3 tmp4 
exit
