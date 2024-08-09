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
function convergence_create_subdirectories(param, param_range; path="./", verbose=false, method="none")
    for value in param_range
        folder = param*"_"*value
        mkpath(path*folder)
        if param == "kgrid"
            N = parse(Int64, value)
            gamma_centered = lowercase(method[1]) == 'm' ? false : true
            write_kpoints(N, gamma_centered=gamma_centered, out=path*folder*"/KPOINTS")
            copy_vasp_input(path, folder, ignore=["KPOINTS"])
        else
            copy_vasp_input(path, folder, ignore=["INCAR"])
            set_key_in_incar(param, value, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
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
        mkdir(path*folder)
        copy_vasp_input(path, folder, ignore=["KPOINTS", "INCAR"], include=[kpoint_files[k]=>"KPOINTS", incar_files[k]=>"INCAR"])
    end

    set_key_in_incar("ISTART", "0", path*"scf/INCAR", verbose=verbose)
    set_key_in_incar("LCHARG", "True", path*"scf/INCAR", verbose=verbose)

    remove_key_from_incar("ISTART", path*"nscf/INCAR", verbose=verbose)
    set_key_in_incar("ICHARG", "11", path*"nscf/INCAR", verbose=verbose)
    set_key_in_incar("LCHARG", "False", path*"nscf/INCAR", verbose=verbose)
end

"""
    supercell_create_subdirectories(path, xdatcar_path, poscar_path, N; method="random", Nmin=1)

Create subdirectories for supercell configurations extracted from an XDATCAR file.

# Arguments
- `path::String`: The directory path where subdirectories will be created.
- `xdatcar_path::String`: The file path to the XDATCAR file containing atomic configurations.
- `poscar_path::String`: The file path to the POSCAR file containing lattice information and atomic positions.
- `N::Int`: The number of configurations to extract and create subdirectories for.
- `method::String="random"`: The method for selecting configurations. "random" selects configurations randomly,
  while "equal" selects them evenly spaced along the XDATCAR trajectory.
- `Nmin::Int=1`: The minimum index of configurations to consider. Defaults to 1.
"""
function supercell_create_subdirectories(path, xdatcar_path, poscar_path, N; method="random", Nmin=1)
    poscar = read_poscar(poscar_path)
    lattice, configs = read_xdatcar(xdatcar_path)
    Nmax = size(configs, 3)
    inds = lowercase(method[1]) == 'e' ? floor.(Int64, LinRange(Nmin, Nmax, N)) : sample(Nmin:Nmax, N, replace=false, ordered=true)
    write_to_file(inds, path*"config_inds")
    for (k, ind) in enumerate(inds)
        mkdir(path*"snap_$k")
        new_poscar = Poscar(1, lattice, poscar.atom_names, poscar.atom_numbers, configs[:, :, ind], poscar.atom_types)
        write_poscar(new_poscar, filename=path*"snap_$k/POSCAR")
        copy_vasp_input(path, "snap_$k", ignore=["POSCAR"])
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
function copy_vasp_input(path, folder; ignore=String[], include=Pair{String, String}[])
    files = ["KPOINTS", "POTCAR", "POSCAR", "INCAR"]
    filter!(file->file ∉ ignore, files)
    infiles = vcat(files, [a for (a, _) in include])
    outfiles = vcat(files, [b for (_, b) in include])
    for (infile, outfile) in zip(infiles, outfiles)
        if !isfile(path*infile)
            @info "$infile file was not found in current path ($path)."
        elseif isfile(path*infile)
            cp(path*infile, path*folder*"/$outfile", force=true)
        end
    end
end


"""
    strong_scaling_create_subdirectories(kpar_range::AbstractArray, ncore_nsim_range::AbstractArray;
                                         path::String="./", verbose::Bool=true, keyword::String="CPU", 
                                         time::Int=1, avail_gpus_per_node::Int=4, avail_cpus_per_node::Int=2)

Create subdirectories and prepare input files for strong scaling tests for VASP simulations.

# Arguments
- `kpar_range::AbstractArray`: An array of KPAR values to be tested.
- `ncore_nsim_range::AbstractArray`: A corresponding array of NCORE (for CPU) or NSIM (for GPU) values to be tested.
- `path::String="./"`: The base directory where the input files (`KPOINTS`, `POTCAR`, `POSCAR`) are located.
- `verbose::Bool=true`: If `true`, enables verbose output for the function calls.
- `keyword::String="CPU"`: Specifies the type of scaling test, either `"CPU"` or `"GPU"`.
- `time::Float64=1.0`: The wall time limit for the SLURM job scripts (in hours).
- `avail_gpus_per_node::Int=4`: The number of GPUs available per compute node.
- `avail_cpus_per_node::Int=2`: The number of CPUs available per compute node.

# Description
This function performs the following steps for each combination of KPAR and NCORE/NSIM values:
1. Creates a directory for the scaling test.
2. Copies the necessary VASP input files (`KPOINTS`, `POTCAR`, `POSCAR`) to the test directory.
3. Modifies the `INCAR` file with the appropriate KPAR and NCORE/NSIM values.
4. Writes a SLURM batch job script tailored to either CPU or GPU runs, based on the `keyword` parameter.

# Throws
- `ArgumentError`: If `keyword` is not `"CPU"` or `"GPU"`.
- `AssertionError`: If `kpar_range` and `ncore_nsim_range` do not have the same length.
- `SystemError`: If the required input files (`KPOINTS`, `POTCAR`, `POSCAR`) are not found in the base path.

# Example
```julia
strong_scaling_create_subdirectories(
    kpar_range=[1, 2, 4],
    ncore_nsim_range=[8, 4, 2],
    path="./",
    verbose=true,
    keyword="CPU",
    time=1,
    gpus_per_node=4,
    cpus_per_node=2
)
"""
function strong_scaling_create_subdirectories(kpar_range::AbstractArray,
                                              ncore_nsim_range::AbstractArray;
                                              path::String = "",
                                              verbose::Bool = true,
                                              keyword::String = "",
                                              time::Int = 1,
                                              avail_cpus_per_node::Int = 2,
                                              avail_gpus_per_node::Int = 4,
                                              module_path::String = "",
                                              module_list::AbstractArray = [""],
                                              vasp_exe::String = "vasp_exe",
                                              partition::String = "batch",
                                              omp_num_threads::Int = 0,
                                              mail::String = "",
                                              script_filename::String = "batch_jobscript",
                                              sub_directory_name::String = "strong_scaling"
                                             )
    if keyword ∉ ["cpu", "gpu"]; throw("Scaling tests for $keyword are not supported"); end
    @assert length(kpar_range) == length(ncore_nsim_range)
    for (i, kpar, ncore_nsim) in zip(collect(1:length(kpar_range)), kpar_range, ncore_nsim_range)
        folder = "$(sub_directory_name)_$(i)_"*keyword
        mkpath(path*folder)
        copy_vasp_input(path, folder)
        set_key_in_incar("KPAR", string(kpar), path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        if keyword == "cpu"
            # if omp_num_threads is default, set to 1 for correct scaling tests
            omp_num_threads = omp_num_threads == 0 ? 1 : omp_num_threads
            set_key_in_incar("NCORE", string(ncore_nsim), path*folder*"/INCAR", verbose=verbose)
            write_slurm_script(path*folder;  module_path=module_path, module_list=module_list, vasp_exe=vasp_exe,
                               time=time, nodes=ceil(Int, kpar / avail_cpus_per_node), ntasks=kpar*24,
                               num_gpu=0, omp_num_threads=omp_num_threads, partition=partition, mail=mail, script_filename=script_filename)
        elseif keyword == "gpu"
            # if omp_num_threads is default, set to 20 * number of avail gpus per node (vasp recommendation)
            omp_num_threads = omp_num_threads == 0 ? 20 * avail_cpus_per_node : omp_num_threads
            set_key_in_incar("NSIM", string(ncore_nsim), path*folder*"/INCAR", verbose=verbose, block_label=get_block_label_for_keyword("KPAR"))
            write_slurm_script(path*folder;  module_path="", module_list=module_list, vasp_exe=vasp_exe,
                               time=time, nodes=ceil(Int, kpar / avail_gpus_per_node), ntasks=kpar, num_gpu=kpar,
                               omp_num_threads=omp_num_threads, partition=partition,
                               mail=mail, script_filename=script_filename)
        end
    end
end


"""
    weak_scaling_create_subdirectories(kpar_range::AbstractArray,
                                       ncore_nsim_range::AbstractArray;
                                       super_cell_vector::Vector{Int64} = [2,2,2],
                                       path::String = "./",
                                       verbose::Bool = true,
                                       keyword::String = "",
                                       time::Int = 1,
                                       avail_cpus_per_node::Int = 2,
                                       avail_gpus_per_node::Int = 4,
                                       module_path::String = "",
                                       module_list::String = "",
                                       vasp_exe::String = "vasp_exe",
                                       partition::String = "batch",
                                       omp_num_threads::Int = 0,
                                       mail::String = "",
                                       script_filename::String = "batch_jobscript")

Create subdirectories and prepare input files for weak scaling tests for VASP simulations.

# Arguments
- `kpar_range::AbstractArray`: An array of KPAR values to be tested.
- `ncore_nsim_range::AbstractArray`: A corresponding array of NCORE (for CPU) or NSIM (for GPU) values to be tested.
- `super_cell_vector::Vector{Int64} = [2,2,2]`: The vector defining the supercell size for scaling - scaled by a factor of n for the nth test.
- `path::String = "./"`: The base directory where the input files (`KPOINTS`, `POTCAR`, `POSCAR`) are located.
- `verbose::Bool = true`: If `true`, enables verbose output for the function calls.
- `keyword::String = ""`: Specifies `cpu` or `gpu`
- `time::Int = 1`: The wall time limit for the SLURM job scripts (in hours).
- `avail_cpus_per_node::Int = 2`: The number of CPUs available per compute node.
- `avail_gpus_per_node::Int = 4`: The number of GPUs available per compute node.
- `module_path::String = ""`: Path to the module file.
- `module_list::String = ""`: List of modules to load.
- `vasp_exe::String = "vasp_exe"`: The VASP executable to be used.
- `partition::String = "batch"`: The SLURM partition to submit jobs to.
- `omp_num_threads::Int = 0`: Number of OpenMP threads.
- `mail::String = ""`: Email address for SLURM notifications.
- `script_filename::String = "batch_jobscript"`: The filename for the SLURM batch job script.

# Description
This function performs the following steps for each combination of KPAR and NCORE/NSIM values:
1. Calls `strong_scaling_create_subdirectories` to create a strong scaling hierarchy.
2. Modifies the `POSCAR` file according to the scaling parameter.
3. Checks if `KSPACING` is set in the `INCAR` file and prints a message if not.

For each combination of KPAR and NCORE/NSIM, it adjusts the supercell vector and transforms the primitive cell accordingly.

# Throws
- `SystemError`: If the required input files (`KPOINTS`, `POTCAR`, `POSCAR`) are not found in the base path.

# Example
```julia
weak_scaling_create_subdirectories(
    kpar_range=[1, 2, 4],
    ncore_nsim_range=[8, 4, 2],
    super_cell_vector=[2, 2, 2],
    path="./",
    verbose=true,
    keyword="",
    time=1,
    avail_cpus_per_node=2,
    avail_gpus_per_node=4,
    module_path="",
    module_list="",
    vasp_exe="vasp_std",
    partition="batch",
    omp_num_threads=0,
    mail="",
    script_filename="batch_jobscript"
)
"""
function weak_scaling_create_subdirectories(kpar_range::AbstractArray,
                                              ncore_nsim_range::AbstractArray;
                                              super_cell_vector::Vector{Int64} = [2,2,2],
                                              path::String = "./",
                                              verbose::Bool = true,
                                              keyword::String = "",
                                              time::Int = 1,
                                              avail_cpus_per_node::Int = 2,
                                              avail_gpus_per_node::Int = 4,
                                              module_path::String = "",
                                              module_list::AbstractArray = [""],
                                              vasp_exe::String = "vasp_std",
                                              partition::String = "batch",
                                              omp_num_threads::Int = 0,
                                              mail::String = "",
                                              script_filename::String = "batch_jobscript")
    sub_directory_name = "weak_scaling"
    # create a strong scaling hierarchy
    strong_scaling_create_subdirectories(kpar_range, ncore_nsim_range; path=path, verbose=verbose, keyword=keyword, time=time,
                                             avail_cpus_per_node=avail_cpus_per_node, avail_gpus_per_node=avail_gpus_per_node,
                                             module_path=module_path, module_list=module_list, vasp_exe=vasp_exe, partition=partition,
                                             omp_num_threads=omp_num_threads, mail=mail, script_filename=script_filename, sub_directory_name=sub_directory_name)
    # modify POSCAR according to scaling parameter
    for (i, _) in enumerate(kpar_range)
        folder = "$(sub_directory_name)_$(i)_"*keyword
        poscar = read_poscar(path*folder*"/POSCAR")
        mv(path*folder*"/POSCAR", path*folder*"/POSCAR_primitive")
        scv = i == 1 ? [1,1,1] : (i-1).*super_cell_vector
        poscar = transform_primitive_cell(poscar, scv; digits=10)
        write_poscar(poscar; filename=path*folder*"/POSCAR")
        # check if KSPACING is SET otherwise print message
        incar = read_incar(path*folder*"/INCAR")
        if haskey(incar, "KSPACING")
            println("KSPACING is not set. If you use a regular KPOINT file, please adjust it yourself. It is recommend to use KSPACING.")
        end
    end
end
