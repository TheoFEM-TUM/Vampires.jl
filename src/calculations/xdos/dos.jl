# Function to compute DOS and Fermi level
function compute_dos(E_bands, occs, sigma, E_grid)
    # Flatten the eigenvalues for DOS calculation
    E_bands_flattened = vec(E_bands)

    efermi = get_fermi_energy(E_bands, occs)
    println(efermi)
    # E_bands_flattened .+= efermi
    # Compute DOS using Gaussian broadening
    # TODO: implement Lorentzian broadening as alternative
    dos = zeros(length(E_grid))
    for E in E_bands_flattened
        dos .+= (1/(sigma*sqrt(2*pi))) .* exp.(-(E_grid .- E).^2 ./ (2*sigma^2))
    end

    return dos, efermi
end