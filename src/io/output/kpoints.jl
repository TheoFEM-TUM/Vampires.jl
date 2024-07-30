"""
    write_kpoints(Ns::AbstractArray; gamma_centered=true, out="KPOINTS")

Generate a VASP KPOINTS file with the specified k-point grid.

# Arguments
- `Ns::AbstractArray`: An array or tuple of three integers `(Nx, Ny, Nz)` specifying the k-point grid in the x, y, and z directions.
- `gamma_centered::Bool`: A boolean flag indicating whether to use Gamma-centered (`true`) or Monkhorst-Pack (`false`) grid. Default is `true`.
- `out::String`: The output filename for the KPOINTS file. Default is `"KPOINTS"`.
"""
function write_kpoints(Ns::AbstractArray; gamma_centered=true, out="KPOINTS")
    Nx, Ny, Nz = Ns
    open(out, "w") do file
        println(file, "Automatic generation")
        println(file, "0")
        if gamma_centered
            println(file, "Gamma")
        else
            println(file, "Monkhorst-pack")
        end
        println(file, " $Nx $Ny $Nz")
        println(file, "  0  0  0")
    end
end

"""
    write_kpoints(kspacing::Float64, poscar_path::String="POSCAR"; gamma_centered::Bool=true, out::String="KPOINTS")

Generate a VASP KPOINTS file with a k-point grid determined by the kspacing parameter and the lattice vectors from a POSCAR file.

# Arguments
- `kspacing::Float64`: The desired k-point spacing.
- `poscar_path::String`: The file path to the POSCAR file containing the lattice vectors. Default is `"POSCAR"`.
- `gamma_centered::Bool`: A boolean flag indicating whether to use a Gamma-centered (`true`) or Monkhorst-Pack (`false`) grid. Default is `true`.
- `out::String`: The output filename for the KPOINTS file. Default is `"KPOINTS"`.
"""
function write_kpoints(kspacing::Float64, poscar_path="POSCAR"; gamma_centered=true, out="KPOINTS")
    poscar = read_poscar(poscar_path)
    Ns = convert_kspacing_to_kgrid(kspacing, poscar.lattice)
    write_kpoints(Ns, gamma_centered=gamma_centered, out=out)
end