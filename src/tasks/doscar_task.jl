"""
list of available tasks:

doscar
    read: read-in the doscar file
    plot: plot the dos from the doscar file
"""


"""
# CLI Commands to work with the DOSCAR file

Available commands:
* `vamp doscar read`: read the doscar file.
* `vamp doscar plot`: plot the dos from the doscar file
"""
run_task(::Type{Val{:doscar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] doscar read [--p <path>] [--doscar <doscar_file>] [--par <parameter>] [--o <output_filename>] [--poscar <poscar_file>] [--incar <incar_file>]

Reads the density of states (DOS) data from a DOSCAR file and writes the results to an HDF5 file if specified.

# Arguments
- `p`: The path to the working directory.
- `doscar`: Path to the DOSCAR file to read from.
- `par`: An optional parameter that specifies what to read from the doscar (e.g., pdos)
- `o`: Output filename where the processed data will be saved.
- `poscar`: Path to the POSCAR file (needed for atom types).
- `incar`: Path to the INCAR file (needed for parameters that affect the (p)dos).

# Examples
```bash
# Example 1: Read DOSCAR data and save it to an HDF5 file.
vamp doscar read --doscar DOSCAR --o dos.h5

# Example 2: Read the pdos from the DOSCAR file and save it to an HDF5 file.
vamp doscar read --par pdos --o pdos.h5
"""
function run_task(::Type{Val{:doscar}}, ::Type{Val{:read}}, args)
    doscar = joinpath(args["p"], args["doscar"])
    dos, _ = read_doscar(doscar)
    dos_keys = ["energy", "total_dos", "integrated_dos"]
    dos_values = [dos[:, 1], dos[:, 2], dos[:, 3]]
    if args["par"] == "pdos"
        # Read atom types from POSCAR
        atom_types = read_poscar(joinpath(args["p"], args["poscar"])).atom_types
        atom_types = add_atom_counts(atom_types)

        # Read relevant INCAR parameters from INCAR
        incar = read_incar(joinpath(args["p"], args["incar"]))
        LORBIT = haskey(incar, "LORBIT") ? parse(Int64, findvalue(incar, "LORBIT")) : 0
        ISPIN = haskey(incar, "ISPIN") ? parse(Int64, findvalue(incar, "ISPIN")) : 1
        LSORBIT = haskey(incar, "LSORBIT") ? parse(Bool, findvalue(incar, "LSORBIT")) : false
        LMAXMIX = haskey(incar, "LMAXMIX") ? parse(Int64, findvalue(incar, "LMAXMIX")) : 2
        orbitals = get_pdos_orbital_list(LORBIT=LORBIT, ISPIN=ISPIN, LSORBIT=LSORBIT, LMAXMIX=LMAXMIX)

        _, pdos, _ = read_doscar_with_pdos(doscar)
        for (i, type) in enumerate(atom_types), (j, orbital) in enumerate(orbitals)
            dos_output[] = pdos[i][1+j, :]
            push!(dos_keys, "$type"*"_"*"$orbital")
            push!(dos_values, pdos[i][1+j, :])
        end
    end
    return NamedTuple(zip(Symbol.(dos_keys), dos_values))
end

"""
    vamp doscar plot [--p <path>] [--doscar <file>] [--o <output_filename>]

Reads the density of states (DOS) data from a DOSCAR file and generates a plot of the DOS.

# Arguments
- `p`: Path to the directory containing the DOSCAR file.
- `doscar`: Name of the DOSCAR file to read from.
- `o`: Output filename for the plot (optional). If not specified, the plot is shown but not saved.

# Behavior
- Reads the DOS data from the specified DOSCAR file.
- Generates a plot of the density of states (DOS).

# Examples
```bash
# Example 1: Plot DOS data from a DOSCAR file and save it to an image file.
vamp doscar plot --p /path/to/files --doscar DOSCAR --o dos_plot
"""
function run_task(::Type{Val{:doscar}}, ::Type{Val{:plot}}, args)
    input_filename = args["p"] * args["doscar"]
    dos, _ = read_doscar(input_filename)
    plot_dos(dos, args["o"])
end