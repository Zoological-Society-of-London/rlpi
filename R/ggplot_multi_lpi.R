#' ggplot_multi_lpi
#'
#' @param lpis - The list of lpis to plot
#' @param names - The names of the lpis in the list
#' @param ylims - The ylims of each plot
#' @param xlims - the xlims of each plot
#' @param title - the title of the plots (same for all)
#' @param col - the RColorBrewer Set to use. Default is "Set2"
#' @param facet - Whether or not to 'facet' the plot (or overlay)
#' @param yrbreaks - The spacing between x-axis tick marks
#' @param lpi_breaks - The spacing between y-axis tick marks
#'
#' @return Returns the calculated plot
#' @export
#'
ggplot_multi_lpi <- function(lpis, names=NULL,
                             ylims=c(0, 2), xlims=NULL,
                             title="", col="Set2",
                             facet=FALSE, trans="identity",
                             yrbreaks = 5,
                             lpi_breaks = 0.2) {

  # Bit of a hack to avoid NOTE during R CMD check
  # Sets the variables used in ggplot2::aes to NULL
  years <- lpi <- group <- lwr <- upr <- NULL

  dfs <- data.frame(years=numeric(0), lpi=numeric(0), lwr=numeric(0), upr=numeric(0), group=character(0))

  if (is.null(names)) {
    names = LETTERS[1:length(lpis)]
  }
  for (i in 1:length(lpis)) {
    d <- cbind(lpis[[i]], group=names[i])
    df <- data.frame(years=as.numeric(as.character(rownames(d))), lpi=d$LPI_final, lwr=d$CI_low, upr=d$CI_high, group=d$group)
    dfs = rbind(dfs, df)
  }

  #print(dfs)
  g = ggplot2::ggplot(dfs, ggplot2::aes(x=years, y=lpi, group=group))+
    ggplot2::geom_hline(yintercept=1) +
    ggplot2::geom_line(ggplot2::aes(color=group), size=1) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin=lwr,ymax=upr, fill=group),alpha=0.5) +
    ggplot2::coord_cartesian(ylim=ylims, xlim=xlims) + ggplot2::theme_bw() +
    ggplot2::theme(text = ggplot2::element_text(size=16),
                   axis.text.x = ggplot2::element_text(size=8, angle = 90, hjust = 1)) +
    ggplot2::ggtitle(title) +
    ggplot2::scale_fill_brewer(palette=col) +
    ggplot2::scale_color_brewer(palette=col) +
    ggplot2::ylab("Index (1970 = 1)") +
    ggplot2::scale_y_continuous(trans=trans, breaks=seq(ylims[1], ylims[2], lpi_breaks)) +
    ggplot2::scale_x_continuous(breaks=seq(xlims[1], xlims[2], yrbreaks)) +
    ggplot2::theme(legend.position="right")


  if (facet) {
    g <- g + ggplot2::facet_grid( ~ group)
  }
  print(g)
}


