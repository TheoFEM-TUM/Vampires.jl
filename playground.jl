using VaspTools, BenchmarkTools, Plots




@time blocks = read_incar("test/tasks/param_test/INCAR")

@show blocks


blocks
@time set_keyword!("ENCUT", "400", blocks)
@time write_incar(blocks, "INCAR2")
@show blocks

kp, Es, occs = read_eigenval("test/test_files/EIGENVAL_gaas")

VaspTools.get_bandgap("test/test_files/EIGENVAL_gaas")


xdatcar = read_xdatcar("test/test_files/XDATCAR_gaas")
@show xdatcar.lattice
write_to_file(xdatcar.configs, "test/test_files/configs_gaas_correct")

Es == VaspTools.read_from_file("Es_correct.dat")

@show occs[:, 1]

band_plot = plot(title="Band Structure", xlabel="k-point index", ylabel="Energy (eV)", legend=false)
for i in axes(Es, 1)
    plot!(band_plot, 1:80, Es[i, :])
end
display(band_plot)

#display()