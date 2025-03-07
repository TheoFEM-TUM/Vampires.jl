# See https://www.vasp.at/wiki/index.php/The_VASP_Manual

"""
    get_comment(key::String) -> String

Retrieve a comment associated with a given key from the `INCAR_COMMENTS` or `WANNIER90_COMMENTS` dictionaries.

# Arguments
- `key::String`: The key for which to retrieve the comment.

# Returns
- A `String` containing the comment associated with the given key. If the key is found in `INCAR_COMMENTS`, the corresponding comment is returned. If not, the function checks `WANNIER90_COMMENTS`. If the key is not found in either dictionary, an empty string is returned.
"""
function get_comment(key)
    if haskey(INCAR_COMMENTS, key)
        return INCAR_COMMENTS[key]
    elseif haskey(WANNIER90_COMMENTS, key)
        return WANNIER90_COMMENTS[key]
    else
        return ""
    end
end

"""
    get_default_for_keyword(key::String) -> Any

Retrieve the default value associated with a given key from the `VASP_DEFAULTS` or `WANNIER90_DEFAULTS` dictionaries.

# Arguments
- `key::String`: The key for which to retrieve the default value.

# Returns
- The default value associated with the given key. If the key is found in `VASP_DEFAULTS`, the corresponding value is returned. If not, the function checks `WANNIER90_DEFAULTS`. 
If the key is not found in either dictionary, an empty string is returned.
"""
function get_default_for_keyword(key)
    if haskey(VASP_DEFAULTS, key)
        return VASP_DEFAULTS[key]
    elseif haskey(WANNIER90_DEFAULTS, key)
        return WANNIER90_DEFAULTS[key]
    else
        return ""
    end
end


get_keywords_for_block(block_label) = haskey(BLOCK_KEYWORDS, block_label) ? BLOCK_KEYWORDS[block_label] : ""


function get_block_label_for_keyword(keyword)
    for (block_label, block_keywords) in BLOCK_KEYWORDS, block_keyword in block_keywords
        if keyword == block_keyword; return block_label; end
    end
    return "Unknown"
end

const INCAR_COMMENTS = Dict{String, String}(
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
    "WANNIER90_WIN" => "sets the content of the wannier90.win file",
    "MDALGO" => "specifies the molecular-dynamics-simulation protocol",
    "ISYM" => "determines the way VASP treats symmetry",
    "IVDW" => "specifies a vdW dispersion term of the atom-pairwise or many-body type"
)

const VASP_DEFAULTS = Dict{String, String}(
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
    "LWANNIER90_RUN" => "True",
    "LWRITE_UNK" => "False",
    "LWRITE_MMN_AMN" => "True",
    "LWRITE_SPN" => "False",
    "WANNIER90_WIN" => "\"\"",
    "MDALGO" => "0",
    "ISYM" => "2",
    "IVDW" => "0"
)

const WANNIER90_COMMENTS = Dict{String, String}(
    "num_wann" => "defines number of Wannier functions",
    "num_iter" => "sets number of iterations for the minimization of Omega",
    "conv_window" => "sets number of iterations over which convergence of Omega is assessed",
    "conv_tol" => "sets convergence tolerance for finding Omega",
    "dis_win_max" => "defines top of the outer energy window",
    "dis_win_min" => "defines bottom of the outer energy window",
    "dis_froz_max" => "defines top of the inner (frozen) energy window",
    "dis_froz_min" => "defines bottom of the inner (frozen) energy window",
    "dis_num_iter" => "sets number of iterations for the minimization of Omega_I",
    "dis_conv_tol" => "sets the convergence tolerance for finding Omega_I",
    "dis_conv_window" => "sets the number of iterations over which convergence of Omega_I is assessed",
    "write_hr" => "write the Hamiltonian in the WF basis",
    "spinors" => "assumes that each WF corresponds to singularly occupied spinor state",
)

const WANNIER90_DEFAULTS = Dict{String, String}(

)

const BLOCK_KEYWORDS = Dict{String, Vector{String}}(
    "Parallelization" => ["NCORE", "KPAR"],
    "MolecularDynamics" => ["IBRION", "ISIF", "TEBEG", "TEEND", "POTIM", "NSW", "SMASS"],
    "ElectronicConvergence" => ["ENCUT", "ISMEAR", "SIGMA", "EDIFF", "NELMIN", "NELM", "PREC"],
    "Output" => ["NWRITE", "LCHARG", "LWAVE", "LORBIT"],
    "Setup" => ["ISTART", "ICHARG"],
    "Wannier90" => ["NUM_WANN", "LWANNIER90_RUN", "LWANNIER90", "LWRITE_UNK", "LWRITE_MMN_AMN", "LWRITE_SPN"],
    "Disentanglement" => ["dis_num_iter", "dis_win_max", "dis_win_min", "dis_froz_max", "dis_froz_min"],
)