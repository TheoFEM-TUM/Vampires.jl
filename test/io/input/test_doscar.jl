dos, meta = read_doscar(test_file_path*"DOSCAR_mapbi3")

@test dos == read_from_file(test_file_path*"dos_mapbi3_correct.dat")

@testset "DOS Meta-Data" begin 
    @test meta["TEBEG"] == 1.000000000000000E-004
    @test meta["Nion"] == 12
    @test meta["Emax"] == 19.65343672
    @test meta["Emin"] == -20.43469034
    @test meta["NEDOS"] == 301
    @test meta["Ef"] == 1.51355922
end

@testset "Orbital list" begin
    # Test 1: Non-spin-polarized orbitals with LMAXMIX = 1
    ISPIN =1; LMAXMIX = 1; LSORBIT = false; LORBIT = 0
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s", "p"]

    # Test 2: Non-spin-polarized orbitals with LMAXMIX = 2
    ISPIN =1; LMAXMIX = 2; LSORBIT = false; LORBIT = 0
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s", "p", "d"]

    # Test 3: Non-spin-polarized orbitals with LORBIT > 10
    ISPIN = 1; LMAXMIX = 2; LSORBIT = false; LORBIT = 11
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s", "p_y", "p_x", "p_z", "d_xy", "d_yz", "d_z2", "d_xz", "d_x2-y2"]

    # Test 4: Spin-polarized orbitals with LORBIT > 10
    ISPIN = 2; LMAXMIX = 2; LSORBIT = false; LORBIT = 11
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s(up)", "s(down)", "p_y(up)", "p_y(down)", "p_x(up)", "p_x(down)", "p_z(up)", "p_z(down)", "d_xy(up)", "d_xy(down)", "d_yz(up)", "d_yz(down)", "d_z2(up)", "d_z2(down)", "d_xz(up)", "d_xz(down)", "d_x2-y2(up)", "d_x2-y2(down)"]

    # Test 5: Spin-orbit coupling is switched on for non-spin-polarized
    ISPIN = 1; LMAXMIX = 2; LSORBIT = true; LORBIT = 11
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s(total)", "s(mx)", "s(my)", "s(mz)", "p_y(total)", "p_y(mx)", "p_y(my)", "p_y(mz)", "p_x(total)", "p_x(mx)", "p_x(my)", "p_x(mz)", "p_z(total)", "p_z(mx)", "p_z(my)", "p_z(mz)", "d_xy(total)", "d_xy(mx)", "d_xy(my)", "d_xy(mz)", "d_yz(total)", "d_yz(mx)", "d_yz(my)", "d_yz(mz)", "d_z2(total)", "d_z2(mx)", "d_z2(my)", "d_z2(mz)", "d_xz(total)", "d_xz(mx)", "d_xz(my)", "d_xz(mz)", "d_x2-y2(total)", "d_x2-y2(mx)", "d_x2-y2(my)", "d_x2-y2(mz)"]

    # Test 6: Default case with non-decomposed orbitals (LORBIT = 0)
    ISPIN = 1; LMAXMIX = 0; LSORBIT = false; LORBIT = 0
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s"]

    # Test 7: Spin-polarized with no decomposed orbitals
    ISPIN = 2; LMAXMIX = 0; LSORBIT = false; LORBIT = 0
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s(up)", "s(down)"]

    # Test 8: Edge case with invalid LORBIT
    ISPIN = 1; LMAXMIX = 1; LSORBIT = false; LORBIT = -1  # Invalid value, should revert to default behavior
    orbitals = Vampires.get_pdos_orbital_list(ISPIN=ISPIN, LMAXMIX=LMAXMIX, LSORBIT=LSORBIT, LORBIT=LORBIT)
    @test orbitals == ["s", "p"]  # Should return the base orbitals since LORBIT is invalid    
end