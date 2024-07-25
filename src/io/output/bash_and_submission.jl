"""
    write_run_script(vasp_exe, path; out="run_job.sh")

Writes a bash script to run VASP in specified folders. If the script already exists, it adds the new folder path to the `folders` array.

# Arguments
- `vasp_exe::String`: The command to execute the VASP program.
- `path::String`: The path to add to the `folders` array in the script.
- `out::String`: The output file name for the script. Defaults to `"run_job.sh"`.

# Description
This function creates a bash script named `run_job.sh` (or the name specified by `out`). If the file already exists, the function adds the specified `path` to the `folders` array within the existing script. 
If the file does not exist, it creates a new script with the necessary structure to run VASP in each folder specified in the `folders` array.
The script will iterate over each folder in the `folders` array, change to that directory, execute the VASP command, and then return to the parent directory.
"""
function write_run_script(vasp_exe, path; out="run_job.sh")
    if out in readdir()
        add_path_to_folders(out, path)
    else
        open(out, "a") do runfile
            println(runfile, "#!/bin/bash")
            println(runfile, "folders=(\"$path\")")
            println(runfile, "for folder in \"\${folders[@]}\"")
            println(runfile, "do")
            println(runfile, "    cd \$folder")
            println(runfile, "    srun $vasp_exe  > vasp.log")
            println(runfile, "    cd ..")
            println(runfile, "done")
        end
    end
    run(`chmod +x $out`)
end


"""
    add_path_to_folders(file::String, new_path::String)

Adds a new path to the `folders` line in a bash script file.

# Arguments
- `file::String`: The path to the bash script file (`run_job.sh`).
- `new_path::String`: The new path to add to the `folders` line.

# Description
This function reads the specified file line-by-line, looks for the line that defines the `folders` array 
(e.g., `folders=("path1" "path2")`), and adds the `new_path` to this array. The line will be modified to 
include the new path, and all other lines in the file will remain unchanged. The modified file is written 
back to the original file.
"""
function add_path_to_folders(file::String, new_path::String)
    lines = readlines(file)
    
    target_pattern = r"""folders=\((.*)\)"""
    
    open(file, "w") do f
        for line in lines
            if occursin(target_pattern, line)
                # Extract the existing paths
                captures = match(target_pattern, line).captures
                existing_paths = captures[1]
                
                # Add the new path to the list of existing paths
                new_folders_line = "folders=(" * existing_paths * " \"$new_path\")"
                
                write(f, new_folders_line * "\n")
            else
                write(f, line * "\n")
            end
        end
    end
end
