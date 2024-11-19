"""
list of available tasks:

w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
    test: test the accuracy of a W90 model versus DFT
w90
    set: set parameters in the INCAR file that are specific to W90
w90_nscf
    make: create the folder structure for a NSCF calculation with W90
"""


"""
# CLI Commands to work with Wannier90 files

Available commands:
* `vamp w90_hr read`: Read the Wannier90 `w90_hr.dat` file and export its data.
* `vamp w90_hr test`: Test the accuracy of a W90 model versus DFT.
* `vamp w90 set`: Set parameters in the INCAR file that are specific to W90.
* `vamp w90_nscf make`: Create the folder structure for a NSCF calculation with W90.
"""
run_task(::Type{Val{:w90}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] w90_hr read [--w90_hr <file>] [--o <output_file>]

Read the Wannier90 `w90_hr.dat` file and export its data in HDF5 format.

# Arguments
- `w90_hr`: Path to the `w90_hr.dat` file to be read.
- `o`: Name of the output file (optional; defaults to "w90_hr.h5"). The output must be in HDF5 format.

# Behavior
- This function reads the Hamiltonian matrix (`Hr`), lattice vectors (`Rs`), and degeneracies (`deg`) from the specified Wannier90 `w90_hr.dat` file.
- If the output file is in HDF5 format, the function saves the read data as datasets within the HDF5 file.
- If `r` is true, the Hamiltonians, degeneracies and lattice vectors are read from each subfolder and stored in the same output file.

# Examples
```bash
# Example 1: Read data from a w90_hr.dat file and save it to a default HDF5 file.
vamp w90_hr read --w90_hr /path/to/w90_hr.dat

# Example 2: Read data from 
vamp w90_hr read --w90_hr /path/to/w90_hr.dat --o /path/to/output.h5
"""
function run_task(::Type{Val{:w90_hr}}, ::Type{Val{:read}}, args)
    input_filename = joinpath(args["p"], args["w90_hr"])
    eigenval = joinpath(args["p"], args["eigenval"])
    incar = joinpath(args["p"], args["incar"])
    Hr, Rs, deg = read_hrdat(input_filename)
    if args["par"] == "eigenvalues"
        ks, _, _ = read_eigenval(eigenval)
        Es, _ = get_wannier90_eigenvalues(Hr, Rs, deg, ks)
        return (eigenvalues = Es,)
    elseif args["par"] == "bandgap"
        num_wann = parse(Int64, findvalue(read_incar(incar), "num_wann"))
        bandmin = parse(Int64, args["N"])
        bandmax = bandmin + num_wann - 1
        ks, _, occs = read_eigenval(eigenval)
        Es, _ = get_wannier90_eigenvalues(Hr, Rs, deg, ks)
        ΔE = get_bandgap(Es, occs[bandmin:bandmax, :])
        return (bandgap = ΔE,)
    else
        return (Hr = Hr, Rs = Rs, degeneracies = deg)
    end
end

"""
    vamp [-r] w90_hr test [--w90_hr <file>] [--method <error_function>] [--N <bandmin>]

Calculate the eigenvalues from a Wannier90 Hr file and compare them to DFT eigenvalues from the EIGENVAL file.

# Arguments
- `w90_hr`: The filename of the Wannier90 `Hr` file containing the Hamiltonian.
- `method`: Specifies the error function (not case sensitive). Options include:
    - `"rmse"` (Root Mean Square Error, default)
    - `"mae"` (Mean Absolute Error)
    - `"mse"` (Mean Squared Error)
- `N`: Starting band index for comparison (default is 1).
- `p`: The path to the directory containing both the `Hr` and `EIGENVAL` files.

# Returns
- `["<method>_error"]`: The name of the error metric calculated.
- `[error]`: The calculated error.

# Examples
```bash
# Example 1: Calculate RMSE between Wannier90 and DFT eigenvalues starting from band 14.
vamp w90_hr test --method rmse --N 14

# Example 2: Calculate the MAE between Wannier90 and DFT in every subfolder for custom filenames.
vamp -r w90_hr test --w90_hr custom_hr.dat --eigenval custom_EIGENVAL
```
"""
function run_task(::Type{Val{:w90_hr}}, ::Type{Val{:test}}, args)
    bandmin = parse(Int64, args["N"]) == 0 ? 1 : parse(Int64, args["N"])
    method = args["method"] == "none" ? "rmse" : args["method"]
    hr_file = joinpath(args["p"], args["w90_hr"])
    eig_file = joinpath(args["p"], args["eigenval"])

    error = compare_w90_and_dft(hr_file, eig_file, bandmin=bandmin, method=method)
    return ["$method"*"_error"], [error]
end

"""
    vamp w90 set [--par <parameter>] [--tol <tolerance>] [--N <bandmin>] [--p <path>] [--incar <file>]

Set parameters in the INCAR file for a Wannier90 calculation based on the specified parameter. If `par` is an INCAR parameter simply calls `incar set`.

# Arguments
- `par`: Specifies the parameter to configure in the INCAR file. Options include:
    - `"windows"`: Sets energy windows (`dis_win_min`, `dis_win_max`, `dis_froz_min`, `dis_froz_max`) for the Wannier90 disentanglement process.
    - `"projections"`: Specifies projections (this functionality is pending).
- `tol`: Tolerance applied when calculating energy windows (default is 0.1).
- `N`: Starting band index for calculating energy windows (default is 1).
- `p`: The path to the directory containing both the `incar` and `eigenval` files.
- `incar`: Path to the INCAR file in which the specified parameters will be set.

# Examples
```bash
# Example 1: Set energy windows in the INCAR file with a tolerance of 0.15, starting from band index 10.
vamp w90 set --par windows --tol 0.15 --N 10 --p /path/to/dir --incar INCAR --eigenval EIGENVAL_bands
```
"""
function run_task(::Type{Val{:w90}}, ::Type{Val{:set}}, args)
    tol = parse(Float64, args["tol"])

    if args["par"] == "windows"
        incar = joinpath(args["p"], args["incar"])
        eig_file = joinpath(args["p"], args["eigenval"])
        bandmin = parse(Int64, args["N"]) == 0 ? 1 : parse(Int64, args["N"])
        num_wann = parse(Int64, findvalue(read_incar(incar), "num_wann"))
        
        dis_win_min, dis_win_max, dis_froz_min, dis_froz_max = get_energy_windows(eig_file, num_wann; bandmin=bandmin, tol=tol)
        
        args["par"] = "dis_win_min,dis_win_max,dis_froz_min,dis_froz_max"
        args["val"] = "$dis_win_min,$dis_win_max,$dis_froz_min,$dis_froz_max"
    elseif args["par"] == "projections"
        # TODO
    end
    
    run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
end

"""
    vamp [-r] w90_nscf make [--p <path>] [--exe <executable>] [--kpoints <kpoints_file>] [--incar <incar_file>] [--exclude <files>]

Prepare subdirectories and scripts for a non-self-consistent field (NSCF) Wannier90 calculation.

# Arguments
- `p`: The base path where the subdirectories and run scripts are created.
- `exe`: The executable file for the NSCF calculation.
- `kpoints`: Path to the KPOINTS file(s). If applicable, first file is used for SCF and second file for NSCF calculation.
- `incar`: Path to the INCAR file. If applicable, first file is used for SCF and second file for NSCF calculation.
- `exclude`: Optional files or list of files to be removed after each calculation, using a callback for customization.

# Examples
```bash
# Example: Set up an NSCF Wannier90 calculation with specific INCAR and KPOINTS, and exclude certain files.
vamp w90_nscf make --p /path/to/calc --exe vasp_std --kpoints KPOINTS,KPOINTS_W90 --incar INCAR,INCAR_W90 --exclude WAVECAR,XDATCAR
```
"""
function run_task(::Type{Val{:w90_nscf}}, ::Type{Val{:make}}, args)
    nscf_create_subdirectories(args["p"], args["kpoints"], args["incar"])
    filename = joinpath(args["p"], "run_nscf.sh")
    bandmin = args["N"] == "0" ? 1 : parse(Int64, args["N"])
    cb = get_exclude_callback(args["exclude"])
    if length(cb) > 0; cb *= "\n"; end
    cb *= "if [[ \"\$folder\" == \"scf\" ]]; then\n      ln -f CHGCAR ../nscf/CHGCAR\n      vamp w90 set --N $bandmin --par windows --eigenval EIGENVAL --incar ../nscf/INCAR\n    fi"
    write_run_script(args["exe"], "./", cb=cb, out=filename)
    add_path_to_folders.(filename, ["scf", "nscf"])

    scf_incar = joinpath(args["p"], "scf/INCAR")
    set_key_in_incar("LWANNIER90_RUN", "False", scf_incar, verbose=args["v"])

    nscf_incar = joinpath(args["p"], "nscf/INCAR")
    set_key_in_incar(["LWANNIER90_RUN","NCORE"], ["true" ,"1"], nscf_incar, verbose=args["v"])
    return nothing
end