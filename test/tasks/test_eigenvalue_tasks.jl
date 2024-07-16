kp, Es, occs = read_eigenval(test_file_path*"EIGENVAL_gaas")
VBM, CBM, (ivbm, kvbm) = get_vbm_and_cbm(Es, occs)

@test get_bandgap(test_file_path*"EIGENVAL_gaas", printit=false) == 0.5953680000000001
@test occs[ivbm, kvbm] > 0.9
@test occs[ivbm+1, kvbm+1] < 0.1
