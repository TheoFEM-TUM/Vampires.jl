# CLI interface

* Change a specific parameter in the INCAR file: e.g., change the energy cutoff to 350 eV
```bash
vamp set --par ENCUT --val 350
```

* Create a set of folders changing only one parameter: e.g., energy cutoff convergence testing
```bash
vamp testpar --par ENCUT --val 300,350,400
```