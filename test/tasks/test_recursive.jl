using Suppressor

"""
this file contains all recursive tests. Even if the run_task_recursive function is defined in a different task file
"""

path = string(@__DIR__)*"/../test_files/"

path_recursive = path * "convergence/"

task = Val{Symbol("eigenval")}
subtask = Val{Symbol("read")}
args = Dict{String, Any}("v"=>false, "r"=>true, "p" => path_recursive, "eigenval" => "EIGENVAL", "o"=>"none", "par"=>"bandgap", "method"=>"none")

output = run_task_recursive(task, subtask, args)
@test output ≈ [0.5946059999999997, 0.595008, 0.594897]


task = Val{Symbol("outcar")}
subtask = Val{Symbol("read")}

args = Dict{String, Any}("v"=>false, "p" => path_recursive, "outcar" => "OUTCAR", "par" => "TOTEN", "N" => "0", "o"=>"none", "r"=>true, "method"=>"none") 

output = @capture_out run_task_recursive(task, subtask, args)

@test output == "The value in ENCUT_250 is: -8.25135668\nThe value in ENCUT_300 is: -8.25251696\nThe value in ENCUT_350 is: -8.25259894\n"
        