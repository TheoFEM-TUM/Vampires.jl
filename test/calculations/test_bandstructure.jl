

@testset "Bandgap" begin
    kp, Es, occs = read_eigenval(test_file_path*"EIGENVAL_gaas")
    VBM, CBM, (ivbm, kvbm) = get_vbm_and_cbm(Es, occs)

    @test get_bandgap(test_file_path*"EIGENVAL_gaas", printit=false) == 0.5953680000000001
    @test occs[ivbm, kvbm] > 0.9
    @test occs[ivbm+1, kvbm+1] < 0.1
    @test get_fermi_energy(Es, occs, printit=true) == 3.060283
end

@testset "FDM coefficients" begin
    # Test 1: N = 3
    @test Vampires.get_finite_difference_coef(3) == [1, -2, 1]

    # Test 2: N = 4
    @test Vampires.get_finite_difference_coef(4) == [2, -5, 4, -1]

    # Test 3: N = 5
    @test Vampires.get_finite_difference_coef(5) == [35/12, -26/3, 19/2, -14/3, 11/12]

    # Test 4: N = 6
    @test Vampires.get_finite_difference_coef(6) == [15/4, -77/6, 107/6, -13, 61/12, -5/6]

    # Test 5: N = 7
    @test Vampires.get_finite_difference_coef(7) == [203/45, -87/5, 117/4, -254/9, 33/2, -27/5, 137/180]

    # Test 6: N = 8
    @test Vampires.get_finite_difference_coef(8) == [469/90, -223/10, 879/20, -949/18, 41, -201/10, 1019/180, -7/10]

    # Test 7: Invalid N less than 3
    @test_throws ErrorException Vampires.get_finite_difference_coef(2)

    # Test 8: Invalid N greater than 8
    @test_throws ErrorException Vampires.get_finite_difference_coef(9)

    # Test 9: Edge case N = 3 (minimum valid N)
    @test Vampires.get_finite_difference_coef(3) == [1, -2, 1]

    # Test 10: Edge case N = 8 (maximum valid N)
    @test Vampires.get_finite_difference_coef(8) == [469/90, -223/10, 879/20, -949/18, 41, -201/10, 1019/180, -7/10]

end