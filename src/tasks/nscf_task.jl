"""
list of available tasks:

nscf
    make: generate the folder structure for a scf->nscf calculation
"""



"""
# CLI Commands to work with the non self-consistent calculations

Available commands:
* `vamp nscf make`: Create folder structure for nscf calculations.
"""
run_task(::Type{Val{:nscf}}, subtask, args) = nothing

"""
    vamp nscf make --kpoints <kpoints_file> [--p <path>] [--vasp_exe <vasp_executable>]

Prepare directories and create a script for non-self-consistent field (NSCF) calculations.

# Arguments
- `kpoints`: Path to the KPOINTS file(s). Multiple filenames are separated with commas.
- `p`: Sets the path where the subdirectories and script will be created (optional; default is the current directory).
- `vasp_exe`: Path to the VASP executable that will be used in the generated script (optional; default is `vasp_std`).

# Behavior
- The function creates subdirectories for NSCF calculations and copies necessary files.
- The first k-point file is copied to `scf` and the second one to `nscf`.
- Changes the tags `ICHARG=11` and `LCHARG=False` in the NSCF INCAR file. 
- It generates a shell script (`run_nscf.sh`) to execute both calculations sequentially, including linking the charge density from the SCF run.
- The script is created with the specified VASP executable and a command to link the `CHGCAR` file from the SCF directory to the NSCF directory.

# Examples
```bash
# Example 1: Prepare NSCF directories and create a script using the default path and VASP executable.
vamp nscf make --kpoints KPOINTS,KPOINTS_bands

# Example 2: Prepare NSCF directories, create a script with the VASP executable for non-collinear calculations.
vamp nscf make --kpoints KPOINTS,KPOINTS_bands --vasp_exe vasp_ncl
```
"""
function run_task(::Type{Val{:nscf}}, ::Type{Val{:make}}, args)
    nscf_create_subdirectories(args["p"], args["kpoints"], args["incar"])
    filename = args["p"]*"run_nscf.sh"
    write_run_script(args["exe"], args["p"], cb="ln scf/CHGCAR nscf/CHGCAR", out=filename)
    add_path_to_folders.(filename, ["scf", "nscf"])
    return nothing
end