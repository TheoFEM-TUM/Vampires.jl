"""
list of available tasks:

prepare
    run_script: creates a bash script that runs vasp in a specific folder
    slurm_script: creates a slurm submission script based on the specified parallelization parameters
"""

function run_task(::Type{Val{:prepare}}, ::Type{Val{:run_script}}, args)
    write_run_script(args["vasp_exe"], args["p"])
end


function run_task(::Type{Val{:prepare}}, ::Type{Val{:slurm_script}}, args)
    write_slurm_script(args["p"], args["o"], args["nnodes"], args["gpu"])
end