path = string(@__DIR__)*"/../test_files/"

path_recursive = path * "recursive/"

mkpath(path_recursive)

file = "EIGENVAL_gaas"

for folder in ["a", "b", "C"]
    mkpath(path_recursive*folder)
    cp(path*file, path_recursive*folder*"/$file", force=true)
end

task =Val{Symbol("calculate")}
subtask =Val{Symbol("bandgap")}

args = Dict{String, String}("p" => path_recursive, "eigenval" => "EIGENVAL_gaas") 
run_task(Val{Symbol("r")}, task, subtask, args)
run_task(Val{Symbol("rconv")}, task, subtask, args)


rm(path_recursive, recursive=true)
        