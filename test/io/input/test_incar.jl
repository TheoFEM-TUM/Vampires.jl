

incar = read_incar(test_file_path*"INCAR")

@testset "INCAR read" begin
    @test findvalue(incar, "ENCUT") == "250"
    @test length(incar.vasp) == 5
    @test findvalue(incar, "NCORE") == "12"
    @test findvalue(incar, "ISIF") == "2"
    @test findvalue(incar, "LPLANE") == "True"
    @test findvalue(incar, "LSCALAPACK") == ".FALSE."
end

write_incar(incar, test_file_path*"INCAR_new")

incar_new = read_incar(test_file_path*"INCAR_new")
@testset "INCAR write" begin
    @test findvalue(incar_new, "ENCUT") == "250"
    @test length(incar_new.vasp) == 5
    @test findvalue(incar_new, "NCORE") == "12"
    @test findvalue(incar_new, "ISIF") == "2"
    @test findvalue(incar_new, "LPLANE") == "True"
    @test findvalue(incar_new, "LSCALAPACK") == ".FALSE."
end

keywords = ["EDIFF", "POTIM", "LCHARG", "NWRITE"]
values = ["1e-6", "10", "True", "1"]

@testset "INCAR set/add/rm" begin
    for (keyword, value) in zip(keywords, values)
        set_key!(incar, keyword, value, verbose=false)
        @test findvalue(incar, keyword) == value
    end
    write_incar(incar, test_file_path*"INCAR_prime")
    incar_prime = read_incar(test_file_path*"INCAR_prime")
    for (keyword, value) in zip(keywords, values)
        @test findvalue(incar, keyword) == value
    end

    # Test multiple keywords and values
    incar2 = read_incar(test_file_path*"INCAR")
    set_key!(incar2, keywords, values, verbose=false)
    for (keyword, value) in zip(keywords, values)
        @test findvalue(incar2, keyword) == value
    end

    @test findvalue(incar2, "NELM") == "60"
    remove_key!(incar2, "NELM", verbose=false)
    @test_throws KeyError findvalue(incar2, "NELM")
end

@testset "INCAR blocks" begin
    incar_small = read_incar(test_file_path*"INCAR_small")
    @test_throws KeyError findvalue(incar_small, "NCORE")
    @test_throws KeyError findvalue(incar_small,"KPAR")
    add_incar_block!(incar_small, "Parallelization", verbose=false)
    @test findvalue(incar_small, "NCORE") == "1"
    @test findvalue(incar_small, "KPAR") == "1"
end

@testset "INCAR W90" begin
    incar_w90 = read_incar(test_file_path*"INCAR_W90")
    keys = ["dis_win_max", "num_wann", "projAs"]
    values = ["15", "8", "l=0;l=1"]
    for (key, value) in zip(keys, values)
        @test findvalue(incar_w90, key) == value
    end

    set_key!(incar_w90, "dis_win_max", "16", verbose=false)
    @test findvalue(incar_w90, "dis_win_max") == "16"
    block_label, isW90 = Vampires.findkey(incar_w90, "dis_win_max")
    @test isW90
    @test block_label == "Disentanglement"

    set_key!(incar_w90, "projGa", "sp3", verbose=false)
    @test findvalue(incar_w90, "projGa") == "sp3"
    block_label, isW90 = Vampires.findkey(incar_w90, "projGa")
    @test isW90
    @test block_label == "Initial guess for WFs"

    set_key!(incar_w90, "wannier_plot", "True", verbose=false, block_label="Plotting")
    @test findvalue(incar_w90, "wannier_plot") == "True"
    block_label, isW90 = Vampires.findkey(incar_w90, "wannier_plot")
    @test isW90
    @test block_label == "Plotting"

    write_incar(incar_w90, test_file_path*"INCAR_w90_out")
    incar_w90_out = read_incar(test_file_path*"INCAR_w90_out")
    @test findvalue(incar_w90, "wannier_plot") == "True"
    @test findvalue(incar_w90, "projGa") == "sp3"
    @test findvalue(incar_w90, "dis_win_max") == "16"
end

rm(test_file_path*"INCAR_new")
rm(test_file_path*"INCAR_prime")
rm(test_file_path*"INCAR_w90_out")