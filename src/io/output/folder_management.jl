"""
    convergence_create_subdirectories(param, param_range; path="./")

Creates subdirectories for a parameter convergence study and copies necessary VASP input files into each subdirectory.

# Arguments
- `param::String`: The parameter to be varied for the convergence study.
- `param_range::AbstractVector`: A range or array of parameter values to be used for the subdirectories.
- `path::String`: The base path where the subdirectories will be created. Defaults to `"./"`.
"""
function convergence_create_subdirectories(param, param_range; path="./", verbose=true)
    for value in param_range
        folder = param*"_"*value
        mkpath(path*folder)
        copy_vasp_input(path, folder, ignore=["INCAR"])
        set_keyword_in_incar!(param, value, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
    end
end

"""
    nscf_create_subdirectories(path::String, kpoint_files::Vector{String})

Create and set up the "scf" and "nscf" subdirectories for VASP calculations, copying necessary files 
and adjusting INCAR settings.

# Arguments
- `path::String`: The directory where the VASP input files are located.
- `kpoint_files::String`: A string containing two KPOINTS filenames for the "scf" and "nscf" calculations respectively.
"""
function nscf_create_subdirectories(path, kpoints; verbose=true)
    for folder in ["scf", "nscf"]
        mkdir(path*folder)
        copy_vasp_input(path, folder, ignore=["KPOINTS"])
    end
    kpoint_files = split_line(kpoints, char=',')
    cp(path*kpoint_files[1], path*"scf/KPOINTS"); cp(path*kpoint_files[2], path*"nscf/KPOINTS") # TODO: write kpoint file with from kpath argument?

    remove_keyword_from_incar!("LCHARG", path*"scf/INCAR", verbose=verbose)
    set_keyword_in_incar!("ISTART", "0", path*"scf/INCAR", verbose=verbose)
    set_keyword_in_incar!("LCHARG", "True", path*"scf/INCAR", verbose=verbose)

    remove_keyword_from_incar!("ISTART", path*"nscf/INCAR", verbose=verbose)
    set_keyword_in_incar!("ICHARG", "11", path*"nscf/INCAR", verbose=verbose)
    set_keyword_in_incar!("LCHARG", "False", path*"nscf/INCAR", verbose=verbose)
end

"""
    copy_vasp_input(path::String, folder::String; ignore::Vector{String}=String[])

Copy specific VASP input files ("KPOINTS", "POTCAR", "POSCAR") from the directory (`path`) to a subdirectory (`folder`).

# Arguments
- `path::String`: The directory where the VASP input files are located.
- `folder::String`: The target subdirectory within `path` where the files will be copied.
- `ignore::Vector{String}`: An optional list of filenames to ignore during the copy process.
"""
function copy_vasp_input(path, folder; ignore=String[])
    for file in ["KPOINTS", "POTCAR", "POSCAR", "INCAR"]
        if !isfile(path*file) && file ∉ ignore
            @info "$file file was not found in current path ($path)."
        elseif isfile(path*file) && file ∉ ignore
            cp(path*file, path*folder*"/$file", force=true)
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
function strong_scaling_create_subdirectories(kpar_range::AbstractArray,  ncore_nsim_range::AbstractArray;
                                              path="./", verbose=true, keyword="CPU", time=1.0, avail_gpus_per_node=4, avail_cpus_per_node=2)
    if keyword ∉ ["CPU", "GPU"]; throw("Scaling tests for $keyword are not supported"); end
    @assert length(kpar_range) == length(ncore_nsim_range)
    for (i, kpar, ncore_nsim) in zip(collect(1:length(kpar_range)), kpar_range, ncore_nsim_range)
        folder = "strong_scaling_$(i)_"*keyword
        mkpath(path*folder)
        for file in ["KPOINTS", "POTCAR", "POSCAR"]
            if !isfile(path*file)
                throw("Please supply a basic $file for your job in the base path ($path)")
            end
            cp(path*file, path*folder*"/$file", force=true)
        end
        set_keyword_in_incar!("KPAR", string(kpar), path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        if keyword == "CPU"
            set_keyword_in_incar!("NCORE", string(ncore_nsim), path*folder*"/INCAR", verbose=verbose)
            write_slurm_script(path*folder;  module_path="", module_list=[], vasp_exe="vasp_exe", time=time, nodes=ceil(Int, kpar / avail_cpus_per_node), ntasks=kpar*24, num_gpu=0, omp_num_threads=1, partition="batch", mail="", script_filename="batch_jobscript")
        elseif keyword == "GPU"
            set_keyword_in_incar!("NSIM", string(ncore_nsim), path*folder*"/INCAR", verbose=verbose, block_label=get_block_label_for_keyword("KPAR"))
            write_slurm_script(path*folder;  module_path="", module_list=[], vasp_exe="vasp_exe", time=time, nodes=ceil(Int, kpar / avail_gpus_per_node), ntasks=kpar, num_gpu=kpar, omp_num_threads=40 * ceil(Int, kpar / gpus_per_node), partition="batch", mail="", script_filename="batch_jobscript")
        end
    
    end
end
