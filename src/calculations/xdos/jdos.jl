"""
implements jDOS as in Eq. 4.4 in
http://web.mit.edu/course/6/6.732/www/6.732-pt2.pdf



function step_approx(E_grid, Delta_e_skn, sigma)
    return (1/(sigma*sqrt(2*pi))) .* exp.(-(Delta_e_skn .- E_grid).^2 ./ (2*sigma^2))
end

sigma = 0.02
E_grid = range(0, stop=5, length=500)

kp, Es, occs = read_eigenval("test/test_files/EIGENVAL_gaas")

nk = length(kp)
ns = 1  # Assuming non-spin-polarized case
# TODO: get Fermi level from Fermi level script
e_skn = Es .- efermi

println(size(e_skn))
N_sk = sum(e_skn .< 0.0, dims=2)
println(N_sk)

result = Float64[]
for s in 1:ns
    for k in 1:nk
        for n1 in N_sk[1, 1]:size(e_skn, 2)
            for n2 in 1:N_sk[1, 1]
                push!(result, e_skn[s, k, n1] - e_skn[s, k, n2])
            end
        end
    end
end

println(minimum(result))
result_k = Array{Float64}(undef, nk, size(e_skn, 2), size(e_skn, 2))
for s in 1:ns
    for k in 1:nk
        for n1 in N_sk[1, 1]:size(e_skn, 2)
            for n2 in 1:N_sk[1, 1]
                result_k[k, n1, n2] = e_skn[s, k, n1] - e_skn[s, k, n2]
            end
        end
    end
end

weights = fill(1.0 / nk, nk)  # Placeholder for k-point weights, replace with actual weights

result_gauss = 2 .* sum([weights[k] .* step_approx(E_grid, result_k[k, n1, 1], sigma) for k in 1:nk, n1 in 1:size(result_k, 2)], dims=2)

CSV.write("JDOS_sigma-$sigma.dat", DataFrame(E_grid = E_grid, JDOS = sum(result_gauss, dims=1)'))

plot(E_grid, sum(result_gauss, dims=1)')
xlabel!("Energy (eV)")
ylabel!("JDOS")
title!("Joint Density of States")
savefig("JDOS_plot.png")


function compute_jdos(E_bands, occs, sigma, E_grid)


end


function calculate_jdos(filename::string, energy_range::Tuple, bins::int)
    kp, Es, occs = read_eigenval(filename)
    for i in range(energy_range[0], stop=energy_range[1], length=bins)
        
    end

end


"""