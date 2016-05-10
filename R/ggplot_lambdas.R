#' Plots annual lambdas
#'
#' @param lambda_values - the dataframe containing lambda values
#' @param col - Color of plotted points, default="red"
#' @param line_col - Color of error bars, default="blue"
#' @param title - Title of plot
#' @param baseline - baseline to show on plot, default=1
#' @param baseline_color - color of baseline, default="grey"
#' @param ylims - y_limits, default=c(0.9, 1.1)
#' @param xlims - y_limits, default=c(1970, 2014.5)
#' @param trans - y-axis transformation, default="identity", could be "log"
#' @param yrbreaks - The spacing between x-axis tick marks
#'
#' @return Returns the calculated plot
#' @export
#'
ggplot_lambdas <- function(lambda_values, col="red", line_col="blue", title="",
                           baseline=1, baseline_color = "grey",
                           ylims=c(0.9, 1.1), ybreaks=0.05,
                           xlims=c(1970, 2014.5), trans="identity",
                           yrbreaks = 5) {
  require(ggplot2)

  pd <- position_dodge(0.1)

  # Calculate means for each year
  mean_lambdas <- colMeans(lambda_values, na.rm = T)
  #mean_lambdas <- colMeans(lambda_values[, 2:46], na.rm = T)

  ## Calculate SEM
  # SEM function
  se <- function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x)))
  # Applied to columns
  #sem_lambdas <- apply(lambda_values[, 2:46],2, se)
  sem_lambdas <- apply(lambda_values,2, se)

  # Convert mean lambdas to dataframe
  mean_lambdas = data.frame(mean_lambdas)
  # Extract years from rownames
  years=as.numeric(substr(rownames(mean_lambdas), 2, 5))
  # Set year 1 to be NA
  mean_lambdas[1, ] = NA

  # Get means, and upper and lower CIs at the given baseline
  u_lambdas = baseline*10^(mean_lambdas)
  lower_limit = baseline*10^(mean_lambdas - 1.96*sem_lambdas)
  upper_limit = baseline*10^(mean_lambdas + 1.96*sem_lambdas)

  # Put it all together in a single data frame
  mean_limits <- data.frame(years=years,
                            mean_lambdas=u_lambdas,
                            lower_limit=lower_limit,
                            upper_limit=upper_limit)
  # Set names
  colnames(mean_limits) <- c("years", "mean_lambdas","lower_limit","upper_limit")

  # Make xlims if not given
  #if (is.null(xlims)) {
  #  xlims = c(min(mean_limits$years), max(mean_limits$years))
  #}


  # Plot points for means, bars for limits, line along baseline
  plot <- ggplot(mean_limits, aes(x=years, y=mean_lambdas)) +
    geom_hline(yintercept = baseline, col=baseline_color) +
    geom_errorbar(aes(ymin=lower_limit, ymax=upper_limit), colour=line_col, width=.3) +
    geom_point(size=2, shape=21, fill=col, col=col) +
    coord_cartesian(ylim=ylims, xlim=xlims) +
    xlab("Years") +
    ylab(paste("Lambda values (", baseline, " = stable)", sep="")) +
    ggtitle(title) +
    scale_x_continuous(limits = xlims, breaks = seq(xlims[1], xlims[2], yrbreaks), expand = c(0,0)) + # Set tick every 5 years
    scale_y_continuous(limits = ylims, trans=trans, breaks = seq(ylims[1], ylims[2], ybreaks)) +
    theme_bw() +
    theme(legend.justification=c(1,0),
          legend.position=c(1,0),
          axis.text.x = element_text(size=12, angle = 90, hjust = 1),
          panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank())
  print(plot)
  return(plot)
}
