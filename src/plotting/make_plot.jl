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
    fig = plot(title=title, xlabel=xlabel, ylabel=ylabel, legend=false, framestyle=:box, tickfontsize=18, labelfontsize=18)
    if length(xdata) > 0
        if length(xdata) == length(ydata)
            for (x, y) in zip(xdata, ydata)
                y = check_transpose_for_plotting(y)
                x, y = check_sorting_for_plotting(x, y)
                colors = get_colors(y)
                plot!(fig, x, y, color=colors)
            end
        elseif length(xdata) == 1
            for y in ydata
                y = check_transpose_for_plotting(y)
                colors = get_colors(y)
                plot!(fig, xdata[1], y, color=colors)
            end
        else
            error("Invalid length of xdata $(length(xdata)) and ydata $(length(ydata))")
        end
    else
        for y in ydata
            y = check_transpose_for_plotting(y)
            colors = get_colors(y)
            plot!(fig, y, linecolor=colors)
        end
    end
    return fig
end

"""
    get_colors(y)

Returns a set of colors based on the input `y`.

# Arguments
- `y::AbstractMatrix`: A matrix or multidimensional array, where each column is treated as a separate series.
  
# Returns
- A `Matrix` of colors (for matrix input) or a single color (for non-matrix input).
"""
function get_colors(y)
    if y isa AbstractMatrix
        base_colors = [autocolor() for _ in axes(y, 2)]
        return cat([[base_colors[i] for _ in axes(y, 1)] for i in axes(y, 2)]..., dims=2)
    else
        return autocolor()
    end
end

"""
    get_plotting_data(out, args)

Extracts and prepares the data for plotting based on the provided `out` data and `args` parameters.

The function identifies `x` and `y` data for plotting based on keys in the `out` dictionary and the values in `args`. It then formats and returns the necessary data along with appropriate labels for the plot axes. It also handles default values for axis labels and can read additional data from folders if needed.

# Arguments
- `out::Dict`: A dictionary where the keys represent data names, and the values are the corresponding data to be plotted. The function checks for keys matching `xdata` and `ydata` specified in `args` to assign the data to `xdata` and `ydata` arrays, respectively.
  
- `args::Dict`: A dictionary of parameters that control the data extraction and labeling:
  - `"xdata"`: A string representing the key for `x` data in `out` (default: `""`).
  - `"ydata"`: A string representing the key for `y` data in `out` (default: `""`).
  - `"xlabel"`: A string representing the label for the x-axis (default: `"xdata"`).
  - `"ylabel"`: A string representing the label for the y-axis (default: `"ydata"`).
  - `"r"`: A boolean flag to read data from folders if `xdata` is empty (default: `false`).
  - `"p"`: A string representing the path where folder data can be read (only needed if `"r"` is `true`).

# Returns
- `xdata::Vector{T}`: A vector of data for the x-axis (type `T` will depend on the data extracted from `out`).
- `ydata::Vector{T}`: A vector of data for the y-axis (type `T` will depend on the data extracted from `out`).
- `xlabel::String`: The label for the x-axis.
- `ylabel::String`: The label for the y-axis.
"""
function get_plotting_data(out, args)
    xdata = []
    ydata = []

    ydata_key = args["ydata"] == "" ? args["par"] : args["ydata"]
    for (key, value) in pairs(out)
        if occursin(ydata_key, string(key)) && ydata_key ≠ ""
            push!(ydata, value)
        elseif occursin(args["xdata"], string(key)) && args["xdata"] ≠ ""
            push!(xdata, value)
        end
    end

    xlabel = args["xlabel"] == "" ? args["xdata"] : args["xlabel"]
    ylabel = args["ylabel"] == "" ? ydata_key : args["ylabel"]

    if args["r"] && length(xdata) == 0
        folders = readfolders(args["p"])
        xdata = push!(xdata, parse.(Float64, [split_line(folder, char='_')[end] for folder in folders]))
        xlabel = args["xlabel"] == "" ? split_line(folders[1], char='_')[1] : xlabel
    end
    return xdata, ydata, xlabel, ylabel
end

"""
    set_backend(output_filename)

Sets the plotting backend based on the specified output file format. This is currently just a placeholder.

# Arguments
- `output_filename` : A string representing the desired output file name. The backend is selected based on the file extension.
"""
function set_backend(output_filename)
    gr()
end

"""
    output_plot(fig, output_filename)

Outputs a plot to a file based on the specified `output_filename` (to be extended).

# Arguments
- `fig` : The plot object to be output or displayed.
- `output_filename` : A string specifying the output file name.
"""
function output_plot(fig, output_filename)
    savefig(fig, output_filename*".pdf")
end

"""
    check_transpose_for_plotting(A::AbstractMatrix)

Ensures that a matrix `A` is oriented appropriately for plotting purposes. 

If the number of rows in `A` is less than the number of columns, the matrix is transposed to make it taller rather than wider. Otherwise, the matrix is returned unchanged.

# Arguments
- `A::AbstractMatrix`: The input matrix to be checked and possibly transposed.

# Returns
- `AbstractMatrix`: The transposed matrix if `size(A, 1) < size(A, 2)`, otherwise the original matrix.
"""
function check_transpose_for_plotting(A::AbstractMatrix)
    if size(A, 1) < size(A, 2) 
        return transpose(A)
    else
        return A
    end
end
check_transpose_for_plotting(A) = A

function check_sorting_for_plotting(x::AbstractVector, y::AbstractVector)
    inds = sortperm(x)
    return x[inds], y[inds]
end
check_sorting_for_plotting(x, y) = x, y