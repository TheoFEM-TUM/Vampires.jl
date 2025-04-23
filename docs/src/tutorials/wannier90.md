# Wannier90
This tutorial covers how to use Vampires.jl for VASP+W90 calculations, focusing specifically on W90-related aspects. Prior knowledge of using Vampires with VASP is assumed. Additionally, to utilize the VASP+W90 interface, you must use a VASP executable compiled with W90 support.

## Preparing input files

Wannier90 inputs are stored as a string in the INCAR tag `WANNIER90_WIN`. To indicate that a tag belongs to W90 in Vampires, it has to be written in lowercase letters.
```bash
vamp incar set --par num_iter --val 0
```

## Auto energy windows

One of the greatest struggles of using W90—one that has driven many a researcher to the brink of madness—is setting the energy windows for band disentanglement. These deceptively simple parameters wield immense power, determining the very accuracy of the W90 Hamiltonian. Get them wrong, and W90 may crash spectacularly, leaving you staring at your terminal in despair.

But fear not! Vampires swoops in to save the day with an automated workflow that intelligently selects the energy windows with minimal effort on your part. Of course, should the forces of fate demand it, manual tweaking may still be necessary—but at least you'll have a fighting chance.

The workflow mirrors a band structure calculation: first, a self-consistent run (without W90) is performed to obtain a converged CHGCAR and determine the energy windows. Then, a non-self-consistent VASP+W90 calculation—optionally on a coarser k-grid—follows, yielding the W90 Hamiltonian. The `N` tag is used to set the minimal band index that should be considered by W90 (defaults to 1). This is especially necessary when using a POTCAR that includes core electron orbitals. 

Note that you need to load the Vampires module (in your job script) in order to use this workflow.
```bash
vamp w90_nscf make [--N 1]
```
Examine the `runscript.sh` file that was generated. There should be an additional line calling Vampires between VASP runs. This will set the energy windows for the second run given the energy eigenvalues of the first. It works in the following way: The disentanglement window ([dis_win_min, dis_win_max]) is defined as the lowest energy eigenvalue (depending on `N`) and the highest energy eigenvalue (depending on `N+Nbands-1`). The frozen window ([dis_froz_min, dis_froz_max]) is set to encompass only the valence bands.

## Testing the accuracy of your Wannier90 Hamiltonian

Now that Wannier90 has completed successfully, you might be wondering about the accuracy of the generated Hamiltonian—specifically, how well it reproduces the correct energy eigenvalues or band structure. You can use Vampire to quickly assess this. The `N` tag sets the minimum band index to be considered, and the `method` keyword determines how the error is computed.
```bash
vamp w90_hr test [--N 1] [--method rmse]
```

## Reading and storing outputs

Just like with VASP output files, you can use the `read` subtask to extract specific parameters. A few examples are shown below. These tasks can also be used recursively—for instance, for plotting or further postprocessing such as calculating mean values.

1. Hamiltonian data
```bash
vamp w90_hr read --o wannier90_hr.h5
```

2. Eigenvalues
```bash
vamp w90_hr read --par eigenvalues --o eigenvalues_w90.h5
```

2. Band gap
```bash
vamp w90_hr read --par bandgap --o eigenvalues_w90.h5
```