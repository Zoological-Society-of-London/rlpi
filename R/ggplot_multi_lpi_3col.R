#' ggplot_multi_lpi_3col
#'
#' @param lpis - the list of lpis to plot
#' @param names - names for each lpi in the list
#' @param title - the title of the plot (same for each)
#' @param col - the RColorBrewer color group to use. Default is "Blues"
#'
#' @return Returns the calculated plot
#' @export
#'
ggplot_multi_lpi_3col <- function(lpis, names, title="", col="Blues") {

  # Bit of a hack to avoid NOTE during R CMD check
  # Sets the variables used in ggplot2::aes to NULL
  years <- lpi <- group <- lwr <- upr <- NULL

  # plot the data
  yrbreaks = 5
  dfs <- data.frame(years=numeric(0), lpi=numeric(0), lwr=numeric(0), upr=numeric(0), group=character(0))

  for (i in 1:length(lpis)) {
    d <- cbind(lpis[[i]], group=names[i])
    df <- data.frame(years=as.numeric(as.character(rownames(d))), lpi=d$LPI_final, lwr=d$CI_low, upr=d$CI_high, group=d$group)
    dfs = rbind(dfs, df)
  }

  colours = RColorBrewer::brewer.pal(name=col, n=nlevels(as.factor(dfs$group)))
  names(colours) = rev(levels(as.factor(dfs$group)))

  ggplot2::ggplot(dfs, ggplot2::aes(x=years, y=lpi, group=group))+
    ggplot2::geom_hline(yintercept=1) +
    ggplot2::geom_line(ggplot2::aes(color=group), size=1) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin=lwr,ymax=upr, fill=group),alpha=0.8) +
    ggplot2::coord_cartesian(ylim=c(0,2)) + ggplot2::theme_bw() +
    ggplot2::theme(text = ggplot2::element_text(size=16), axis.text.x = ggplot2::element_text(size=8, angle = 90, hjust = 1)) +
    ggplot2::ggtitle(title) +
    ggplot2::scale_fill_manual(values=colours) +
    ggplot2::scale_color_manual(values=colours) +
    ggplot2::facet_grid(. ~ group) +
    ggplot2::labs(aesthetic="CPI Group") +
    ggplot2::scale_x_continuous(breaks = as.numeric(df$years)[c(TRUE, rep(FALSE, yrbreaks-1))]) +
    ggplot2::facet_wrap( ~ group, ncol=3)

}
