# List of Available Tasks

```
calculation
    bandgap: returns the bandgap calculated from a eigenval file
```

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
set/add
    incar: changes or adds a parameter _par_ to a given value _value_ or adds a block to the incar
rm
    incar: remove a certain tag or block from the INCAR file.
read
    incar: read the value of a certain INCAR tag and print it
make
    incar: create an INCAR file with certain tags or blocks in it
whatis
    return the default comment for an INCAR tag.
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
    make: creates a bash script that runs vasp in a specific folder
```

```
strong_scaling
    cpu: create a folder structure with slurm files to analyze CPU scaling in VASP
        example: `strong_scaling cpu --N 1 --ncore 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file ./extended_parameter_file --block batch_file_cpu`
    gpu: create a folder structure with slurm files to analyze GPU scaling in VASP
        example: `strong_scaling gpu --N 1 --nsim 24,24,24,24 --kpar 1,2,3,4 --p ./ --ext_par_file ./extended_parameter_file --block batch_file_gpu`
    plot: collects and plots the scaling task output in the current directory and subdirectories; the option `--N` selects the n-th CPU scaling tasks that is compared to the GPU runs in a seperate plot
        example: `strong_scaling plot --N 2`

weak_scaling
    cpu: create a folder structure with slurm files to analyze weak CPU scaling in VASP
    gpu: create a folder structure with slurm files to analyze weak GPU scaling in VASP
```

```
run_script
    prepare: creates a bash script that runs vasp in a specific folder
slurm_script
    prepare: creates a slurm submission script based on the extemded configuration file
    parallelization parameters are set to the default - individual tuning necessary
    #TODO: make this dependent on NCORE and KPAR and find best slurm configuration
```

```
w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
```

