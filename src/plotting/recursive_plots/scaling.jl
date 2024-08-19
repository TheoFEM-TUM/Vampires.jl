function plot_strong_scaling_bars(core_n, avg_time_scf_step_n; type="cpu", title="Strong scaling VASP", figure_filename="plot.png", xticks=string.(core_n))
    # Calculate speedup relative to the first element in avg_time_scf_step_n
    speedup = avg_time_scf_step_n[1] ./ avg_time_scf_step_n

    # Set the color and x-axis label based on the type
    bar_color = type == "gpu" ? RGB(0.0, 0.60, 0.50) : type=="mixed" ? vcat([RGB(0.35, 0.70, 0.90)], repeat([RGB(0.0, 0.60, 0.50)], length(speedup)-1)) : RGB(0.35, 0.70, 0.90)
    x_label = type == "gpu" ? "Number of GPUs" : type == "mixed" ? "" : "Number of Cores"


    # Adjust x values for equidistant bars
    x_values = 1:length(core_n)

    # Create the bar plot
    p = bar(
        x_values,
        speedup,
        label = "",
        color = bar_color,
        xlab = x_label,
        ylab = "Speedup",
        tick_direction = :in,
        yticks = :auto,
        bar_width = 0.7,  # Make bars broader
        legend = false,
        xticks = (x_values, xticks),  # Replace x-axis ticks with core_n values
        framestyle = :box,  # Add a frame around the plot
        xmirror = false,  # Add axis to the top
        ymirror = false   # Add axis to the right

    )

    # Add speedup text on top of each bar
    for (i, s) in enumerate(speedup)
        annotate!(x_values[i], s, text("$(round(s, digits=1)) x", :black, :bottom, 10))
    end

    # Add plot title and customize ticks
    title!(title)
    ylims!(0, maximum(speedup) * 1.2)  # Adjust y-axis limits for better text visibility
    savefig(figure_filename)
end


function plot_strong_scaling_bars(core_n, core_avg_time_scf_step_n, gpu_n, gpu_avg_time_scf_step_n; type="mixed", title="Strong scaling VASP", figure_filename="plot.png", index=2)
    core_n = vcat([core_n[index]], gpu_n)
    avg_time_scf_step_n = vcat([core_avg_time_scf_step_n[index]], gpu_avg_time_scf_step_n)
    xticks = vcat(["CPU"], string.(core_n[2:end]) .* " GPU" )
    plot_strong_scaling_bars(core_n, avg_time_scf_step_n; type=type, title=title, figure_filename=figure_filename, xticks=xticks)
end
