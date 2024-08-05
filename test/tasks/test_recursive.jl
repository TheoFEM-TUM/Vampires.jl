using Suppressor

"""
this file contains all recursive tests. Even if the run_task_recursive function is defined in a different task file
"""

path = string(@__DIR__)*"/../test_files/"

path_recursive = path * "convergence/"

task = Val{Symbol("calculate")}
subtask = Val{Symbol("bandgap")}
args = Dict{String, String}("p" => path_recursive, "eigenval" => "EIGENVAL")

output = @capture_out run_task_recursive(task, subtask, args)
@test output == "ΔE = 0.5946059999999997\nΔE = 0.595008\nΔE = 0.594897\n" 


task = Val{Symbol("outcar")}
subtask = Val{Symbol("read")}

args = Dict{String, Any}("p" => path_recursive, "outcar" => "OUTCAR", "par" => "TOTEN", "N" => "0") 

output = @capture_out run_task_recursive(task, subtask, args)

@test output == "The value in ENCUT_250 is: -8.25135668\nThe value in ENCUT_300 is: -8.25251696\nThe value in ENCUT_350 is: -8.25259894\n"
