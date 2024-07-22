params = ["ENCUT", "LOOP+", "TOTEN"]
values = [250, 0.8263, 3.61103872]

@testset "OUTCAR params" begin
    for (param, value) in zip(params, values)
        @test read_value_from_file(param, test_file_path*"OUTCAR_gaas", mode="first", N=1) == value
    end
    @test read_value_from_file("LOOP+", test_file_path*"OUTCAR_gaas", mode="last", N=1) == 0.9085
    @test length(read_value_from_file("LOOP", test_file_path*"OUTCAR_gaas", mode="first", N=0)) == 12
end