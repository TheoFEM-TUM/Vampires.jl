using Plots
# Define parameters
sigma = 0.1
E_grid = range(-10, stop=10, length=500)

# Read eigenvalues from file (replace with actual path to your EIGENVAL file)
kp, Es, occs = read_eigenval(test_file_path*"EIGENVAL_gaas")

# Compute DOS and Fermi level
dos, efermi = compute_dos(Es, occs, sigma, E_grid)

# Plot DOS
plot(E_grid, dos, xlabel="Energy (eV)", ylabel="DOS", title="Density of States")
vline!([0], label="Fermi Level", line=:dash)
savefig("DOS_plot.png")
rm("DOS_plot.png")