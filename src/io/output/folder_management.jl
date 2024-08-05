"""
    convergence_create_subdirectories(param, param_range; path="./")

Creates subdirectories for a parameter convergence study and copies necessary VASP input files into each subdirectory.

# Arguments
- `param::String`: The parameter to be varied for the convergence study.
- `param_range::AbstractVector`: A range or array of parameter values to be used for the subdirectories.
- `path::String`: The base path where the subdirectories will be created. Defaults to `"./"`.
"""
function convergence_create_subdirectories(param, param_range; path="./", verbose=true, method="none")
    for value in param_range
        folder = param*"_"*value
        mkpath(path*folder)
        if param == "kgrid"
            N = parse(Int64, value)
            gamma_centered = lowercase(method[1]) == "m" ? false : true
            write_kpoints(N, gamma_centered=gamma_centered, out=path*folder*"/KPOINTS")
            copy_vasp_input(path, folder, ignore=["KPOINTS"])
        else
            copy_vasp_input(path, folder, ignore=["INCAR"])
            set_keyword_in_incar!(param, value, path*"INCAR", out=path*folder*"/INCAR", verbose=verbose)
        end
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