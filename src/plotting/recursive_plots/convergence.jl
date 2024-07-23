"""
    convergence_plot_value(param, path, output_filename)

Generates a convergence plot of a specified parameter from VASP OUTCAR files.

# Arguments
- `param::String`: The parameter to extract from the OUTCAR files.
- `path::String`: The base path where the folders containing OUTCAR files are located.
- `output_filename::String`: The filename for saving the generated plot.
"""
function plot_value_convergence(y_param, x_param, x_values, y_values, output_filename)
    plot(x_values, y_values, xlabel=y_param, ylabel=x_param)
    savefig(output_filename)
end