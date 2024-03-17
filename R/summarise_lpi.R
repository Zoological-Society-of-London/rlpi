#' summarise_lpi - generates useful summaries for data within the given infile
#'
#' @param infile - The infile to summarise the data within
#'
#' @export
#'

summarise_lpi <- function(infile) {
  # Bit of a hack to avoid NOTE during R CMD check
  # Sets the variables used in ggplot2::aes to NULL
  summarise <- Binomial <- year <- ID <- species <- pop <- duration <- nspecies <- minyear <- maxyear <- NULL

  FileTable <- read.table(infile, header = TRUE)
  FileNames <- FileTable$FileName
  Group <- FileTable[2]
  NoFiles <- max(dim(Group))

  summary_data <- data.frame(filename = character(0), nyear = numeric(0), nsp = numeric(0), npop = numeric(0))

  for (FileNo in 1:NoFiles) {
    filename <- toString(FileNames[FileNo])
    Data <- read.table(filename, header = TRUE)

    nyear <- plyr::summarise(Data, nyear = length(unique(year)))
    npop <- plyr::summarise(Data, npop = length(unique(ID)))
    nsp <- plyr::summarise(Data, nsp = length(unique(Binomial)))

    summary_data <- rbind(summary_data, data.frame(filename = filename, nyear = nyear, nsp = nsp, npop = npop))

    pdf(file = paste(filename, ".summary.pdf", sep = ""), width = 16, height = 6)


    npop_year <- plyr::ddply(Data, "year", plyr::summarise, nyear = length(unique(ID)))
    colnames(npop_year) <- c("year", "npop")
    p1 <- ggplot2::ggplot(npop_year, ggplot2::aes(x = year, y = npop)) +
      ggplot2::geom_point(size = 4) +
      ggplot2::xlab("Year") +
      ggplot2::ylab("Number of populations") +
      ggplot2::ggtitle("Number of populations per year") +
      ggplot2::scale_x_continuous(breaks = round(seq(min(as.numeric(npop_year$year)), max(as.numeric(npop_year$year)), by = 1), 1)) +
      ggplot2::theme(
        text = ggplot2::element_text(size = 16),
        panel.background = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_line(linetype = 3, color = "darkgray"),
        panel.grid.major.y = ggplot2::element_line(linetype = 2, color = "gray"),
        axis.text.y = ggplot2::element_text(size = ggplot2::rel(0.8)),
        axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5)
      )
    print(p1)

    write.table(npop_year, file = paste(filename, ".npop_year.txt", sep = ""), row.names = FALSE)

    nsp_year <- plyr::ddply(Data, "year", plyr::summarise, nyear = length(unique(Binomial)))
    colnames(nsp_year) <- c("year", "nspecies")
    p2 <- ggplot2::ggplot(nsp_year, ggplot2::aes(x = year, y = nspecies)) +
      ggplot2::geom_point(size = 4) +
      ggplot2::xlab("Year") +
      ggplot2::ylab("Number of species") +
      ggplot2::ggtitle("Number of species per year") +
      ggplot2::scale_x_continuous(breaks = round(seq(min(nsp_year$year), max(nsp_year$year), by = 1), 1)) +
      ggplot2::theme(
        text = ggplot2::element_text(size = 16),
        panel.background = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_line(linetype = 3, color = "darkgray"),
        panel.grid.major.y = ggplot2::element_line(linetype = 2, color = "gray"),
        axis.text.y = ggplot2::element_text(size = ggplot2::rel(0.8)),
        axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5)
      )
    print(p2)

    write.table(nsp_year, file = paste(filename, ".nsp_year.txt", sep = ""), row.names = FALSE)

    nyear_sp <- plyr::ddply(Data, "Binomial", plyr::summarise, nyear = length(unique(year)))
    colnames(nyear_sp) <- c("species", "nyear")
    p3 <- ggplot2::ggplot(nyear_sp, ggplot2::aes(x = reorder(species, nyear), y = nyear)) +
      ggplot2::geom_point(size = 2) +
      ggplot2::xlab("Species") +
      ggplot2::ylab("Number of years") +
      ggplot2::ggtitle("Number of years per species") +
      # scale_x_continuous(breaks = round(seq(min(nsp_year$year), max(nsp_year$year), by = 1),1)) +
      # scale_y_continuous(breaks = round(seq(0, max(nsp_year$nspecies), by = 100),1)) +
      ggplot2::theme(
        text = ggplot2::element_text(size = 16),
        panel.background = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_line(linetype = 3, color = "darkgray"),
        panel.grid.major.y = ggplot2::element_line(linetype = 2, color = "gray"),
        axis.text.y = ggplot2::element_text(size = ggplot2::rel(0.8)),
        axis.text.x = ggplot2::element_text(size = 10, angle = 90, hjust = 1, vjust = 0.5)
      )
    print(p3)

    write.table(nyear_sp[order(nyear_sp$nyear), ], file = paste(filename, ".nyear_sp.txt", sep = ""), row.names = FALSE)

    nyear_pop <- plyr::ddply(Data, c("ID", "Binomial"), plyr::summarise, nyear = length(unique(year)))
    colnames(nyear_pop) <- c("pop", "binomial", "nyear")
    p4 <- ggplot2::ggplot(nyear_pop, ggplot2::aes(x = reorder(pop, nyear), y = nyear)) +
      ggplot2::geom_point(size = 2) +
      ggplot2::xlab("Population") +
      ggplot2::ylab("Number of years") +
      ggplot2::ggtitle("Number of years per population") +
      ggplot2::theme(
        text = ggplot2::element_text(size = 16),
        panel.background = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_line(linetype = 3, color = "darkgray"),
        panel.grid.major.y = ggplot2::element_line(linetype = 2, color = "gray"),
        axis.text.y = ggplot2::element_text(size = ggplot2::rel(0.8)),
        axis.text.x = ggplot2::element_text(size = 6, angle = 90, hjust = 1, vjust = 0.5)
      )
    print(p4)

    write.table(nyear_pop[order(nyear_pop$nyear), ], file = paste(filename, ".nyear_pop.txt", sep = ""), row.names = FALSE)

    # Calculate min and max for each population/species
    minpop_year <- plyr::ddply(Data, c("Binomial", "ID"), plyr::summarise, minyear = min(as.numeric(year)))
    maxpop_year <- plyr::ddply(Data, c("Binomial", "ID"), plyr::summarise, maxyear = max(as.numeric(year)))
    df <- merge(minpop_year, maxpop_year, by = c("Binomial", "ID"))
    df$duration <- df$maxyear - df$minyear


    # Then plot these
    p5 <- ggplot2::ggplot(df, ggplot2::aes(colour = "black")) +
      ggplot2::geom_segment(ggplot2::aes(x = minyear, xend = maxyear, y = reorder(Binomial, duration), yend = reorder(Binomial, duration)), size = 0.5, colour = "black") +
      ggplot2::xlab("Duration")
    print(p5)

    dev.off()
  }
  write.table(summary_data, file = paste(infile, ".summary.csv", sep = ""), sep = ",", row.names = FALSE)

  print(summary_data)

  cat(sprintf("\nOverall summary for infile: %s\n", infile))
  print(colSums(summary_data[, -1]))

  cat(sprintf("\nSee generated files for summary plots\n"))
}
