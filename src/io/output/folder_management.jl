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
                @info "$file file was not found in current path ($path)."
            end
            cp(path*file, path*folder*"/$file", force=true)
        end
        set_keyword_in_incar!(param, value, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
    end
end

function nscf_create_subdirectories()
    mkdir("scf"); mkdir("nscf")
end