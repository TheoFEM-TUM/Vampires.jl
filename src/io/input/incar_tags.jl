# See https://www.vasp.at/wiki/index.php/The_VASP_Manual

get_comment(tag) = haskey(INCAR_COMMENTS, tag) ? INCAR_COMMENTS[tag] : ""
get_keywords_for_block(block_label) = haskey(BLOCK_KEYWORDS, block_label) ? BLOCK_KEYWORDS[block_label] : ""
get_default_for_keyword(keyword) = haskey(VASP_DEFAULTS, keyword) ? VASP_DEFAULTS[keyword] : ""
function get_block_label_for_keyword(keyword)
    for (block_label, block_keywords) in BLOCK_KEYWORDS, block_keyword in block_keywords
        if keyword == block_keyword; return block_label; end
    end
    return "Unkown"
end

INCAR_COMMENTS = Dict{String, String}(
    "ENCUT" => "specifies the energy cutoff for the plane-wave basis set in eV",
    "KPAR" => "determines the number of k-points that are to be treated in parallel",
    "NCORE" => "determines the number of compute cores that work on an individual orbital",
    "KSPACING" => "determines the number of k points if the KPOINTS file is not present",
    "KGAMMA" => "determines whether the k-points include the Gamma point",
    "EDIFF" => "specifies the global break condition for the electronic SC-loop in eV",
    "POTIM" => "sets the time step in molecular dynamics or the step width in ionic relaxations",
    "IBRION" => "determines how the ions are updated and moved",
    "NSW" => "sets the maximum number of ionic steps",
    "ISIF" => "determines if the stress tensor is calculated and which ionic degrees of freedom are varied",
    "PREC" => "specifies the \"precision\" mode",
    "LREAL" => "determines whether the projection operators are evaluated in real-space or in reciprocal space",
    "ALGO" => "specifies the electronic minimization algorithm and/or selects the type of GW calculations",
    "IALGO" => "selects the algorithm to optimize the orbitals",
    "NSIM" => "sets the number of bands that are optimized simultaneously by the RMM-DIIS algorithm",
    "LDIAG" => "determines whether a subspace diagonalization is performed or not within the main algorithm (ALGO or IALGO)",
    "LPLANE" => "switches on the plane-wise data distribution in real space",
    "ISPIN" => "specifies spin polarization",
    "MAGMOM" => "sets initial magnetic moment for each atom if no magnetization density is present",
    "ISTART" => "determines whether or not to read the WAVECAR file",
    "ICHARG" => "determines how VASP constructs the initial charge density",
    "IWAVPR" => "determines how orbitals and/or charge densities are extrapolated from one ionic configuration to the next configuration",
    "LMAXMIX" => "controls maximum l for one-center PAW charge densities",
    "ISMEAR" => "determines how the partial occupancies fnk are set for each orbital",
    "SIGMA" => "specifies the width of the smearing in eV",
    "TEBEG" => "sets the starting temperature (in K) for an ab-initio molecular dynamics run and other routines",
    "TEEND" => "sets the final temperature (in K) for an ab-initio molecular-dynamics run",
    "SMASS" => "controls the velocities during an ab-initio molecular-dynamics run",
    "NWRITE" => "determines how much will be written to the file OUTCAR",
    "LCHARG" => "determines whether the charge densities (CHGCAR and CHG) are written",
    "LWAVE" => "determines whether the wavefunctions are written to the WAVECAR file at the end of a run",
    "NELM" => "sets the maximum number of electronic SC (self-consistency) steps",
    "NELMIN" => "specifies the minimum number of electronic self-consistency steps",
    "LORBIT" => "selects a projection method onto local quantum numbers and writes PROCAR/PROOUT file",
    "LSORBIT" => "switch on spin-orbit coupling",
    "NUM_WANN" => "controls the number of Wannier orbitals to be constructed",
    "LWANNIER90" => "switches on the interface between VASP and WANNIER90",
    "LWANNIER_RUN" => "executes wannier_setup and subsequently runs WANNIER90 in library mode",
    "LWRITE_UNK" => "decides whether the cell-periodic part of the relevant Bloch functions is written",
    "LWRITE_MMN_AMN" => "write the wannier90.mmn and wannier90.amn files",
    "LWRITE_SPN" => "Write wannier90.spn file for noncollinear calculations",
    "WANNIER90_WIN" => "sets the content of the wannier90.win file"
)

VASP_DEFAULTS = Dict{String, String}(
    "ENCUT" => "250",
    "KPAR" => "1",
    "NCORE" => "1",
    "KSPACING" => "0.5",
    "KGAMMA" => "true",
    "EDIFF" => "1e-4",
    "POTIM" => "0.5",
    "IBRION" => "0",
    "NSW" => "0",
    "ISIF" => "2",
    "PREC" => "Normal",
    "LREAL" => "False",
    "ALGO" => "Normal",
    "IALGO" => "38",
    "NSIM" => "4",
    "LDIAG" => "True",
    "LPLANE" => "True",
    "ISPIN" => "1",
    "MAGMOM" => "NONE",
    "ISTART" => "0",
    "ICHARG" => "2",
    "IWAVPR" => "0",
    "LMAXMIX" => "2",
    "ISMEAR" => "1",
    "SIGMA" => "0.2",
    "TEBEG" => "0",
    "TEEND" => "0",
    "SMASS" => "-3",
    "NWRITE" => "2",
    "LCHARG" => "True",
    "LWAVE" => "True",
    "NELM" => "60",
    "NELMIN" => "2",
    "LORBIT" => "0",
    "LSORBIT" => "False",
    "NUM_WANN" => "0",
    "LWANNIER90" => "False",
    "LWANNIER_RUN" => "True",
    "LWRITE_UNK" => "False",
    "LWRITE_MMN_AMN" => "True",
    "LWRITE_SPN" => "False",
    "WANNIER90_WIN" => "\"\""
)

BLOCK_KEYWORDS = Dict{String, Vector{String}}(
    "Parallelization" => ["NCORE", "KPAR"],
    "MolecularDynamics" => ["IBRION", "ISIF", "TEBEG", "TEEND", "POTIM", "NSW", "SMASS"],
    "ElectronicConvergence" => ["ISMEAR", "SIGMA", "EDIFF", "NELMIN", "NELM", "PREC"],
    "Output" => ["NWRITE", "LCHARG", "LWAVE", "LORBIT"],
    "Setup" => ["ISTART", "ICHARG"],
    "Wannier90" => ["NUM_WANN", "LWANNIER_RUN", "LWANNIER90", "LWRITE_UNK", "LWRITE_MMN_AMN", "LWRITE_SPN"],
)