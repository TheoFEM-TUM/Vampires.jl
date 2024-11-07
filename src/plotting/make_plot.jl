"""
    make_plot(xdata, ydata; title="", xlabel="", ylabel="")

Creates a plot using the provided `xdata` and `ydata` arrays. 

If `xdata` is non-empty, it is used as the x-axis data. If `xdata` is empty, `ydata` will be plotted as a function of its index.

# Arguments
- `xdata` : Array of x-axis data points. If empty, `ydata` is plotted against its index.
- `ydata` : Array of y-axis data points.
  
# Keyword Arguments
- `title` : Title of the plot. Default is an empty string (`""`).
- `xlabel` : Label for the x-axis. Default is an empty string (`""`).
- `ylabel` : Label for the y-axis. Default is an empty string (`""`).

# Returns
- `fig` : The plot object with the specified data and labels.
"""
function make_plot(xdata, ydata; title="", xlabel="", ylabel="")
    fig = plot(title=title, xlabel=xlabel, ylabel=ylabel, legend=false)
    if length(xdata) > 0
        plot!(xdata, ydata)
    else 
        plot!(ydata)
    end
    return fig
end

"""
    set_backend(output_filename)

Sets the plotting backend based on the specified output file format.

- If `output_filename` is `png` or `pdf`, the `GR` backend is selected.
- If `output_filename` is `tikz`, the `PGFPlotsX` backend is selected for creating LaTeX-compatible plots.
- Else, the `UnicodePlots` backend is used to display plots in the terminal.

# Arguments
- `output_filename` : A string representing the desired output file name. The backend is selected based on the file extension.
"""
function set_backend(output_filename)
    if occursin(".png", output_filename) && occursin(".pdf", output_filename)
        gr()
    elseif occursin(".tikz", output_filename)
        pgfplotsx()
    else
        unicodeplots()
    end
end

"""
    output_plot(fig, output_filename)

Outputs a plot to a file or displays it in the terminal (depends on backend), based on the specified `output_filename`.

# Arguments
- `fig` : The plot object to be output or displayed.
- `output_filename` : A string specifying the output file name.
"""
function output_plot(fig, output_filename)
    if occursin(".png", output_filename) || occursin(".pdf", output_filename) || occursin(".tikz", output_filename)
        savefig(fig, output_filenamename)
    else
        show(fig)        
    end
end