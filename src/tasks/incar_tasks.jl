"""
list of available tasks:

incar
    set/add: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
    rm: remove a certain tag or block from the INCAR file.
    read: read the value of a certain INCAR tag and print it
    make: create an INCAR file with certain tags or blocks in it
    whatis: return the default comment for an INCAR tag.
"""



"""
# CLI Commands to work with the INCAR file
The following command can be used to create, modify or retrieve information from an INCAR file.

Available commands:
* `vamp incar make`: Create an INCAR file.
* `vamp incar read`: Read key,value pairs from an INCAR file.
* `vamp incar whatis`: Display information about INCAR tags.
* `vamp incar set`: Add/change values of INCAR tags.
* `vamp incar rm`: Remove an INCAR tag.
"""
run_task(::Type{Val{:incar}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp [-r] incar make [--par <key(s)>] [--val <key(s)>] [--block <block_label>] [--p <path>] [--incar <file>]

Create a new INCAR file with specified parameters or blocks. If no values are provided, default values are used.

# Arguments
- `par`: Name of the tag(s) to include in the INCAR file. Multiple tags are separated by commas.
- `val`: Values for the tag(s). Multiple values are separated by commas.
- `block`: Block label to include in the INCAR file, with all associated default parameters. Multiple blocks are separated by commas.
- `p`: Sets the path where the INCAR file will be created (optional).
- `incar`: Name of the INCAR file to be created (optional; default is "INCAR").

# Behavior
- If `par` is provided, the function creates a new INCAR file with the specified parameters, each initialized with their default values.
- If `block` is provided and `par` is not, the function creates a new INCAR file containing the specified block(s), with all associated default parameters.
- The resulting INCAR file is saved to the specified path or the current working directory.

# Examples
```bash
# Example 1: Create a new INCAR file with default values for ENCUT and ISMEAR.
vamp incar make --par ENCUT,ISMEAR

# Example 2: Create a new INCAR file with a Parallelization block containing the default parameters 'KPAR' and 'NCORE'.
vamp incar make --block Parallelization

# Example 3: Create a new INCAR file in a specific directory with set values for EDIFF and LREAL.
vamp incar make --par EDIFF,LREAL --val 1e-5,False --p /path/to/dir
```
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:make}}, args)
    incar = get_empty_incar()
    if length(args["par"]) > 0
        keys = split_line(args["par"], char=',')
        values = length(args["val"]) > 0 ? split_line(args["val"], char=',') : [get_default_for_keyword(key) for key in keys]
        for (key, value) in zip(keys, values)
            set_key!(incar, key, value, block_label=args["block"])
        end
    elseif length(args["block"]) > 0
        add_incar_block!(split_line(args["block"], char=','), incar)
    end
    write_incar(incar, args["p"]*args["incar"])
end

"""
    vamp [-r] incar read --par <key(s)> [--p <path>] [--incar <file>]

Read and display the value(s) of specified parameter(s) from an INCAR file.

# Arguments
- `par`: Name of the tag(s) to read from the INCAR file. Multiple tags are separated by commas.
- `p`: Sets the path where the INCAR file is located (optional).
- `incar`: Name of the INCAR file to read (optional; default is "INCAR").

# Behavior
- The function reads the specified INCAR file and prints the values of the provided parameters.
- If multiple parameters are specified, the values for each parameter are printed sequentially.

# Examples
```bash
# Example 1: Read the value of the ENCUT parameter from the INCAR file in every subfolder.
vamp -r incar read --par ENCUT

# Example 2: Read the values of the ISMEAR and SIGMA parameters from an INCAR file located in a folder named 'bands'.
vamp incar read --par ISMEAR,SIGMA --p bands

# Example 3: Read the value of the EDIFF parameter from a custom INCAR file named 'INCAR_relax'.
vamp incar read --par EDIFF --incar INCAR_relax
```
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:read}}, args)
    incar = read_incar(args["p"]*args["incar"])
    for key in split_line(args["par"], char=',')
        value = findvalue(incar, key)
        println("The value of $key is: $value")
    end
end

"""
    vamp incar whatis --par <key>

Retrieve and display information about a specific INCAR or Wannier90 parameter.

# Arguments
- `par`: Name of the parameter or keyword to look up.

# Behavior
- If the parameter belongs to Wannier90, the function displays a message describing the parameter.
- If the parameter belongs to VASP, the function displays a message describing the parameter and provides a URL to the VASP wiki for more detailed information.

# Examples
```bash
# Example 1: Get information about the ENCUT parameter in the INCAR file.
vamp incar whatis --par ENCUT

# Example 2: Get information about the LCHARG parameter.
vamp incar whatis --par LCHARG

# Example 3: Get information about a Wannier90 parameter like 'num_wann'.
vamp incar whatis --par num_wann
```

# Aliases
* `vamp whatis`
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:whatis}}, args)
    param = args["par"]
    if iswannier90key(param)
        println("The $param keyword ", get_comment(param), ".")
    else
        println("The $param keyword ", get_comment(param), " (see https://www.vasp.at/wiki/index.php/$param for more info).")
    end
end
run_task(::Type{Val{:whatis}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("whatis")}, args)

"""
    vamp [-r] incar set --par <key(s)> --val <value(s)> [--p <path>] [--incar <file>] [--block <block_label>] [--out <file>]

Read a given incar file and add or change a tag to a certain value. Can also be used to add entire blocks with default values.

# Arguments
- `r`: Task is applied recursively to INCAR files in all subfolders.
- `par`: Name of the tag(s). Multiple tags are separated by commas.
- `val`: Value of the tag(s). Multiple tags are separated by commas.
- `p`: Sets the path where the command is executed.
- `incar`: Name of the INCAR file.
- `block`: Block label within the INCAR file where the tag is placed. If `par` is not given, the block will be added with default values. Multiple blocks are separated by commas.
- `out`: Sets the name of the modified INCAR file (default=INCAR).

# Examples
```bash
# Example 1: Set the value of the cut-off energy to 300 eV.
vamp incar set --par ENCUT --val 300

# Example 2: Change the smearing to Gaussian smearing and change sigma to 0.1 eV. The INCAR is located in a folder named 'bands'.
vamp incar set --par ISMEAR,SIGMA --val 0,0.01 --p bands

# Example 3: Add a block 'Parallelization' that contains the default parameters 'KPAR' and 'NCORE'.
vamp incar set --block Parallelization

# Example 4: Change the energy difference for electronic convergence in the INCAR in every subfolder
vamp -r incar set --par EDIFF --val 1e-5
```

# Aliases
* `vamp setincar`
* `vamp incar add`
* `vamp addincar`
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:set}}, args)
    if length(args["par"]) > 0
        set_key_in_incar(split_line(args["par"], char=','), split_line(args["val"], char=','), args["p"]*args["incar"], out=args["p"]*args["incar"], block_label=args["block"])
    elseif length(args["block"]) > 0
        add_block_to_incar(split_line(args["block"], char=','), args["p"]*args["incar"])
    end
end
run_task(::Type{Val{:setincar}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
run_task(::Type{Val{:incar}}, ::Type{Val{:add}}, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)
run_task(::Type{Val{:addincar}}, subtask, args) = run_task(Val{Symbol("incar")}, Val{Symbol("set")}, args)

"""
    vamp [-r] incar rm --par <key(s)> [--p <path>] [--incar <file>] [--block <block_label>] [--out <file>]

Read a given INCAR file and remove a specified tag or an entire block of tags.

# Arguments
- `r`: Task is applied recursively to INCAR files in all subfolders.
- `par`: Name of the tag(s) to remove. Multiple tags are separated by commas.
- `p`: Sets the path where the command is executed.
- `incar`: Name of the INCAR file.
- `block`: Block label within the INCAR file to remove. If `par` is not given, the entire block will be removed. Multiple blocks are separated by commas.
- `out`: Sets the name of the modified INCAR file (default=INCAR).

# Examples
```bash
# Example 1: Remove the cut-off energy tag from the INCAR file.
vamp incar rm --par ENCUT

# Example 2: Remove the ISMEAR and SIGMA tags from an INCAR file located in a folder named 'bands'.
vamp incar rm --par ISMEAR,SIGMA --p bands

# Example 3: Remove the 'Parallelization' block from the INCAR file, removing all associated tags like 'KPAR' and 'NCORE'.
vamp incar rm --block Parallelization

# Example 4: Remove the energy difference for electronic convergence tag (EDIFF) from the INCAR in every subfolder.
vamp -r incar rm --par EDIFF
```

# Aliases
* `vamp rmincar`
"""
function run_task(::Type{Val{:incar}}, ::Type{Val{:rm}}, args)
    if length(args["par"]) > 0
        remove_key_from_incar(args["par"], args["p"]*args["incar"], out=args["p"]*args["incar"])
    elseif length(args["block"]) > 0
        remove_block_from_incar(args["block"], args["p"]*args["incar"])
    end
end
run_task(::Type{Val{:rmincar}}, subtask, args) = run_task(Val{Symbol("rm")}, Val{Symbol("incar")}, args)