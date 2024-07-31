"""
list of available tasks:

run_script
    make: creates a bash script that runs vasp in a specific folder
"""

function run_task(::Type{Val{:run_script}}, ::Type{Val{:make}}, args)
    write_run_script(args["vasp_exe"], args["p"])
end