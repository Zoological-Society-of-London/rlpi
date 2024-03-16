#' Plots an index using ggplot (dataframe containing LPI_final, CI_low, CI_high)
#'
#' @param d - the dataframe containing colnames(LPI_final, CI_low, CI_high)
#' @param col - Color of plotted index ribbon (confidence intervals)
#' @param line_col - Color of mean line of plotting index
#' @param title - Title of plot
#' @param ylims - ylim of plot
#' @param xlims - xlim of plot
#' @param trans - The y-axis transformation, default is 'identitiy', but could be 'log'
#' @param yrbreaks - The spacing between x-axis tick marks
#' @param lpi_breaks - The spacing between y-axis tick marks
#' @param xlab - The x axis label - defaults to "Years"
#' @param ylab - The y axis label - defaults to "Index (1970 = 1)"
#'
#' @return Returns the calculated plot
#' @export
#'
ggplot_lpi <- function(d, col="darkblue", line_col="white", title="",
                       ylims=c(0, 2.0), xlims=NULL, trans="identity",
                       yrbreaks = 5, lpi_breaks = 0.2,
                       xlab = "Years",
                       ylab = "Index (1970 = 1)") {

  df <- data.frame(years=as.numeric(as.character(rownames(d))), lpi=d$LPI_final, lwr=d$CI_low, upr=d$CI_high)
  if (is.null(xlims)) {
    xlims = c(min(df$years), max(df$years))
  }
  g <- ggplot2::ggplot(data=df, ggplot2::aes_string(x='years', y='lpi', group=1))

  if (!is.null(d$CI_low)) {
    g <- g + ggplot2::geom_ribbon(data=df, ggplot2::aes_string(ymin='lwr',ymax='upr', group=1), alpha=0.8, fill=col)
  }
  g <- g + ggplot2::geom_line(size=0.6, col=line_col)
  g <- g + ggplot2::geom_hline(yintercept=1, alpha=0.8)
  g <- g + ggplot2::coord_cartesian(ylim=ylims, xlim=xlims) + ggplot2::theme_bw()
  g <- g + ggplot2::theme(text = ggplot2::element_text(size=16), axis.text.x = ggplot2::element_text(size=8, angle = 90, hjust = 1))
  g <- g + ggplot2::scale_y_continuous(trans=trans, breaks = seq(ylims[1], ylims[2], lpi_breaks))
  g <- g + ggplot2::scale_x_continuous(breaks = seq(xlims[1], xlims[2], yrbreaks))
  g <- g + labs(title = title, x = xlab, y = ylab)
  print(g)
}
