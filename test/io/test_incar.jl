

incar = read_incar(test_file_path*"INCAR")

@testset "INCAR read" begin
    @test find_value(incar, "ENCUT") == "250"
    @test length(incar.vasp) == 5
    @test find_value(incar, "NCORE") == "12"
    @test find_value(incar, "ISIF") == "2"
    @test find_value(incar, "LPLANE") == "True"
    @test find_value(incar, "LSCALAPACK") == ".FALSE."

    # Test that a tag without a comment receives default comment
    @test Vampires.find_comment(incar, "ISMEAR") == Vampires.INCAR_COMMENTS["ISMEAR"]
end

write_incar(incar, test_file_path*"INCAR_new")

incar_new = read_incar(test_file_path*"INCAR_new")
@testset "INCAR write" begin
    @test find_value(incar_new, "ENCUT") == "250"
    @test length(incar_new.vasp) == 5
    @test find_value(incar_new, "NCORE") == "12"
    @test find_value(incar_new, "ISIF") == "2"
    @test find_value(incar_new, "LPLANE") == "True"
    @test find_value(incar_new, "LSCALAPACK") == ".FALSE."
end

keywords = ["EDIFF", "POTIM", "LCHARG", "NWRITE"]
values = ["1e-6", "10", "True", "1"]

@testset "INCAR set/add/rm" begin
    for (keyword, value) in zip(keywords, values)
        set_key!(incar, keyword, value, verbose=false)
        @test find_value(incar, keyword) == value
    end
    
    # Test that a custom commend is not overwritten
    @test Vampires.find_comment(incar, "POTIM") == "MD time step in fs"

    # Test that an exsting key is overwritten in the same block
    @test Vampires.find_key(incar, "POTIM")[1] == "MD settings"

    # Test adding a new key
    set_key!(incar, "TEEND", "100", verbose=false)
    @test find_value(incar, "TEEND") == "100"
    @test Vampires.find_key(incar, "TEEND")[1] == "MolecularDynamics"
    @test Vampires.find_comment(incar, "TEEND") == Vampires.get_comment("TEEND")

    # Test adding an existing key to a different block
    set_key!(incar, "LPLANE", "False", block_label="Parallelization", verbose=false)
    @test find_value(incar, "LPLANE") == "False"
    @test Vampires.find_key(incar, "LPLANE")[1] == "Parallelization"
    @test haskey(incar.vasp["MD settings"], "LPLANE") == false

    # Test adding a new key to a new block
    set_key!(incar, "KSPACING", "0.5", block_label="K-Convergence", verbose=false)
    @test find_value(incar, "KSPACING") == "0.5"
    @test Vampires.find_key(incar, "KSPACING")[1] == "K-Convergence"
    @test Vampires.find_comment(incar, "KSPACING") == Vampires.get_comment("KSPACING")

    # Test adding a non-existing key
    set_key!(incar, "MYTAG", "NO", verbose=false)
    @test find_value(incar, "MYTAG") == "NO"
    @test Vampires.find_key(incar, "MYTAG")[1] == "Unknown"
    @test Vampires.find_comment(incar, "MYTAG") == Vampires.get_comment("MYTAG")

    write_incar(incar, test_file_path*"INCAR_prime")
    incar_prime = read_incar(test_file_path*"INCAR_prime")
    for (keyword, value) in zip(keywords, values)
        @test find_value(incar, keyword) == value
    end

    # Test multiple keywords and values
    incar2 = read_incar(test_file_path*"INCAR")
    set_key!(incar2, keywords, values, verbose=false)
    for (keyword, value) in zip(keywords, values)
        @test find_value(incar2, keyword) == value
    end

    @test find_value(incar2, "NELM") == "60"
    remove_key!(incar2, "NELM", verbose=false)
    @test_throws KeyError find_value(incar2, "NELM")
end

@testset "INCAR blocks" begin
    incar_small = read_incar(test_file_path*"INCAR_small")
    @test_throws KeyError find_value(incar_small, "NCORE")
    @test_throws KeyError find_value(incar_small,"KPAR")
    add_incar_block!(incar_small, "Parallelization", verbose=false)
    @test find_value(incar_small, "NCORE") == "1"
    @test find_value(incar_small, "KPAR") == "1"
end

@testset "INCAR W90" begin
    incar_w90 = read_incar(test_file_path*"INCAR_W90")
    keys = ["dis_win_max", "num_wann", "projAs"]
    values = ["15", "8", "l=0;l=1"]
    for (key, value) in zip(keys, values)
        @test find_value(incar_w90, key) == value
    end

    set_key!(incar_w90, "dis_win_max", "16", verbose=false)
    @test find_value(incar_w90, "dis_win_max") == "16"
    block_label, isW90 = Vampires.find_key(incar_w90, "dis_win_max")
    @test isW90
    @test block_label == "Disentanglement"

    set_key!(incar_w90, "projGa", "sp3", verbose=false)
    @test find_value(incar_w90, "projGa") == "sp3"
    block_label, isW90 = Vampires.find_key(incar_w90, "projGa")
    @test isW90
    @test block_label == "Initial guess for WFs"

    set_key!(incar_w90, "wannier_plot", "True", verbose=false, block_label="Plotting")
    @test find_value(incar_w90, "wannier_plot") == "True"
    block_label, isW90 = Vampires.find_key(incar_w90, "wannier_plot")
    @test isW90
    @test block_label == "Plotting"

    write_incar(incar_w90, test_file_path*"INCAR_w90_out")
    incar_w90_out = read_incar(test_file_path*"INCAR_w90_out")
    @test find_value(incar_w90, "wannier_plot") == "True"
    @test find_value(incar_w90, "projGa") == "sp3"
    @test find_value(incar_w90, "dis_win_max") == "16"
end

rm(test_file_path*"INCAR_new")
rm(test_file_path*"INCAR_prime")
rm(test_file_path*"INCAR_w90_out")