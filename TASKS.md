# List of Available Tasks

```
calculation
    bandgap: returns the bandgap calculated from a eigenval file
```

```
convergence
    create: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
```

```
modify
    incar: changes a parameter _par_ to a given value _value_
```

```
plot
    bandstructure: plots the bandstructure
    dos: plots the density of states
```

```
Executes a specified task on all subdirectories of the current directory.

# Arguments
- `task::Function`: The main task function to run.
- `subtask::Function`: The subtask function to run within each folder.
- `args::Dict`: A dictionary of arguments to pass to the `task` function. The path for each subdirectory will be added to this dictionary with the key `"p"`.

# Description
This function scans the current directory for subdirectories. For each subdirectory found, it updates the `args` dictionary with the subdirectory path (under the key `"p"`) and then calls the `task` function with the specified `subtask` and the updated `args`.

The function assumes that the `task` function accepts the `subtask` function and an `args` dictionary as parameters, and that the `args` dictionary should include the path to the current subdirectory.
```

```
run_script
    creates a bash script that runs vasp in a specific folder
```

