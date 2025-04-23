# Supercells

## Generating supercells

Having a POSCAR file for a unit cell, you can use Vampires to generate a supercell with
```bash
vamp supercell make [--N 3,3,3]
```
where the `N` tag specifies how many times the unit cell is repeated in each direction.

## Sampling from an MD trajectory

You can also use Vampires to sample from an MD trajectory (XDATCAR), e.g., to perform self-consistent calculations on individual snapshots to compute optoelectronic properties with higher accuracy. The sample size is defined by the `N` keyword and the method for sampling (uniform or random) by the `method` keyword.
```bash
vamp supercell sample [--N 10] [--method random]
```