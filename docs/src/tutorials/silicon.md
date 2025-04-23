# Silicon
In this tutorial, you will learn the basics of performing convergence tests for the simple but relevant material silicon. You can easily transfer the workflow to any material that you are interested in.

## Input files

To run a DFT calculation with VASP you will need the following input files:

* INCAR (main input file containing all arguments)
* POSCAR (defines lattice and atomic positions)
* POTCAR (file containing the pseudopotential)
* KPOINTS (contains the k-points to discretize the Brillouin zone)

We will consider silicon in the diamond crystal structure. Create a file `POSCAR` with the following content.
```
cubic diamond Si
5.43
 0.0    0.5     0.5
 0.5    0.0     0.5
 0.5    0.5     0.0
 Si
 2
Direct
  0.00  0.00  0.00
  0.25  0.25  0.25
```
Get a POTCAR for silicon, this comes with your VASP code.

## Converging important parameters

To obtain meaningful results from your calculations, it is essential to ensure that the total energy is converged with respect to two key parameters: the cut-off energy (specified by `ENCUT` in the `INCAR`) for plane waves and the size of the k-point grid (the `KPOINTS` file).

* The cut-off energy determines the maximum energy of plane waves included in the calculation, directly affecting the basis set size. A higher cut-off energy allows for a more accurate representation of the electronic states, but it also increases computational costs.
* Similarly, the k-point grid specifies how the Brillouin zone is sampled, which is critical for accurately describing periodic systems in reciprocal space. A finer k-point grid improves precision in the electronic properties but requires more computational resources.

By systematically varying these parameters and analyzing the resulting total energy values, we will identigy the convergence thresholds necessary to achieve reliable and meaningful results.

### Cut-off energy ENCUT

First, create a new folder for your ENCUT convergence and copy POTCAR and POSCAR into it.
```bash
mkdir encut_convergence && cp POTCAR POSCAR encut_convergence
```
Now, let's generate a basic INCAR file
```bash
vamp incar make --par ENCUT,EDIFF,KSPACING,ISMEAR,SIGMA,ISTART
```
Please familiarize yourself with every tag used by looking it up on the VASP wiki or via
```bash
vamp incar whatis --par <INCAR_TAG>
```

Let's optimize the cut-off energy first. You want to set different values and check whether the final value of the total energy is converged w.r.t. the cut-off energy.

```bash
vamp convergence make --par ENCUT --val 250,275,300,325,350,400
```
Next you want to generate a run script that executes VASP in every subfolder you just created.
```bash
vamp -r runscript make
```
After all runs have finished you can print out and plot the total energy for each cut-off energy.
```bash
vamp -r outcar read --par TOTEN
vamp -r outcar plot --par TOTEN --o total_energy_vs_cut_off
```

## K-point grid

Next, we will do the same for the KSPACING parameter. Start at a value of 0.5 and decrease it gradually using the same commands as for ENCUT. Note how the calculation becomes more expensive as you decrease KSPACING.
```bash
vamp -r outcar plot --par LOOP+ --o run_time_vs_cut_off
```

# Silicon bandstructure

To calculate the bandstructure of silicon, you will need to perform two DFT calculations. A self-consistent one to obtain a converged charge density and a non self-consistent one using the previously calculated charge density to only compute energy eigenvalues along a certain path through the Brillouin zone.

This path is also defined in a `KPOINTS_bands` file:
```
kpoints for bandstructure L-G-X-U K-G
 20
line
reciprocal
  0.50000  0.50000  0.50000    1
  0.00000  0.00000  0.00000    1

  0.00000  0.00000  0.00000    1
  0.00000  0.50000  0.50000    1

  0.00000  0.50000  0.50000    1
  0.25000  0.62500  0.62500    1

  0.37500  0.7500   0.37500    1
  0.00000  0.00000  0.00000    1
```

Using the converged `KPOINTS` file from before, the `INCAR`, `POSCAR` and `POTCAR` file, we can easily set-up the folder structure with
```bash
vamp nscf make --kpoints KPOINTS,KPOINTS_bands
```

Let's visualize the results! You can plot the bandstructure with
```bash
vamp eigenval plot --eigenval nscf/EIGENVAL
```