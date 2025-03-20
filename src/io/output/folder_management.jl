"""
    convergence_create_subdirectories(param::AbstractString, param_range::AbstractArray; path::AbstractString="./", verbose::Bool=false, method::AbstractString="none")

Create subdirectories for convergence testing by varying a specified parameter and copying the necessary VASP input files.

# Arguments
- `param::AbstractString`: The parameter to vary for convergence testing (e.g., "ENCUT", "kgrid").
- `param_range::AbstractArray`: An array of values for the specified parameter.
- `path::AbstractString`: The base path where the subdirectories will be created. Default is `"./"`.
- `verbose::Bool`: A boolean flag indicating whether to print detailed information during execution. Default is `false`.
- `method::AbstractString`: The method to use for k-point grid generation. Can be `"none"`, `"gamma"`, or `"monkhorst"`. Default is `"none"`.
"""
function convergence_create_subdirectories(param, param_range; path="./", verbose=false, method="none", incar="INCAR", potcar="POTCAR", kpoints="KPOINTS", poscar="POSCAR", include_files=String[])
    files = [poscar, potcar, incar, kpoints]
    include = get_include(include_files)
    for value in param_range
        folder = param*"_"*value
        mkpath(joinpath(path, folder))
        if param == "kgrid"
            N = parse(Int64, value)
            gamma_centered = lowercase(method[1]) == 'm' ? false : true
            copy_vasp_input(path, folder, files, ignore=["KPOINTS"], include=include)
            write_kpoints(N, gamma_centered=gamma_centered, out=joinpath(path, folder, "KPOINTS"))
        else
            copy_vasp_input(path, folder, files, ignore=["INCAR"], include=include)
            set_key_in_incar(param, value, joinpath(path, incar), out=joinpath(path, folder, incar), verbose=verbose)
        end
    end
end

"""
    nscf_create_subdirectories(path::String, kpoints::String, incar::String; verbose::Bool=false)

Create and configure subdirectories for SCF and NSCF calculations by copying and modifying VASP input files.

# Arguments
- `path::String`: The base directory where the SCF and NSCF subdirectories will be created. This should be a full or relative path ending with a slash (`/`).
- `kpoints::String`: A comma-separated string specifying the `KPOINTS` files for the SCF and NSCF calculations. If a single file is provided, it will be used for both SCF and NSCF calculations.
- `incar::String`: A comma-separated string specifying the `INCAR` files for the SCF and NSCF calculations. If a single file is provided, it will be used for both SCF and NSCF calculations.

# Keyword Arguments
- `verbose::Bool`: If `true`, the function will print additional information during the process. Defaults to `false`.

# Description
The function creates two subdirectories, `scf` and `nscf`, within the specified `path`. It copies VASP input files from the `path` directory into these subdirectories with the following process:
1. `KPOINTS` and `INCAR` files are specified via the `kpoints` and `incar` arguments. These files are split into two lists (if provided as a comma-separated string), one for the SCF calculation and one for the NSCF calculation.
2. The function calls `copy_vasp_input` to copy standard VASP input files into each subdirectory, using the specified `KPOINTS` and `INCAR` files.
3. The `INCAR` files in each subdirectory are then modified:
    - For the SCF subdirectory:
      - `ISTART` is set to `"0"`.
      - `LCHARG` is set to `"True"`.
    - For the NSCF subdirectory:
      - `ISTART` is removed.
      - `ICHARG` is set to `"11"`.
      - `LCHARG` is set to `"False"`.
"""
function nscf_create_subdirectories(path, kpoints, incar; verbose=false)
    folders = ["scf", "nscf"]
    kpoint_files = split_line(kpoints, char=','); if length(kpoint_files) == 1; append!(kpoint_files, kpoint_files); end
    incar_files = split_line(incar, char=','); if length(incar_files) == 1; append!(incar_files, incar_files); end
    for (k, folder) in enumerate(folders)
        mkdir(joinpath(path, folder))
        copy_vasp_input(path, folder, ignore=["KPOINTS", "INCAR"], include=[kpoint_files[k]=>"KPOINTS", incar_files[k]=>"INCAR"])
    end
    scf_incar = joinpath(path, "scf/INCAR")
    set_key_in_incar(["ISTART", "LCHARG"], ["0", "True"], scf_incar, verbose=verbose)

    nscf_incar = joinpath(path, "nscf/INCAR")
    remove_key_from_incar("ISTART", nscf_incar, verbose=verbose)
    set_key_in_incar(["ICHARG", "LCHARG"], ["11", "False"], nscf_incar, verbose=verbose)
end

"""
    supercell_create_subdirectories(path, xdatcar_path, N; method="random", Nmin=1)

Create subdirectories for supercell configurations extracted from an XDATCAR file.

# Arguments
- `path::String`: The directory path where subdirectories will be created.
- `xdatcar_path::String`: The file path to the XDATCAR file containing atomic configurations.
- `N::Int`: The number of configurations to extract and create subdirectories for.
- `method::String="random"`: The method for selecting configurations. "random" selects configurations randomly,
  while "uniform" selects them evenly spaced along the XDATCAR trajectory.
- `Nmin::Int=1`: The minimum index of configurations to consider. Defaults to 1.
"""
function supercell_create_subdirectories(path, xdatcar_path, N; method="random", Nmin=1, potcar="POTCAR", kpoints="KPOINTS", incar="INCAR", include_files=String[])
    xdatcar = read_xdatcar(xdatcar_path)
    lattice, configs = xdatcar.lattice, xdatcar.positions
    Nmax = size(configs, 3)
    inds = lowercase(method[1]) == 'u' ? floor.(Int64, LinRange(Nmin, Nmax, N)) : sample(Nmin:Nmax, N, replace=false, ordered=true)
    write_to_file(inds, joinpath(path, "config_inds"))
    include = get_include(include_files)
    files = [incar, potcar, kpoints]
    for (k, ind) in enumerate(inds)
        mkdir(joinpath(path, "config_$k"))
        new_poscar = Structure(1, lattice, xdatcar.atom_names, xdatcar.atom_numbers, configs[:, :, ind], xdatcar.atom_types)
        write_poscar(new_poscar, filename=joinpath(path, "config_$k/POSCAR"))
        copy_vasp_input(path, "config_$k", ignore=["POSCAR"], include=[potcar=>"POTCAR", kpoints=>"KPOINTS", incar=>"INCAR"])
    end
end

"""
copy_vasp_input(path::String, folder::String; ignore::Vector{String}=String[], include::Vector{Pair{String, String}}=Pair{String, String}[])

Copy VASP input files from a specified directory to a target folder, with options to ignore or rename specific files.

# Arguments
- `path::String`: The source directory where the VASP input files are located. This should be the full or relative path ending with a slash (`/`).
- `folder::String`: The target directory where the files should be copied. This should be a relative path from `path` or an absolute path.

# Keyword Arguments
- `ignore::Vector{String}`: A list of file names to ignore during the copying process. Defaults to an empty list.
- `include::Vector{Pair{String, String}}`: A list of pairs specifying additional files to include in the copying process, where the first element is the source file name and the second is the target file name in the destination folder. Defaults to an empty list.

"""
function copy_vasp_input(path, folder, files=["KPOINTS", "POTCAR", "POSCAR", "INCAR"]; ignore=String[], include=Pair{String, String}[])
    # Filter files that are in the ignore list
    filter!(file->file ∉ ignore, files)

    # Filter files that are added via the include list
    filter!(file->file ∉ [b for (_, b) in include], files)

    infiles = vcat(files, [a for (a, _) in include])
    outfiles = vcat(files, [b for (_, b) in include])
    for (infile, outfile) in zip(infiles, outfiles)
        if !isfile(joinpath(path, infile))
            @info "$infile file was not found in current path ($path)."
        elseif isfile(joinpath(path, infile))
            cp(joinpath(path, infile), joinpath(path, folder, "$outfile"), force=true)
        end
    end
end

get_include(include_files) = [file=>file for file in include_files]

"""
    split_path_at_folder(path::String, folder::String) -> String

Split a path at the first occurrence of a specified folder name and return the remaining path after that folder.

# Arguments
- `path::String`: The full path to split.
- `folder::String`: The folder name at which to split the path.

# Returns
- A `String` representing the portion of the path following the specified folder name. If the folder is the last element, an empty string is returned.
"""
function split_path_at_folder(path, folder)
    segments = split_line(path, char='/')
    index = findfirst(seg -> occursin(folder, seg), segments)
    if index === nothing
        error("Folder name '$folder' not found in the path '$path'")
    elseif index ≤ length(segments) - 1
        return joinpath(segments[index+1:end]...)
    else
        return ""
    end
end

"""
    strong_scaling_create_subdirectories_VASP(kpar_range::AbstractArray,
                                              ncore_nsim_range::AbstractArray;
                                              path::String="./",
                                              verbose::Bool=true,
                                              keyword::String="cpu",
                                              time::Int=1,
                                              avail_cpus_per_node::Int=1,
                                              avail_gpus_per_node::Int=1,
                                              module_paths::AbstractArray=[],
                                              module_list::AbstractArray=[],
                                              exe::String="vasp_std",
                                              partition::String="batch",
                                              omp_num_threads::Int=0,
                                              mail::String="",
                                              script_filename::String="jobscript",
                                              sub_directory_name::String="strong_scaling"
                                              )

Creates subdirectories and prepares input files for strong scaling tests in VASP simulations.

# Arguments
- `kpar_range::AbstractArray`: An array of `KPAR` values to be tested.
- `ncore_nsim_range::AbstractArray`: A corresponding array of `NCORE` (for CPU) or `NSIM` (for GPU) values to be tested.

# Keyword Arguments
- `path::String="./"`: Base directory containing the input files (`KPOINTS`, `POTCAR`, `POSCAR`).
- `verbose::Bool=true`: If `true`, enables verbose INCAR manipulation output.
- `keyword::String="cpu"`: Specifies the type of scaling test (`"cpu"` or `"gpu"`).
- `time::Int=1`: Wall time limit for the SLURM job scripts (in hours).
- `avail_cpus_per_node::Int=2`: Number of CPUs available per compute node.
- `avail_gpus_per_node::Int=4`: Number of GPUs available per compute node.
- `module_paths::AbstractArray=[]`: List of module paths to be loaded.
- `module_list::AbstractArray=[]`: List of modules required for the job.
- `exe::String="vasp_std"`: VASP executable command.
- `partition::String="batch"`: SLURM partition name.
- `omp_num_threads::Int=0`: Number of OpenMP threads ('0' -> not set;  fall back to VASP recommendation).
- `mail::String=""`: Email address for SLURM job notifications.
- `script_filename::String="jobscript"`: Name of the SLURM script file.
- `sub_directory_name::String="strong_scaling"`: Base name for created subdirectories.

# Throws
- `ArgumentError`: If `keyword` is not `"cpu"` or `"gpu"`.
- `AssertionError`: If `kpar_range` and `ncore_nsim_range` do not have the same length.
- `SystemError`: If required input files (`KPOINTS`, `POTCAR`, `POSCAR`) are missing in the specified path.

# Example
```julia
strong_scaling_create_subdirectories_VASP(
    kpar_range=[1, 2, 4],
    ncore_nsim_range=[8, 4, 2],
    path="./",
    verbose=true,
    keyword="cpu",
    time=1,
    avail_gpus_per_node=4,
    avail_cpus_per_node=2
)
"""
function strong_scaling_create_subdirectories_VASP(kpar_range::AbstractArray,
                                                   ncore_nsim_range::AbstractArray;
                                                   path::String = "",
                                                   verbose::Bool = true,
                                                   keyword::String = "",
                                                   time::Int = 1,
                                                   avail_cpus_per_node::Int = 1,
                                                   avail_gpus_per_node::Int = 1,
                                                   module_paths::AbstractArray = [],
                                                   module_list::AbstractArray = [],
                                                   exe::String = "vasp_std",
                                                   partition::String = "batch",
                                                   omp_num_threads::Int = 0,  # '0' -> not set; fall back to VASP recommendation
                                                   mail::String = "",
                                                   script_filename::String = "jobscript",
                                                   sub_directory_name::String = "strong_scaling"
                                                   )
    if keyword ∉ ["cpu", "gpu"]; throw("Scaling tests for $keyword are not supported"); end
    @assert length(kpar_range) == length(ncore_nsim_range)
    for (i, kpar, ncore_nsim) in zip(collect(1:length(kpar_range)), kpar_range, ncore_nsim_range)
        folder = "$(sub_directory_name)_$(i)_"*keyword*"/"
        mkpath(path*folder)
        copy_vasp_input(path, folder)
        set_key_in_incar("KPAR", string(kpar), path*"INCAR", out=path*folder*"INCAR", verbose=verbose)
        if keyword == "cpu"
            # if omp_num_threads is default, set to 1 for correct scaling tests
            omp_num_threads = omp_num_threads == 0 ? 1 : omp_num_threads
            set_key_in_incar("NCORE", string(ncore_nsim), path*folder*"INCAR", verbose=verbose)
            write_slurm_script(exe, path*folder;  module_paths=module_paths, module_list=module_list,
                               time=time, nodes=ceil(Int, kpar / avail_cpus_per_node), ntasks_per_node=kpar*24, ntasks_per_core=1,
                               omp_num_threads=omp_num_threads, num_gpu=0, partition=partition, mail=mail, filename=script_filename)
        elseif keyword == "gpu"
            # if omp_num_threads is default, set to 20 * number of avail gpus per node (vasp recommendation)
            omp_num_threads = omp_num_threads == 0 ? 20 * avail_cpus_per_node : omp_num_threads
            set_key_in_incar("NSIM", string(ncore_nsim), path*folder*"INCAR", verbose=verbose, block_label=get_block_label_for_keyword("KPAR"))
            write_slurm_script(exe, path*folder;  module_paths=module_paths, module_list=module_list,
                               time=time, nodes=ceil(Int, kpar / avail_gpus_per_node), ntasks_per_node=kpar, num_gpu=kpar,
                               omp_num_threads=omp_num_threads, partition=partition,
                               mail=mail, filename=script_filename)
        end
    end
end