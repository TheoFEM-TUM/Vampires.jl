"""
list of available tasks:


<task>:
    plot: call the read task for `file` and create a plot.
"""


"""
# CLI Commands to plot value from a file

Available commands:
* `vamp <task> plot`: plot values from `vamp <task> read`
"""
run_task(::Type{Val{:file}}, ::Type{Val{:plot}}, args) = nothing

"""
    vamp [-r] <task> plot [--par <param>] [--xdata <xkey>] [--ydata <ykey>] [--xlabel <xlabel>] [--ylabel <ylabel>] [--o <filename>]

Call the read task to read the contents from `task` and plot them. If output file is neither `png` or `pdf` the plot will be printed to stdout.

# Arguments
- `task`: Specifies the type of file to be read, such as `eigenval`, `outcar`, or `poscar`.
- `par`: (Optional) Parameter to filter or specify certain settings in the `read` task.
- `xdata`: (Optional) Key to select the data column for the x-axis. If not provided, defaults to the first available data column.
- `ydata`: Key to select the data column for the y-axis. Required if there is more than one data column.
- `xlabel`: (Optional) Label for the x-axis of the plot. If not provided, defaults to the name of the x-data column.
- `ylabel`: (Optional) Label for the y-axis of the plot. If not provided, defaults to the name of the y-data column.
- `o`: (Optional) Output file name for saving the plot. Accepted formats are `png` and `pdf`. If omitted, the plot will be printed directly to stdout.
- `reduce`: (Optional) Specifies a method that is applied to the data an in task output.

# Examples
```bash
# Example 1: Plot the temperature for each time step of an MD run
vamp outcar plot --par temperature --xlabel Iteration --ylabel "Temperature (eV)" --o temp_vs_iter

# Example 2: Plot the pDOS for all orbitals projected onto Pb
vamp doscar plot --par pdos --ydata Pb --xdata energy --xlabel "Energy (eV)" --ylabel "pDOS (arb. u.)" --o pb_pdos

# Example 3: From a convergence run, plot the total energy versus ENCUT
vamp outcar plot --par "free  energy" --xlabel "ENCUT (eV)" --ylabel "Total energy (eV)"
```
"""
function run_task(task, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    set_backend(output_filename)

    out = run_task(task, Val{Symbol("read")}, args)
    broadcasted = args["reduce"][end] == '.' ? Val{Symbol("broadcasted")} : nothing
    out = reduce_output(out, Val{Symbol(strip(args["reduce"], '.'))}, broadcasted)
    xdata, ydata, xlabel, ylabel = get_plotting_data(out, args)
    fig = make_plot(xdata, ydata, title=args["title"], xlabel=xlabel, ylabel=ylabel)
    output_plot(fig, output_filename)
    return nothing
end

function run_task_recursive(task, ::Type{Val{:plot}}, args)
    output_filename = args["o"]
    set_backend(output_filename)

    out = run_task_recursive(task, Val{Symbol("read")}, args)
    broadcasted = args["reduce"][end] == '.' ? Val{Symbol("broadcasted")} : nothing
    out = reduce_output(out, Val{Symbol(strip(args["reduce"], '.'))}, broadcasted)
    xdata, ydata, xlabel, ylabel = get_plotting_data(out, args)
    fig = make_plot(xdata, ydata, title=args["title"], xlabel=xlabel, ylabel=ylabel)

    output_plot(fig, output_filename)
    return nothing
end