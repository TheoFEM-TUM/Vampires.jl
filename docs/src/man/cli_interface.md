# CLI interface

* Change a specific parameter in the INCAR file: e.g., change the energy cutoff to 350 eV
```bash
vamp modify incar --par ENCUT --val 350
```

* Create a set of folders changing only one parameter: e.g., energy cutoff convergence testing
```bash
vamp convergence create --par ENCUT --val 300,350,400
```

* Or KSPACING
```bash
vamp convergence create --par KSPACING --val 0.5,0.4,0.3
```
