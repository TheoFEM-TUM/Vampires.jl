"""
    read_config(filename::String) -> Dict{String, Dict{String, String}}

Reads a configuration file and parses its contents into a nested dictionary.

# Arguments
- `filename::String`: The path to the configuration file.

# Returns
- `Dict{String, Dict{String, String}}`: A nested dictionary where the top-level keys are the section names and the values are dictionaries containing key-value pairs from the sections.

# Description
This function processes a configuration file with a specific format. The configuration file is expected to contain sections denoted by `begin section_name` and `end` markers. Each section contains key-value pairs separated by an equals sign (`=`).

The function performs the following steps:
1. Reads the input file and splits its content into lines.
2. Initializes an empty dictionary to store the configuration data.
3. Iterates over each line, identifying section starts and ends.
4. Within each section, extracts key-value pairs and stores them in a nested dictionary structure.

"""
function read_config(filename::String)::Dict{String, Dict{String, String}}
    # read the input file
    input_text = open_and_read(filename)
    # Split the input text into lines
    lines = split_lines(input_text, char=r", |, |,| ")

    # Initialize variables
    config_dict = Dict{String, Dict{String, String}}()
    current_section = ""

    # Iterate over each line
    for line in lines
        if length(line) == 0; continue; end
        # Check for section start
        if line[1] == "begin"
            # Extract section name
            current_section = line[2]
            config_dict[current_section] = Dict{String, String}()
        elseif line[1] == "end"
            current_section = ""
        elseif !isempty(current_section) && !isempty(line)
            key = line[1]
            value = line[2] == "=" ? join(line[3:end], ",") : join(line[2:end], ",")
            # Store key-value pair in the current section dictionary
            config_dict[current_section][key] = value
        end
    end
    return config_dict
end