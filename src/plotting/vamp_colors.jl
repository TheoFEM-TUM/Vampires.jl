"""
Define colorblind perceivable colors based on https://jfly.uni-koeln.de/color/#pdf

# List of color names
- `blue`
- `orange`
- `green`
- `yellow`
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
    blue = RGB(0.0, 0.45, 0.70),
    orange = RGB(0.90, 0.60, 0.0),
    green = RGB(0.0, 0.60, 0.50),
    yellow = RGB(0.95, 0.90, 0.25),
    purple = RGB(0.80, 0.60, 0.70),
    sky_blue = RGB(0.35, 0.70, 0.90),
    vermilion = RGB(0.80, 0.40, 0.0),
    black = RGB(0.0, 0.0, 0.0)
)

"""
    mutable struct ColorGetter

A mutable struct designed to track the current position in a sequence of colors. 

# Fields
- `index::Int64`: The current position in the color sequence.
"""
mutable struct ColorGetter
    index :: Int64
end

"""
    autocolor()

Each call returns the next color in the sequence `vcolors`, restarting from the beginning once all colors are used.

# Behavior
- Increments the `index` field of the `ColorGetter` instance, cycling back to `1` after reaching the end of the color list.
- Returns the color corresponding to the updated `index` from the global `vcolors` array.
"""
function (cg::ColorGetter)()
    cg.index = mod(cg.index, length(vcolors)) + 1
    return vcolors[cg.index]
end
const autocolor = ColorGetter(0)

"""
    resetcolor()

Resets the `autocolor` cycle to its initial state.
"""
resetcolor() = autocolor.index = 0