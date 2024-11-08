"""
    compare_w90_and_dft(hr_file, eig_file; method="rmse", bandmin=1)

Compares the eigenvalues from a Wannier90 Hamiltonian file (`hr_file`) with those from a DFT eigenvalue file (`eig_file`) over a specified band range.

# Arguments
- `hr_file`: Path to the Wannier90 Hamiltonian file, containing tight-binding parameters.
- `eig_file`: Path to the DFT eigenvalue file.
- `method`: Specifies the error calculation method to use. Options are:
    - `"rmse"`: Root Mean Square Error (default)
    - `"mae"`: Mean Absolute Error
    - `"mse"`: Mean Squared Error
- `bandmin`: The starting band index for comparison, with the default being `1`. This value defines the minimum band included in the range of bands for analysis.

# Returns
- `error`: The error metric between DFT and Wannier90 eigenvalues for the selected band range, as per the specified `method`.

"""
function compare_w90_and_dft(hr_file, eig_file; method="rmse", bandmin=1)
    ks, Es_dft, _ = read_eigenval(eig_file)
    Hr, Rs, deg = read_hrdat(hr_file)
    bandmax = bandmin + size(Hr, 1) - 1

    Es_dft = Es_dft[bandmin:bandmax, :]
    Es_w90, _ = get_wannier90_eigenvalues(Hr, Rs, deg, ks)

    if lowercase(method) == "rmse"
        error = RMSE(Es_dft, Es_w90)
    elseif lowercase(method) == "mae"
        error = MAE(Es_dft, Es_w90)
    elseif lowercase(method) == "mse"
        error = MSE(Es_dft, Es_w90)
    end
    return error
end

"""
    get_energy_windows(eig_file, num_wann; bandmin=1, tol=0.1)

Calculate the energy windows for a Wannier90 calculation based on eigenvalues from an EIGENVAL file.

# Arguments
- `eig_file`: The path to the EIGENVAL file containing DFT-calculated eigenvalues.
- `num_wann`: The number of Wannier functions (or bands) used in the Wannier90 calculation.
- `bandmin`: (Optional) The starting index of bands for the Wannier90 projection (default is 1).
- `tol`: (Optional) A tolerance factor to expand the energy window slightly above and below the calculated minimum and maximum values (default is 0.1).

# Returns
- `dis_win_min`: The minimum energy for the disentanglement window.
- `dis_win_max`: The maximum energy for the disentanglement window.
- `dis_froz_min`: The minimum energy for the frozen window (typically set equal to `dis_win_min`).
- `dis_froz_max`: The maximum energy for the frozen window, set to the VBM plus `tol`.
"""
function get_energy_windows(eig_file, num_wann; bandmin=1, tol=0.1)
    _, Es, occs = read_eigenval(eig_file)
    VBM, _, _ = get_vbm_and_cbm(Es, occs)
    bandmax = bandmin + num_wann - 1
    Es = Es[bandmin:bandmax, :]

    dis_win_min = round(minimum(Es) - tol, digits=2)
    dis_win_max = round(maximum(Es) + tol, digits=2)
    dis_froz_min = dis_win_min
    dis_froz_max = round(VBM + tol, digits=2)
    return dis_win_min, dis_win_max, dis_froz_min, dis_froz_max
end