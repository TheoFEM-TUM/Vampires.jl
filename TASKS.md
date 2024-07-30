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
set/add
    incar: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
rm
    incar: remove a certain tag or block from the INCAR file.
read
    incar: read the value of a certain INCAR tag and print it
create
    incar: create an INCAR file with certain tags or blocks in it
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
### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

```

```
run_script
    creates a bash script that runs vasp in a specific folder
```

```
strong_scaling
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP

weak_scaling
    cpu: create a folder structure with slurm files to analyze weak CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze weak GPU scaling in VASP
```

