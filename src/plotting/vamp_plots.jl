function plot_bars(xval, yval, xlab, ylab, xticks, bar_color, ymin, ymax; title="")

  # Adjust x values for equidistant bars
  xval_equi = 1:length(xval)

  # Create the bar plot
  p = bar(
      xval_equi,
      yval,
      label = "",
      color = bar_color,
      xlab = xlab,
      ylab = ylab,
      tick_direction = :in,
      yticks = :auto,
      bar_width = 0.7,  # Make bars broader
      legend = false,
      xticks = (xval_equi, xticks),  # Replace x-axis ticks with core_n values
      framestyle = :box,  # Add a frame around the plot
      xmirror = false,  # Add axis to the top
      ymirror = false   # Add axis to the right

  )

  # Add plot title and customize ticks
  if title != ""; title!(title); end
  ylims!(ymin, ymax)  # Adjust y-axis limits for better text visibility

  return p
end