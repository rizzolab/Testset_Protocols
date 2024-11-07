***1P44 and 3LSY have bonds in NAD cofactor which are changed when writing out cof.am1bcc.mol2. You must manually change the ring back to being fully aromatic instead of partially aromatic prior to run.002.
***1H1D SAM cofactor appears to have similar issue as NAD

#Removed Systems
3BKL was a previous DUDE implementation, which succesfully built once, but is no longer successfully building spheres. It was a DUDE system.

1NJS has incorrect geometry on structure. It should have two aliphatic amines according to 2D structure, but the geometry is planar in the structure. It was a DUDE system

1A8I has nonstandard covalent cofactor "LLP" near ligand in active site, no possible standard substitution for LLP, unless we made it a noncovalent cofactor for the grid but its best just to reject this system

1R9O was a DUDE system which was introduced, but removed in PDB for unclear reason
#Notes
CPC 4/4/23
Added nonstandard residues which are recognized by amber (ASH) and mutations to nearby residues encountered in the SB testset
in fix_nonstandard_residues script
- in zzz.parameters y2p files had to change O1P to O1Z
