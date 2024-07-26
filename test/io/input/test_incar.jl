incar = read_incar(test_file_path*"INCAR")

@testset "INCAR read" begin
    @test get_value_for_keyword("ENCUT", incar) == "250"
    @test length(incar) == 5
    @test get_value_for_keyword("NCORE", incar) == "12"
    @test get_value_for_keyword("ISIF", incar) == "2"
    @test get_value_for_keyword("LPLANE", incar) == "True"
    @test get_value_for_keyword("LSCALAPACK", incar) == ".FALSE."
end

write_incar(incar, test_file_path*"INCAR_new")

incar_new = read_incar(test_file_path*"INCAR_new")
@testset "INCAR write" begin
    @test get_value_for_keyword("ENCUT", incar_new) == "250"
    @test length(incar_new) == 5
    @test get_value_for_keyword("NCORE", incar_new) == "12"
    @test get_value_for_keyword("ISIF", incar_new) == "2"
    @test get_value_for_keyword("LPLANE", incar_new) == "True"
    @test get_value_for_keyword("LSCALAPACK", incar_new) == ".FALSE."
end

keywords = ["EDIFF", "POTIM", "LCHARG", "NWRITE"]
values = ["1e-6", "10", "True", "1"]

@testset "INCAR set/add/rm" begin
    for (keyword, value) in zip(keywords, values)
        set_keyword!(keyword, value, incar, verbose=false)
        @test get_value_for_keyword(keyword, incar) == value
    end
    write_incar(incar, test_file_path*"INCAR_prime")
    incar_prime = read_incar(test_file_path*"INCAR_prime")
    for (keyword, value) in zip(keywords, values)
        @test get_value_for_keyword(keyword, incar) == value
    end

    # Test multiple keywords and values
    incar2 = read_incar(test_file_path*"INCAR")
    set_keyword!(keywords, values, incar2, verbose=false)
    for (keyword, value) in zip(keywords, values)
        @test get_value_for_keyword(keyword, incar2) == value
    end

    @test get_value_for_keyword("NELM", incar2) == "60"
    remove_keyword!("NELM", incar2, verbose=false)
    @test_throws KeyError get_value_for_keyword("NELM", incar2)
end

@testset "INCAR blocks" begin
    incar_small = read_incar(test_file_path*"INCAR_small")
    @test_throws KeyError get_value_for_keyword("NCORE", incar_small)
    @test_throws KeyError get_value_for_keyword("KPAR", incar_small)
    add_incar_block!("Parallelization", incar_small, verbose=false)
    @test get_value_for_keyword("NCORE", incar_small) == "1"
    @test get_value_for_keyword("KPAR", incar_small) == "1"
end

rm(test_file_path*"INCAR_new")
rm(test_file_path*"INCAR_prime")