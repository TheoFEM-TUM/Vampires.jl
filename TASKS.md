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
incar
    set/add: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
    rm: remove a certain tag or block from the INCAR file.
    read: read the value of a certain INCAR tag and print it
    create: create an INCAR file with certain tags or blocks in it
    whatis: return the default comment for an INCAR tag. 
whatis
    return the default comment for an INCAR tag.
```

```
supercell
    create: create a supercell POSCAR file from an existing POSCAR file
```

```
plot
    bandstructure: plots the bandstructure
    dos: plots the density of states
```

```
prepare
    run_script: creates a bash script that runs vasp in a specific folder
    slurm_script: creates a slurm submission script based on the specified parallelization parameters
```

```
### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

```

