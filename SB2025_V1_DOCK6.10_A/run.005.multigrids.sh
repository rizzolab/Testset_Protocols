id| awk '{print $1}'| awk -F'(' '{print $2}'

module load anaconda/2

### Set some variables manually
attractive="6"
repulsive="9"
grid_spacing="0.3"
box_margin="8"
sphcut="8"
maxkeep="75"


### Set some paths
dockdir="${DOCKHOMEWORK}/bin"
amberdir="${AMBERHOMEWORK}/bin"
moedir="${MOEHOMEWORK}/bin"
rootdir="${VS_ROOTDIR}"
masterdir="${rootdir}/zzz.master"
paramdir="${rootdir}/zzz.parameters"
scriptdir="${rootdir}/zzz.scripts"
system=${1}


### Make sure the receptor and spheres are present
if ! ls -l ${rootdir}/${system}/002.rec-prep |  grep -q "${system}.rec.clean.mol2" ;then
        echo "Missing ${system}.rec.clean.mol2. Exiting."
        exit
fi

if ! ls -l ${rootdir}/${system}/003.spheres | grep -q "${system}.rec.clust.close.pdb" ;then
        echo "Missing ${system}.rec.clust.close.pdb. Exiting."
        exit
fi


### Make the grid preparation directory
rm -fr ${rootdir}/${system}/004.multigrids/
mkdir -p ${rootdir}/${system}/004.multigrids/
cd ${rootdir}/${system}/004.multigrids/


### Link and copy some files here
cp ${paramdir}/vdw_AMBER_parm99.defn ./vdw.defn
cp ${paramdir}/chem.defn ./chem.defn
cp ${rootdir}/${system}/004.grid/box.pdb ./


cat >${system}.reference_minimization.in<<EOF
conformer_search_type                                        rigid
use_internal_energy                                          yes
internal_energy_rep_exp                                      12
internal_energy_cutoff                                       100
ligand_atom_file                                             ${rootdir}/${system}/001.lig-prep/${system}.lig.am1bcc.mol2
limit_max_ligands                                            no
skip_molecule                                                no
read_mol_solvation                                           no
calculate_rmsd                                               yes
use_rmsd_reference_mol                                       yes
rmsd_reference_filename                                      ${rootdir}/${system}/001.lig-prep/${system}.lig.am1bcc.mol2
use_database_filter                                          no
orient_ligand                                                no
bump_filter                                                  no
score_molecules                                              yes
contact_score_primary                                        no
contact_score_secondary                                      no
grid_score_primary                                           no
grid_score_secondary                                         no
multigrid_score_primary                                      no
multigrid_score_secondary                                    no
dock3.5_score_primary                                        no
dock3.5_score_secondary                                      no
continuous_score_primary                                     yes
continuous_score_secondary                                   no
cont_score_rec_filename                                      ${rootdir}/${system}/002.rec-prep/${system}.rec.clean.mol2
cont_score_att_exp                                           ${attractive}
cont_score_rep_exp                                           ${repulsive}
cont_score_rep_rad_scale                                     1
cont_score_use_dist_dep_dielectric                           yes
cont_score_dielectric                                        4.0
cont_score_vdw_scale                                         1
cont_score_es_scale                                          1
footprint_similarity_score_secondary                         no
pharmacophore_score_score_secondary                          no
descriptor_score_secondary                                   no
gbsa_zou_score_secondary                                     no
gbsa_hawkins_score_secondary                                 no
SASA_score_secondary                                         no
amber_score_secondary                                        no
minimize_ligand                                              yes
simplex_max_iterations                                       1000
simplex_tors_premin_iterations                               0
simplex_max_cycles                                           1
simplex_score_converge                                       0.1
simplex_cycle_converge                                       1.0
simplex_trans_step                                           1.0
simplex_rot_step                                             0.1
simplex_tors_step                                            10.0
simplex_random_seed                                          0
simplex_restraint_min                                        yes
simplex_coefficient_restraint                                5.0
atom_model                                                   all
vdw_defn_file                                                ${paramdir}/vdw_AMBER_parm99.defn
flex_defn_file                                               ${paramdir}/flex.defn
flex_drive_file                                              ${paramdir}/flex_drive.tbl
ligand_outfile_prefix                                        output
write_orientations                                           no
num_scored_conformers                                        1
rank_ligands                                                 no
EOF
##################################################

### Execute dock on the headnode
${dockdir}/dock6 -i ${system}.reference_minimization.in -o ${system}.reference_minimization.out
mv output_scored.mol2 ${system}.lig.python.min.mol2

echo " Write footprints for multigrids later"
###########################################################################################
cat >${system}.footprint_rescore.in <<EOF
conformer_search_type                                        rigid
use_internal_energy                                          no
ligand_atom_file                                             ${system}.lig.python.min.mol2
limit_max_ligands                                            no
skip_molecule                                                no
read_mol_solvation                                           no
calculate_rmsd                                               no
use_database_filter                                          no
orient_ligand                                                no
bump_filter                                                  no
score_molecules                                              yes
contact_score_primary                                        no
contact_score_secondary                                      no
grid_score_primary                                           no
grid_score_secondary                                         no
multigrid_score_primary                                      no
multigrid_score_secondary                                    no
dock3.5_score_primary                                        no
dock3.5_score_secondary                                      no
continuous_score_primary                                     no
continuous_score_secondary                                   no
footprint_similarity_score_primary                           yes
footprint_similarity_score_secondary                         no
fps_score_use_footprint_reference_mol2                       yes
fps_score_footprint_reference_mol2_filename                  ${system}.lig.python.min.mol2
fps_score_foot_compare_type                                  Euclidean
fps_score_normalize_foot                                     no
fps_score_foot_comp_all_residue                              no
fps_score_choose_foot_range_type                             threshold
fps_score_vdw_threshold                                      0.5
fps_score_es_threshold                                       0.2
fps_score_hb_threshold                                       0.5
fps_score_use_remainder                                      yes
fps_score_receptor_filename                                  ${rootdir}/${system}/002.rec-prep/${system}.rec.clean.mol2
fps_score_vdw_att_exp                                        6
fps_score_vdw_rep_exp                                        12
fps_score_vdw_rep_rad_scale                                  1
fps_score_use_distance_dependent_dielectric                  yes
fps_score_dielectric                                         4.0
fps_score_vdw_fp_scale                                       1
fps_score_es_fp_scale                                        1
fps_score_hb_fp_scale                                        0
pharmacophore_score_secondary                                no
descriptor_score_secondary                                   no
gbsa_zou_score_secondary                                     no
gbsa_hawkins_score_secondary                                 no
SASA_score_secondary                                         no
amber_score_secondary                                        no
minimize_ligand                                              no
atom_model                                                   all
vdw_defn_file                                                ${paramdir}/vdw_AMBER_parm99.defn
flex_defn_file                                               ${paramdir}/flex.defn
flex_drive_file                                              ${paramdir}/flex_drive.tbl
ligand_outfile_prefix                                        output
write_footprints                                             yes
write_hbonds                                                 no
write_orientations                                           no
num_scored_conformers                                        1
rank_ligands                                                 no
EOF
#################################################
echo "Create primary residues dat file"

${dockdir}/dock6 -i ${system}.footprint_rescore.in -o ${system}.footprint_rescore.out
cp ${system}.footprint_rescore.out footprint_rescore.out

###########################################################################################

grep -A 1 "range_union" footprint_rescore.out | grep -v "range_union" | grep -v "\-" | sed -e '{s/,/\n/g}' | sed -e '{s/ //g}' |  sed '/^$/d' | sort -n | uniq > temp.dat

for i in `cat temp.dat`; do
	printf "%0*d\n" 3 $i >> primary_residues.dat
done

for r in `cat temp.dat`; do
        grep " $r " output_footprint_scored.txt  | awk -v temp=$r '{if ($2 == temp) print $0;}' | awk '{print $1 "  " $3 "  " $4}' >> reference.txt
done

grep "remainder" output_footprint_scored.txt | sed -e '{s/,/  /g}' | tr -d '\n' | awk '{print $2 "  " $3 "  " $6}' >> reference.txt

rm temp.dat
cp output_footprint_scored.txt ${system}.footprint.txt
#EOF
###########################################################################################

cp primary_residues.dat ${system}.primary_residues.dat
mv reference.txt ${system}.reference.txt

echo "Minimizing reference ligand in gridspace..."
### DOCK input file for minimizing on grid
###########################################################################################
cat  >${system}.reference_gridmin.in <<EOF
conformer_search_type                                        rigid
use_internal_energy                                          yes
internal_energy_rep_exp                                      12
ligand_atom_file                                             ${rootdir}/${system}/004.multigrids/${system}.lig.python.min.mol2
limit_max_ligands                                            no
skip_molecule                                                no
read_mol_solvation                                           no
calculate_rmsd                                               yes
use_rmsd_reference_mol                                       yes
rmsd_reference_filename                                      ${rootdir}/${system}/004.multigrids/${system}.lig.python.min.mol2
use_database_filter                                          no
orient_ligand                                                no
bump_filter                                                  no
score_molecules                                              yes
contact_score_primary                                        no
contact_score_secondary                                      no
grid_score_primary                                           yes
grid_score_secondary                                         no
grid_score_rep_rad_scale                                     1
grid_score_vdw_scale                                         1
grid_score_es_scale                                          1
grid_score_grid_prefix                                       ${rootdir}/${system}/004.grid/${system}.rec
multigrid_score_secondary                                    no
dock3.5_score_secondary                                      no
continuous_score_secondary                                   no
footprint_similarity_score_secondary                         no
descriptor_score_secondary                                   no
gbsa_zou_score_secondary                                     no
gbsa_hawkins_score_secondary                                 no
SASA_descriptor_score_secondary                              no
amber_score_secondary                                        no
minimize_ligand                                              yes
simplex_max_iterations                                       1000
simplex_tors_premin_iterations                               0
simplex_max_cycles                                           1
simplex_score_converge                                       0.1
simplex_cycle_converge                                       1.0
simplex_trans_step                                           1.0
simplex_rot_step                                             0.1
simplex_tors_step                                            10.0
simplex_random_seed                                          0
simplex_restraint_min                                        yes
simplex_coefficient_restraint                                10.0
atom_model                                                   all
vdw_defn_file                                                ${paramdir}/vdw_AMBER_parm99.defn
flex_defn_file                                               ${paramdir}/flex.defn
flex_drive_file                                              ${paramdir}/flex_drive.tbl
ligand_outfile_prefix                                        grid_output
write_orientations                                           no
num_scored_conformers                                        1
rank_ligands                                                 no
EOF
###########################################################################################

echo "Execute dock on the headnode"
${dockdir}/dock6 -i ${system}.reference_gridmin.in -o ${system}.reference_gridmin.out
mv grid_output_scored.mol2 ${system}.lig.gridmin.mol2

echo "Grid input file for multi-grid"
###########################################################################################
cat >${system}.multigrid.in <<EOF
compute_grids                  yes
grid_spacing                   0.3
output_molecule                yes
contact_score                  no
chemical_score                 no
energy_score                   yes
energy_cutoff_distance         999
atom_model                     a
attractive_exponent            ${attractive}
repulsive_exponent             ${repulsive}
distance_dielectric            yes
dielectric_factor              4
bump_filter                    yes
bump_overlap                   0.75
receptor_file                  temp.mol2
box_file                       ./box.pdb
vdw_definition_file            ./vdw.defn
chemical_definition_file       ./chem.defn
score_grid_prefix              temp.rec
receptor_out_file              temp.rec.grid.mol2
EOF
###########################################################################################

num_of_grids=`wc -l ../004.multigrids/${system}.primary_residues.dat | awk '{print $1+1}'`

echo "DOCK input file for minimizing on multi-grids"
###########################################################################################
cat >${system}.reference_multigridmin.in <<EOF
conformer_search_type                                        rigid
use_internal_energy                                          yes
internal_energy_rep_exp                                      12
ligand_atom_file                                             ${rootdir}/${system}/004.multigrids/${system}.lig.python.min.mol2 
limit_max_ligands                                            no
skip_molecule                                                no
read_mol_solvation                                           no
calculate_rmsd                                               yes
use_rmsd_reference_mol                                       yes
rmsd_reference_filename                                      ${rootdir}/${system}/004.multigrids/${system}.lig.python.min.mol2
use_database_filter                                          no
orient_ligand                                                no
bump_filter                                                  no
score_molecules                                              yes
contact_score_primary                                        no
contact_score_secondary                                      no
grid_score_primary                                           no
grid_score_secondary                                         no
multigrid_score_primary                                      yes
multigrid_score_secondary                                    no
multigrid_score_rep_rad_scale                                1
multigrid_score_vdw_scale                                    1
multigrid_score_es_scale                                     1
multigrid_score_number_of_grids                              ${num_of_grids}
EOF
############################################################################################

        counter="0"

for residue in `cat ../004.multigrids/${system}.primary_residues.dat`;do 
        
###########################################################################################
cat  >>${system}.reference_multigridmin.in<<EOF
multigrid_score_grid_prefix${counter}                                 ${rootdir}/${system}/004.multigrids/${system}.resid_${residue}
EOF
###########################################################################################

	counter=$((counter+1)) 
	done


###########################################################################################
cat  >>${system}.reference_multigridmin.in<<EOF
multigrid_score_grid_prefix${counter}                        ${rootdir}/${system}/004.multigrids/${system}.resid_remaining
multigrid_score_fp_ref_mol                                   yes
multigrid_score_fp_ref_text                                  no
multigrid_score_footprint_ref                                ${rootdir}/${system}/004.multigrids/${system}.lig.python.min.mol2
multigrid_score_foot_compare_type                            Euclidean
multigrid_score_use_euc                                      yes
multigrid_score_normalize_foot                               no
multigrid_score_use_cor                                      no
multigrid_score_vdw_euc_scale                                1
multigrid_score_es_euc_scale                                 1
dock3.5_score_secondary                                      no
continuous_score_secondary                                   no
footprint_similarity_score_secondary                         no
descriptor_score_secondary                                   no
gbsa_zou_score_secondary                                     no
gbsa_hawkins_score_secondary                                 no
SASA_descriptor_score_secondary                              no
amber_score_secondary                                        no
minimize_ligand                                              yes
simplex_max_iterations                                       1000
simplex_tors_premin_iterations                               0
simplex_max_cycles                                           1
simplex_score_converge                                       0.1
simplex_cycle_converge                                       1.0
simplex_trans_step                                           1.0
simplex_rot_step                                             0.1
simplex_tors_step                                            10.0
simplex_random_seed                                          0
simplex_restraint_min                                        yes
simplex_coefficient_restraint                                5.0
atom_model                                                   all
vdw_defn_file                                                ${paramdir}/vdw_AMBER_parm99.defn
flex_defn_file                                               ${paramdir}/flex.defn
flex_drive_file                                              ${paramdir}/flex_drive.tbl
ligand_outfile_prefix                                        output
write_orientations                                           no
num_scored_conformers                                        1
rank_ligands                                                 no
EOF
###########################################################################################

primary_res=` cat ../004.multigrids/${system}.primary_residues.dat | sed -e 's/\n/ /g'`
echo ${primary_res}

echo "python script"
python ${scriptdir}/multigrid_fp_gen.py ${rootdir}/${system}/002.rec-prep/${system}.rec.clean.mol2 ${system}.resid ${system}.multigrid.in ${primary_res}

rm ${system}.resid*.rec.grid.mol2
rm temp.mol2
echo "succesful completion"
