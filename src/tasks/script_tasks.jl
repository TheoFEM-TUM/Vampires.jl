"""
list of available tasks:

run_script
    prepare: creates a bash script that runs vasp in a specific folder
slurm_script
    prepare: creates a slurm submission script based on the extemded configuration file
    parallelization parameters are set to the default - individual tuning necessary
    #TODO: make this dependent on NCORE and KPAR and find best slurm configuration
"""

function run_task(::Type{Val{:run_script}}, ::Type{Val{:prepare}}, args)
    write_run_script(args["vasp_exe"], args["p"])
end


function run_task(::Type{Val{:slurm_script}}, ::Type{Val{:prepare}}, args)
    if args["ext_par_file"] == "none"; throw("Slurm script tasks require a parameter file."); end
    extended_args = read_config(args["ext_par_file"])[args["block"]]
    vasp_exe = args["vasp_exe"] == "vasp_std" && haskey(extended_args, "vasp_exe") ? extended_args["vasp_exe"] : args["vasp_exe"]
    time = args["N"] == "none" ? extended_args["time"] : args["N"]
    time = parse(Int, time)
    module_path = extended_args["module_path"]
    module_list = extended_args["module_list"]
    partition = extended_args["partition"]
    omp_num_threads = tryparse(Int, extended_args["omp_num_threads"])
    omp_num_threads = isnull(omp_num_threads) ? 1 : parse(omp_num_threads)
    mail = extended_args["mail"]
    write_slurm_script(args["p"];  module_path=module_path, module_list=module_list, vasp_exe=vasp_exe, time=time, nodes=1, ntasks=24, ntasks_per_core=0, omp_num_threads=1, num_gpu=0, partition=partition, mail=mail, script_filename=script_filename)
end