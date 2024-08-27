function plot_strong_scaling_bars(core_n, avg_time_scf_step_n; type="cpu", title="Strong scaling VASP", figure_filename="plot.png", xticks=string.(core_n))
    # Calculate speedup relative to the first element in avg_time_scf_step_n
    speedup = avg_time_scf_step_n[1] ./ avg_time_scf_step_n

    # Set the color and x-axis label based on the type
    bar_color = type == "gpu" ? vamp_colors["Bluish Green"] : type=="mixed" ? vcat([vamp_colors["Sky Blue"]], repeat([vamp_colors["Bluish Green"]], length(speedup)-1)) : vamp_colors["Sky Blue"]
    xlab = type == "gpu" ? "Number of GPUs" : type == "mixed" ? "" : "Number of Cores"

    p = plot_bars(core_n, speedup, xlab, "Speedup", bar_color, 0, maximum(speedup) * 1.2)

    # Add speedup text on top of each bar
    for (i, s) in enumerate(speedup)
        annotate!(1:length(core_n)[i], s, text("$(round(s, digits=1)) x", :black, :bottom, 10))
    end
    savefig(figure_filename)
end


function plot_strong_scaling_bars(core_n, core_avg_time_scf_step_n, gpu_n, gpu_avg_time_scf_step_n; type="mixed", title="Strong scaling VASP", figure_filename="plot.png", index=2)
    core_n = vcat([core_n[index]], gpu_n)
    avg_time_scf_step_n = vcat([core_avg_time_scf_step_n[index]], gpu_avg_time_scf_step_n)
    xticks = vcat(["CPU"], string.(core_n[2:end]) .* " GPU" )
    plot_strong_scaling_bars(core_n, avg_time_scf_step_n; type=type, title=title, figure_filename=figure_filename, xticks=xticks)
end
