# Test read_config
@testset "Extended parameter file read" begin
    config = read_config(test_file_path*"extended_parameter_file")
    @test config["batch_file_gpu"]["module_path"] == "/path/to/cpu_modules/"
    @test config["batch_file_gpu"]["module_list"] == "module1,module2"
    @test config["batch_file_gpu"]["exe"] == "vasp_exe"
    @test config["batch_file_gpu"]["partition"] == "gpus"
    @test config["batch_file_gpu"]["mail"] == "user.name@mail.com"
    @test config["batch_file_gpu"]["omp_num_threads"] == "40"

    @test config["batch_file_cpu"]["module_path"] == "/path/to/gpu_modules/"
    @test config["batch_file_cpu"]["module_list"] == "module1,module2"
    @test config["batch_file_cpu"]["exe"] == "vasp_exe"
    @test config["batch_file_cpu"]["partition"] == "batch"
    @test config["batch_file_cpu"]["mail"] == "user.name@mail.com"
    @test config["batch_file_cpu"]["omp_num_threads"] == "1"

    @test length(config) == 2
end