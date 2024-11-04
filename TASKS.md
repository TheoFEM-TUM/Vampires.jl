# List of Available Tasks

```
convergence
    make: creates the folder structure where the specified parameter is changed in the different subdirectories
    read: reads a specific output (e.g., energy) from a convergence test
    plot: plots a specific output (e.g., TOTEN) vs folder seed (e.g., ENCUT)
```

```
doscar
    read: read-in the doscar file
    plot: plot the dos from the doscar file
```

```

eigenval:
    read: read the data from the eigenval file.
    plot: plot the bandstructure from the eigenval file.
```

```
incar
    set/add: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
    rm: remove a certain tag or block from the INCAR file.
    read: read the value of a certain INCAR tag and print it
    make: create an INCAR file with certain tags or blocks in it
    whatis: return the default comment for an INCAR tag.
```

```
kpoints
    make: generate a kpoint file for a certain grid size or kspacing, respectively.
```

```
supercell
    make: create a supercell POSCAR file from an existing POSCAR file
    sample: create folders that each contains one snapshot from an XDATCAR file and other VASP input files
```

```
nscf
    make: generate the folder structure for a scf->nscf calculation
```

```
outcar
    read: read a certain value from the outcar file
    plot: plot a series of values from an OUTCAR file. If recursive, plot one value from an OUTCAR file in multiple folders.
```

```
poscar
    read: read the POSCAR file
```

```
### recursive wrapper for all tasks:
any_task
    any_subtask: if the option `-r` is specified, the subtask will run in every subfolder of `./`

```

```
run
    make: creates a bash script that runs vasp in a specific folder
```

```
settings
    set: set a new setting in the settings file
    rm: remove a setting from the settings file
    read: read a setting from the settings file
```

```
"""
list of available tasks
```

```
w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
    test: test the accuracy of a W90 model versus DFT
w90
    set: set parameters in the INCAR file that are specific to W90
w90_nscf
    make: create the folder structure for a NSCF calculation with W90
```

