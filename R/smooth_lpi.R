#' smooth_lpi
#'
#' @param d - the index to smooth
#' @param N - The size of the smoothing window
#' @param smooth_type - Type of smoothing. Default is 'loess', otherwise uses boxcar with ends pinned
#'
#' @return The smoothed LPI
#' @export
#'
smooth_lpi <- function(d, N, smooth_type="loess") {

  smooth <- d

  if (smooth_type=="loess") {
    x_range <- 1:length(d$LPI_final)
    y.loess <- loess(d$LPI_final~x_range, span=0.25)
    smooth$LPI_final <- predict(y.loess, data.frame(x_range))

    y.loess <- loess(smooth$CI_low~x_range, span=0.25)
    smooth$CI_low <- predict(y.loess, data.frame(x_range))

    y.loess <- loess(smooth$CI_high~x_range, span=0.25)
    smooth$CI_high <- predict(y.loess, data.frame(x_range))

  } else {
    # Boxcar with end-points pinned
    smooth$LPI_final <- stats::filter(d$LPI_final, rep(1, N)/N, "convolution", sides=2)
    smooth$CI_low <- stats::filter(d$CI_low, rep(1, N)/N, "convolution", sides=2)
    smooth$CI_high <- stats::filter(d$CI_high, rep(1, N)/N, "convolution", sides=2)

    smooth$LPI_final[1] = d$LPI_final[1]
    smooth$LPI_final[length(d$LPI_final)] = d$LPI_final[length(d$LPI_final)]

    smooth$CI_low[1] = d$CI_low[1]
    smooth$CI_low[length(d$LPI_final)] = d$CI_low[length(d$LPI_final)]

    smooth$CI_high[1] = d$CI_high[1]
    smooth$CI_high[length(d$LPI_final)] = d$CI_high[length(d$LPI_final)]
  }
  return(smooth)
}




