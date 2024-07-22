using Printf

function extract_first_docstring(filename::String)::String
    open(filename, "r") do file
        content = read(file, String)
        m = match(r"\"\"\"(\X*?)\"\"\"", content)
        return m !== nothing ? m.match : ""
    end
end

function update_tasks_md(task_dir::String, output_file::String)
    task_docstrings = String[]
    
    for file in readdir(task_dir)
        if endswith(file, ".jl")
            docstring = extract_first_docstring(joinpath(task_dir, file))
            if !isempty(docstring)
                docstring = chopsuffix(chopprefix(docstring, r"\"\"\"\X(.*?)\n\n"), r"\n\"\"\"")
                docstring = "```\n" * docstring * "\n```" 
                push!(task_docstrings, docstring)
            end
        end
    end

    open(output_file, "w") do file
        write(file, "# List of Available Tasks\n\n")
        for docstring in task_docstrings
            write(file, "$docstring\n\n")
        end
    end
end

task_dir = "src/tasks"
output_file = "TASKS.md"

update_tasks_md(task_dir, output_file)
