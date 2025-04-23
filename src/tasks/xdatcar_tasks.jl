"""
list of available tasks:


xdatcar:
    read: read the atomic configurations from the XDATCAR file.
    merge: merge multiple XDATCAR into one single file.
"""


"""
# CLI Commands to work with the XDATCAR file

Available commands:
* `vamp xdatcar read`: read the data from the XDATCAR file.
* `vamp xdatcar merge`: merge multiple XDATCAR into one single file.
"""
run_task(::Type{Val{:xdatcar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] xdatcar read [--par <param>] [--xdatcar <file>] [--poscar <file>] [--p <path>] [--o <file>]

Reads atomic configurations from an XDATCAR file and calculates specific properties, such as mean squared displacement (MSD), based on the specified parameter.

# Arguments
- `par`: (Optional) Specifies the property to calculate. Accepted values:
    - `"msd"`: Computes the mean squared displacement (MSD) and its standard deviation relative to the initial atomic positions in the POSCAR file.
    - `"vdos"`: Computes the (mass weighted) vibrational density of states.
- `xdatcar`: (Optional) The name of the XDATCAR file containing atomic configurations from a molecular dynamics simulation.
- `poscar`: (Optional) The name of the POSCAR file containing the initial atomic configuration (required if `par` is `"msd"`).
- `p`: (Optional) The path where the XDATCAR and POSCAR files are located.
- `o`: (Optional) The name of the output file.

# Returns
- If `par` is `"msd"`: Returns MSD and its standard deviation
- Elseif `par` is `"vdos"`: Returns vdos and corresponding frequencies
- Otherwise: Returns the lattice vectors and configurations from the XDATCAR file.

# Examples
```bash
# Example 1: Read atomic configurations and save them to a file
vamp xdatcar read --xdatcar XDATCAR --out configurations.h5

# Example 2: Calculate the MSD for an MD trajectory
vamp xdatcar read --par MSD
```
"""
function run_task(::Type{Val{:xdatcar}}, ::Type{Val{:read}}, args)
    xdatcar = read_xdatcar(joinpath(args["p"], args["xdatcar"]))
    lattice, configs = xdatcar.lattice, xdatcar.positions

    if lowercase(args["par"]) == "msd"
        poscar = read_poscar(joinpath(args["p"], args["poscar"]))
        msd, err = compute_msd(poscar.positions, configs, lattice)
        return (msd = msd, deviation = err)
    elseif lowercase(args["par"]) == "vdos"
        δt = args["N"] == "none" ? read_value_from_outcar("POTIM", args["outcar"]) : parse(Float64, args["N"])
        if !(typeof(δt) <: Number) || δt == 0.0
            println("Please specify a time step larger than 0.0 (you may use '--N'). Exiting...")
            exit()
        end
        v = compute_velocities(xdatcar.positions, δt, xdatcar.lattice)
        ω, S = compute_vdos(v, δt; method="full", atom_names=xdatcar.atom_types)
        return (energy = ustrip.(ω), vdos = ustrip.(S))
    end

    return (lattice = lattice, configs = configs)
end

"""
    vamp [-r] xdatcar merge --xdatcar <file0, file1, ...> --o <file> [--p <path>]

Merges atomic configurations from several XDATCARs in the given order and writes them to an output file.

# Arguments
- `xdatcar`: The name of the XDATCAR files from an molecular dynamics simulation in the order they should be merged.
- `o`: The name of the output file.
- `p`: (Optional) The path where the XDATCAR files are located.

# Examples
```bash
# Example 1: Merge two XDATCAR_* files to a single XDATCAR
vamp xdatcar merge --xdatcar XDATCAR_0-100,XDATCAR_101-200 --out XDATCAR
```
"""
function run_task(::Type{Val{:xdatcar}}, ::Type{Val{:merge}}, args)
    structure_n = read_xdatcar.(joinpath.(args["p"], split(args["xdatcar"], ",")))
    output_filename = args["o"] == "none" ? "XDATCAR_merged" : args["o"]
    open(joinpath(args["p"], output_filename), "w") do file
        write_xdatcar(file, structure_n)
    end
    return nothing
end