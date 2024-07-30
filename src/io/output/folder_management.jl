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
        for file in ["KPOINTS", "POTCAR", "POSCAR"]
            if !isfile(path*file)
                throw("Please supply a basic $file for your job in the base path ($path)")
            end
            cp(path*file, path*folder*"/$file", force=true)
        end
        set_keyword_in_incar!(param, value, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
    end
end


"""
TODO
"""
function strong_scaling_create_subdirectories(kpar_range<:AbstractArray,  ncore_nsim_range<:AbstractArray; path="./", verbose=true, keyword="CPU")
    if keyword ∉ ["CPU", "GPU"]; throw("Scaling Tests for $keyword are not supported"); end
    @assert length(kpar_range) == length(ncore_nsim_range)
    for (i, kpar, ncore_nsim) in zip(range(length(kpar_range)), kpar_range, ncore_nsim_range)
        folder = "strong_scaling_$i\_"*keyword
        mkpath(path*folder)
        for file in ["KPOINTS", "POTCAR", "POSCAR"]
            if !isfile(path*file)
                throw("Please supply a basic $file for your job in the base path ($path)")
            end
            cp(path*file, path*folder*"/$file", force=true)
        end
        set_keyword_in_incar!("KPAR", kpar, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        if keyword == "CPU"
            set_keyword_in_incar!("NCORE", ncore_nsim, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        elseif keyword == "GPU"
            set_keyword_in_incar!("NSIM", ncore_nsim, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        end
        write_slurm_script()
    end
end
