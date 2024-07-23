# See https://www.vasp.at/wiki/index.php/The_VASP_Manual
INCAR_COMMENTS = Dict{String, String}(
    "ENCUT" => "ENCUT specifies the energy cutoff for the plane-wave basis set in eV.",
    "KPAR" => "KPAR determines the number of k-points that are to be treated in parallel.",
    "NCORE" => "NCORE determines the number of compute cores that work on an individual orbital.",
    "KSPACING" => "The tag KSPACING determines the number of k points if the KPOINTS file is not present.",
    "KGAMMA" => "Determines whether the k-points include the Gamma point.",
    "EDIFF" => "EDIFF specifies the global break condition for the electronic SC-loop in eV.",
)

get_comment(tag) = haskey(INCAR_COMMENTS, tag) ? INCAR_COMMENTS[tag] : ""