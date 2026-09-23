function plot_dos(dos, output_filename)
    dos_plot = plot(title="Density of States", xlabel="Energy (eV)", ylabel="DOS", legend=false)
    plot!(dos[1, :], dos[2, :])
    savefig(output_filename)
end
