"""
list of available tasks:

w90_hr
    read: read the W90 Hamiltonian from the *_hr.dat file
"""

function run_task(::Type{Val{:w90_hr}}, ::Type{Val{:read}}, args)
    input_filename = args["w90_hr"]
    output_filename = args["o"] == "none" ? "w90_hr.h5" : args["o"]
    Hr, Rs, deg = read_hrdat(input_filename)
    if occursin("h5", output_filename)
        write_data_to_hdf5(output_filename, ["Hr", "Rs", "degeneracies"], [Hr, Rs, deg])
    else
        throw("Unknown output file format.")
    end
end
