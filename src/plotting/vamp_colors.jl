"""
Define colorblind perceivable colors based on https://jfly.uni-koeln.de/color/#pdf

# List of color names
- `orange`
- `blue`
- `yellow`
- `green`
- `purple`
- `sky_blue`
- `vermilion`
- `black`

# Example
```julia
mycolor = vcolors.blue
```
or
```
mycolor = vcolors[:yellow]
```
"""
const vcolors = (
    orange = RGB(0.90, 0.60, 0.0),
    blue = RGB(0.0, 0.45, 0.70),
    yellow = RGB(0.95, 0.90, 0.25),
    green = RGB(0.0, 0.60, 0.50),
    purple = RGB(0.80, 0.60, 0.70),
    sky_blue = RGB(0.35, 0.70, 0.90),
    vermilion = RGB(0.80, 0.40, 0.0),
    black = RGB(0.0, 0.0, 0.0)
)

"""
    create_color_getter(vcolors::Vector)

Creates a color-cycling mechanism that iterates through a given list of colors in `vcolors`.

This function returns two closures:
1. `autocolor`: Retrieves the next color from the list in sequence. It wraps around to the
   beginning after reaching the last color, ensuring infinite cycling.
2. `resetcolor`: Resets the sequence so that the next call to `get_color` starts from the
   first color in the list.

# Returns
- `autocolor::Function`: A function that returns the next color in sequence.
- `resetcolor::Function`: A function to reset the sequence to start from the first color.
"""
function create_color_getter()
    index = 0
    function autocolor()
        index = mod(index, length(vcolors)) + 1
        return vcolors[index]
    end
    function resetcolor()
        index = 0
    end
    return autocolor, resetcolor
end

# Assign the closure to a global constant
const autocolor, resetcolor = create_color_getter()