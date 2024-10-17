"""
    read_eigenval(file::AbstractString, nmax::Int=1000000)

Read the `EIGENVAL` VASP output file and extract the k-points and energy bands.

# Arguments
- `file::AbstractString`: The path to the `EIGENVAL` file.
- `nmax::Int=1000000`: The maximum number of bands to read. Default is 1,000,000.

# Returns
- `kpoints::Array{Float64, 2}`: A 3 x nkpts array where each column represents a k-point.
- `E_bands::Array{Float64, 2}`: An nbands x nkpts array of energy bands.
"""
function read_eigenval(file::AbstractString, nmax::Int=1000000)
    lines = open_and_read(file)
    lines = split_lines(lines)
    meta = Dict{String, Float64}()
    @views begin
        nelec = parse(Int64, lines[6][1]); meta["nelec"] = nelec
        nkpts = parse(Int64, lines[6][2]); meta["nkpts"] = nkpts
        nbands = parse(Int64, lines[6][3]); meta["nbands"] = nbands
        meta["temp"] = parse(Float64, lines[3][1])
        nbands = min(nmax, nbands)
        empty_lines = [i for (i, line) in enumerate(lines) if isempty(line)]
        E_bands = zeros(nbands, nkpts)
        kpoints = zeros(3, nkpts)
        occs = zeros(nbands, nkpts)
        for (k, i) in enumerate(empty_lines)
            kpoints[:, k] = parse.(Float64, lines[i+1][1:3])
            for j in 1:nbands
                @inbounds E_bands[j, k] = parse(Float64, lines[i+1+j][2])
                @inbounds occs[j, k] = parse(Float64, lines[i+1+j][3])
            end
        end
    end
    return kpoints, E_bands, occs
end

"""
    write_eigenval_to_hdf5(input_filename::String, output_filename::String)

Read k-points, energy eigenvalues, and band occupations from an EIGENVAL file and store or append them into an HDF5 file.

# Arguments:
- `input_filename::String`: The path to the input file (EIGENVAL) from which k-points, energy eigenvalues, and occupations will be extracted.
- `output_filename::String`: The path to the output HDF5 file where the data will be saved.

# Functionality:
1. This function reads the k-points, energy eigenvalues, and band occupations from the `input_filename` using the `read_eigenval` function.
2. It then writes or appends these datasets (`kpoints`, `eigenvalues`, and `occupations`) into the HDF5 file specified by `output_filename`.
   - If the dataset (e.g., `kpoints`, `eigenvalues`, or `occupations`) does not already exist in the HDF5 file, it will be created.
   - If the dataset already exists in the HDF5 file:
     - If the dataset is a 2D matrix, it will be converted into a 3D matrix, where the third dimension represents new data batches.
     - If the dataset is already a 3D matrix, new data will be appended along the third dimension.
3. The HDF5 file is opened in `"cw"` mode, meaning the data is written in a way that allows modification of the file. If an HDF5 dataset with the same name already exists, it will be deleted and replaced with the new data.
"""
function write_eigenval_to_hdf5(input_filename, output_filename)
    kp, Es, occs = read_eigenval(input_filename)
    h5open(output_filename, "cw") do file
        for (data_key, data_values) in zip(["kpoints", "eigenvalues", "occupations"], [kp, Es, occs])
            if haskey(file, data_key)
                current_size = size(file[data_key])
                if length(current_size) == 2
                    new_data_values = zeros(eltype(data_values), current_size[1], current_size[2], 2)
                    copyto!(new_data_values[:, :, 1], file[data_key])
                    new_data_values[:, :, 2] .= data_values
                    delete_object(file, data_key)                    
                    file[data_key] = new_data_values
                else
                    new_data_values = zeros(eltype(data_values), current_size[1], current_size[2], current_size[3]+1)
                    copyto!(new_data_values[:, :, 1:end-1], file[data_key])
                    new_data_values[:, :, end] .= data_values
                    delete_object(file, data_key) 
                    file[data_key] = new_data_values
                end
            else
                h5write(output_filename, data_key, data_values)
            end
        end
    end
end