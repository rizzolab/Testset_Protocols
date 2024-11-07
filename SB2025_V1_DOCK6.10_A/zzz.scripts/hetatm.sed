#!/bin/sed -f

# Delete all lines that are not ATOM HETATM or TER
/^ATOM\|^HETATM\|^TER/!d

# Change HETATM to ATOM only if it matches ion atom and residue name
/HETATM.*CA.*CA/{s/HETATM/ATOM  /}
/HETATM.*NA.*NA/{s/HETATM/ATOM  /}
/HETATM.*CL.*CL/{s/HETATM/ATOM  /}
/HETATM.*ZN.*ZN/{s/HETATM/ATOM  /}
/HETATM.*MG.*MG/{s/HETATM/ATOM  /}
/HETATM.*K.*K/{s/HETATM/ATOM  /}

#Do same for HEME cofactor
/HETATM.*HEM/{s/HETATM/ATOM  /}

#Do same for Y2P residue
/HETATM.*Y2P/{s/HETATM/ATOM  /}

# Delete all waters
# /HETATM ....  O   HOH /d

# Delete all remaining HETATM records (usually ligand+waters)
/HETATM/d
