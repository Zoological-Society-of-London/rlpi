#' plot_lpi
#'
#' @param index - The index to plot
#' @param REF_YEAR - The reference year of the plot (index == 1)
#' @param PLOT_MAX - The max y-value of the plot
#' @param CI_FLAG - whether confidence intervals are to be plotted
#' @param lowerCI - lower confidence interval values
#' @param upperCI - upper confidence interval values
#' @param col - The color of the plot. Default is "black"
#'
#' @export
#'
plot_lpi <- function(index, REF_YEAR, PLOT_MAX, CI_FLAG=0, lowerCI=0, upperCI=0, col="black") {
  # plot the data
  Year <- seq(REF_YEAR, (REF_YEAR + length(index)) - 1)
  plot(Year, index, xlim = c(REF_YEAR, PLOT_MAX), ylim = c(0, 2), ylab = paste("Index (", REF_YEAR, "= 1.0)", sep=""), col=col)
  #plot(Year, index, xlim = c(REF_YEAR, PLOT_MAX), ylab = paste("Index (", REF_YEAR, " = 1.0)", sep=""))
  zeroEffectLine <- rep(1, (length(index)))
  lines(Year, zeroEffectLine, col="black")
  lines(Year, index, col=col)

  if (CI_FLAG == 1) {
    lines(Year, lowerCI, col=col)
    lines(Year, upperCI, col=col)
  }
}
