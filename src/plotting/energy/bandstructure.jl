function plot_bandstructure(Es, kp, output_filename)
    # TODO: add dictionary for HS points and paths
    band_plot = plot(title="Band Structure", xlabel="k-point distance", ylabel="Energy (eV)", legend=false)
    k_dist = cumsum(hcat(0.0, sqrt.(sum(diff(kp, dims=2).^2, dims=1))), dims=2)
    for i in 1:size(Es)[1]
        plot!(band_plot, k_dist[1, :], Es[i, :])
    end
    savefig(output_filename)
end

function plot_bandstructure_dos(Es, kp, output_filename)
    @warn "plot_bandstructure_dos is not yet implemented"
    return 0
    # TODO: implement
    band_plot = plot(title="Band Structure", xlabel="k-point distance", ylabel="Energy (eV)", legend=false)
    k_dist = cumsum(hcat(0.0, sqrt.(sum(diff(kp, dims=2).^2, dims=1))), dims=2)
    for i in 1:size(Es)[1]
        plot!(band_plot, k_dist[1, :], Es[i, :])
    end
    savefig(output_filename)
end