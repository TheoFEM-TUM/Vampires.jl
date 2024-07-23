params = ["ENCUT", "LOOP+", "TOTEN"]
values = [250, 0.8263, -8.25135668]

@testset "OUTCAR params" begin
    for (param, value) in zip(params, values)
        @test read_value_from_outcar(param, test_file_path*"OUTCAR_gaas")[end] == value
    end
    @test read_value_from_outcar("LOOP+", test_file_path*"OUTCAR_gaas", line_mode="last")[end] == 0.9085
    @test length(read_value_from_outcar("LOOP", test_file_path*"OUTCAR_gaas", line_mode="first")) == 12
    @test read_value_from_outcar("TOTEN", test_file_path*"OUTCAR_gaas")[1] == 3.61103872
    @test length(read_value_from_outcar("TOTEN", test_file_path*"OUTCAR_gaas")) == 12
end