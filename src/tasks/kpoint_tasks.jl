"""
list of available tasks:

kpoints
    make: generate a kpoint file for a certain grid size or kspacing, respectively.
"""



"""
# CLI Commands to work with the KPOINTS file
The following command can be used to work with the KPOINTS file.

Available commands:
* `vamp kpoints make`: Create a KPOINTS file.
"""
run_task(::Type{Val{:kpoints}}, ::Type{Val{:none}}, args) = nothing

"""
    vamp kpoints make [--par <parameter>] [--val <value>] [--N <N1,N2,N3>] [--poscar <file>] [--method <name>] [--o <file>]

Generate a KPOINTS file based on specified parameters or a predefined k-grid.

# Arguments
- `par`: (Optional) Specifies the parameter for generating the k-grid. If set to `KSPACING`, the function will use the provided `val` to determine the k-spacing.
- `val`: (Optional) The value corresponding to the `par` parameter. If `par` is `KSPACING`, this value is used to set the k-spacing for the k-grid.
- `N`: (Optional) The number of k-points in each direction, specified as a comma-separated list (e.g., `10,10,10`). Used if `par` is not `KSPACING`.
- `poscar`: (Optional) Path to the POSCAR file used to determine the lattice parameters for k-point generation (optional; default is "POSCAR").
- `method`: (Optional) Defines the method to generate the k-point grid. Default is Gamma-centered, if first letter of method is "m", Monkhorst-Pack grid will be used instead.
- `o`: (Optional) Name of the output file where the KPOINTS data will be written. The default filename is "KPOINTS".

# Behavior
- If `par` is set to `KSPACING`, the function calculates the k-grid using the specified k-spacing value and writes the `KPOINTS` file accordingly. Requires `POSCAR`.
- If `par` is not provided or has a different value, the function directly writes a KPOINTS file using the specified number of k-points (`N`) in each direction.
- The `gamma_centered` option determines whether the k-grid is gamma-centered or generated as a Monkhorst-Pack grid.

# Examples
```bash
# Example 1: Generate a KPOINTS file with a k-spacing of 0.2 Å⁻¹ using gamma-centered grid and the POSCAR in `relax/POSCAR`.
vamp kpoints make --par KSPACING --val 0.2 --poscar relax/POSCAR

# Example 2: Generate a KPOINTS file with a Monkhorst-Pack k-grid of 10x10x10 points.
vamp kpoints make --N 10,10,10 --method Monkhorst-Pack
```
"""
function run_task(::Type{Val{:kpoints}}, ::Type{Val{:make}}, args)
    out = args["o"] == "none" ? "KPOINTS" : args["o"]
    gamma_centered = lowercase(args["method"]) == 'm' ? false : true
    if args["par"] == "KSPACING"
        kspacing = parse(Float64, args["val"])
        write_kpoints(kspacing, joinpath(args["p"], args["poscar"]), out=joinpath(args["p"], out), gamma_centered=gamma_centered)
    else
        Ns = parse.(Int64, split_line(args["N"], char=','))
        write_kpoints(Ns, out=joinpath(args["p"], out), gamma_centered=gamma_centered)
    end
    return nothing
end