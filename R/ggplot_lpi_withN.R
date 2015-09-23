#' Plots an index with the number of points contributing using ggplot (dataframe containing LPI_final, CI_low, CI_high, LPI=number of points)
#'
#' @param d - the dataframe containing colnames(LPI_final, CI_low, CI_high, LPI)
#' @param col - Color of plotted index
#' @param title - Title of plot
#' @param y_min - y_min of plot
#' @param y_max - y_max of plot
#'
#' @return Returns the calculated plot
#' @export
#'
ggplot_lpi_withN <- function(d, col="black", title="", y_min=0, y_max=2) {

  # Bit of a hack to avoid NOTE during R CMD check
  # Sets the variables used in ggplot2::aes to NULL
  Years <- LPI <- group <- lwr <- upr <- Count <- name <- r <- NULL

  df <- data.frame(years=as.numeric(as.character(rownames(d))), lpi=d$LPI_final, lwr=d$CI_low, upr=d$CI_high)

  grid::grid.newpage()

  # two plots
  p1 <- ggplot2::ggplot(data=df, ggplot2::aes(x=Years, y=LPI, group=1)) +
    ggplot2::geom_hline(yintercept=1) +
    ggplot2::geom_line(size=1) +
    ggplot2::geom_ribbon(data=df, ggplot2::aes(ymin=lwr,ymax=upr, group=1),alpha=0.3, fill=col) +
    ggplot2::scale_y_continuous(limits = c(0.0, 2.0)) + ggplot2::theme_bw() +
    ggplot2::theme(text = ggplot2::element_text(size=16), axis.text.x = ggplot2::element_text(size=8, angle = 90, hjust = 1),panel.grid.major=ggplot2::element_blank(),panel.grid.minor=ggplot2::element_blank()) +
    ggplot2::ylab("Index (1970=1.0)") +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = NA))

  p2 <- ggplot2::ggplot(data=df, ggplot2::aes(x=Years, y=LPI, group=1)) +
    ggplot2::geom_point(size = 3, alpha = 0.1, ggplot2::aes(y = Count), color="black") +
    ggplot2::scale_y_continuous(breaks = seq(0, max(Count), by = 250)) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = NA),
          panel.grid.major = ggplot2::element_blank(),
          panel.grid.minor = ggplot2::element_blank())

  # extract gtable
  g1 <- ggplot2::ggplot_gtable(ggplot2::ggplot_build(p1))
  g2 <- ggplot2::ggplot_gtable(ggplot2::ggplot_build(p2))

  # overlap the panel of 2nd plot on that of 1st plot
  pp <- c(subset(g1$layout, name == "panel", se = t:r))
  g <- gtable::gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t,
                       pp$l, pp$b, pp$l)

  # axis tweaks
  ia <- which(g2$layout$name == "axis-l")
  ga <- g2$grobs[[ia]]
  ax <- ga$children[[2]]
  ax$widths <- rev(ax$widths)
  ax$grobs <- rev(ax$grobs)
  ax$grobs[[1]]$x <- ax$grobs[[1]]$x - grid::unit(1, "npc") + grid::unit(0.15, "cm")
  g <- gtable::gtable_add_cols(g, g2$widths[g2$layout[ia, ]$l], length(g$widths) - 1)
  g <- gtable::gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)

  # draw it
  grid::grid.draw(g)
}
