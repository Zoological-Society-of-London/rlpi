#' ggplot_lpis
#'
#' @param lpis - The list of lpis to plot
#' @param names - the names of the each lpi in the list
#' @param title - the title of the plots (same for each)
#' @param col - The RColorBrewer set to use. Default is "Set2"
#' @param ylims - The ylims of the plot
#' @param trans - The transformation to apply to the y-axis. Default is 'identity' could be 'log'
#'
#' @return Returns the calculated plot
#'
ggplot_lpis <- function(lpis, names, title="", col="Set2", ylims=c(0.4, 2.5), trans="identity") {

  # Bit of a hack to avoid NOTE during R CMD check
  # Sets the variables used in ggplot2::aes to NULL
  years <- lpi <- group <- lwr <- upr <- NULL

  # plot the data
  yrbreaks = 5
  dfs <- data.frame(years=numeric(0), lpi=numeric(0), lwr=numeric(0), upr=numeric(0), group=character(0))

  d <- cbind(lpis, group=names)
  df <- data.frame(years=as.numeric(as.character(rownames(d))), lpi=d$LPI_final, lwr=d$CI_low, upr=d$CI_high, group=d$group)
  dfs = rbind(dfs, df)

  ggplot2::ggplot(dfs, ggplot2::aes(x=years, y=lpi, group=1))+
    ggplot2::geom_hline(yintercept=1) +
    ggplot2::geom_line(size=1) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin=lwr,ymax=upr),alpha=0.8, fill=col) +
    ggplot2::coord_cartesian(ylim=ylims) + ggplot2::theme_bw() +
    ggplot2::theme(text = ggplot2::element_text(size=16), axis.text.x = ggplot2::element_text(size=8, angle = 90, hjust = 1)) ++
    ggplot2::scale_y_continuous(limits = ylims, trans=trans) +
    ggplot2::scale_x_continuous(breaks = as.numeric(df$years)[c(TRUE, rep(FALSE, yrbreaks-1))])
}

