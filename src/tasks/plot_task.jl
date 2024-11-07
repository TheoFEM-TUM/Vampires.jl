"""
list of available tasks:


file:
    plot: call the read task for `file` and create a plot.
"""


"""
# CLI Commands to plot value from a file

Available commands:
* `vamp <task> plot`: plot values from `vamp <task> read`
"""
run_task(::Type{Val{:file}}, ::Type{Val{:plot}}, args) = nothing

"""
    vamp <task> plot [--par <param>] [--xdata <xkey>] [--ydata <ykey>] [--xlabel <xlabel>] [--ylabel <ylabel>] [--o <filename>]

Call the read task to read the contents from `task` and plot them. If output file is neither `png` or `pdf` the plot will be printed to stdout.

# Arguments
- `task`: Specifies the type of file to be read, such as `eigenval`, `outcar`, or `poscar`.
- `par`: (Optional) Parameter to filter or specify certain settings in the `read` task.
- `xdata`: (Optional) Key to select the data column for the x-axis. If not provided, defaults to the first available data column.
- `ydata`: Key to select the data column for the y-axis. Required if there is more than one data column.
- `xlabel`: (Optional) Label for the x-axis of the plot. If not provided, defaults to the name of the x-data column.
- `ylabel`: (Optional) Label for the y-axis of the plot. If not provided, defaults to the name of the y-data column.
- `o`: (Optional) Output file name for saving the plot. Accepted formats are `png` and `pdf`. If omitted, the plot will be printed directly to stdout.

# Examples
"""
function run_task(task, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    set_backend(output_filename)

    keys, values = run_task(task, Val{Symbol("read")}, args)
    # TODO: add reduce output
    
    y_data_index = findfirst(x->x==args["ydata"], keys)
    ydata = values[y_data_index]

    if length(args["xdata"]) > 0
        x_data_index = findfirst(x->x==args["xdata"], keys)
        xdata = values[x_data_index]
    end

    fig = make_plot(xdata, ydata, title=title, xlabel=xlabel, ylabel=ylabel)
    
    output_plot(fig, output_filename)
end

function run_task_recursive(task, ::Type{Val{plot}}, args)
    # TODO
end
