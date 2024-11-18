using Colors
using Plots

"""
Define colorblind perceivable colors based on https://jfly.uni-koeln.de/color/#pdf
"""
vamp_colors = Dict(
    "black" => RGB(0.0, 0.0, 0.0),
    "orange" => RGB(0.90, 0.60, 0.0),
    "sky_blue" => RGB(0.35, 0.70, 0.90),
    "bluish_green" => RGB(0.0, 0.60, 0.50),
    "yellow" => RGB(0.95, 0.90, 0.25),
    "blue" => RGB(0.0, 0.45, 0.70),
    "vermilion" => RGB(0.80, 0.40, 0.0),
    "reddish_purple" => RGB(0.80, 0.60, 0.70)
)