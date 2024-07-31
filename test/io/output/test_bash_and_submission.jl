
# Helper functions to read the generated SLURM script and extract the necessary information
function read_slurm_script(filepath::String)
    return read(filepath, String)
end

function extract_sbatch_directive(script::String, directive::String)
    match_res = match(r"\#SBATCH\s+--"*directive*r"=([^\n]+)", script)
    return match_res !== nothing ? match_res.captures[1] : nothing
end

@testset "SLURM Script" begin
    script_path = test_file_path * "test_jobscript.sh"
    write_slurm_script(test_file_path; module_path="/path/to/modules", module_list=["module1", "module2"], vasp_exe="vasp_std",
                       time=2, nodes=2, ntasks=96, ntasks_per_core=2, omp_num_threads=12, num_gpu=4, partition="batch",
                       mail="user@example.com", script_filename="test_jobscript.sh")

    script_content = read_slurm_script(script_path)
    
    # Test SBATCH directives
    @test extract_sbatch_directive(script_content, "nodes") == "2"
    @test extract_sbatch_directive(script_content, "ntasks") == "96"
    @test extract_sbatch_directive(script_content, "partition") == "batch"
    @test extract_sbatch_directive(script_content, "gres") == "gpu:4"
    @test extract_sbatch_directive(script_content, "time") == "02:00:00"
    @test extract_sbatch_directive(script_content, "mail-user") == "user@example.com"
    
    # Test module loading
    @test occursin("module use /path/to/modules", script_content)
    @test occursin("module load module1", script_content)
    @test occursin("module load module2", script_content)

    # Test VASP execution command
    @test occursin("orterun --map-by ppr:4:node --bind-to core -np 4 \${vasp_std} > vasp.log", script_content)

    # rm(script_path)
end