#' Create an index from a number of datasets in a given input file
#'
#' @details
#'
#' # Calculate an index using the population file specified in GlobalInFile.txt, calculating confidence intervals using 100 bootstraps
#' lpi_global <- LPIMain("GlobalInfile.txt", CI_FLAG=1, title="Global LPI", BOOT_STRAP_SIZE=100)
#' # Plot this global LPI
#' ggplot_lpi(lpi_global)
#' # Calculate an index using the population file specified in TropicalInfile.txt, calculating confidence intervals using 100 bootstraps
#' lpi_tropical <- LPIMain("TropicalInfile.txt", CI_FLAG=1, title="Tropical LPI", BOOT_STRAP_SIZE=100)
#' # Plot this tropical LPI
#' ggplot_lpi(lpi_tropical)
#' # Plot them together
#' ggplot_lpi_multi(list(lpi_global, lpi_tropical), names=c("global", "tropical"))
#'
#' @param infile - Input file specifying the population files that should be included in the index
#' @param basedir - Base directory in which files (inc. temporary directories) will be stored
#' @param REF_YEAR - Reference year for index (when the index == 1). Default=1970
#' @param PLOT_MAX - The final year of the index to plot. Default=2012,
#' @param force_recalculation - Whether the population annual differences should be recalucated (they are cached for a given file). Default=0
#' @param use_weightings - Whether to use the first level of weightings ('Weightings') in the infile. Default=0
#' @param use_weightings_B - Whether to use the second level of weightings ('WeightingsB') in the infile. Default=0
#' @param title - The title. Default=""
#' @param CI_FLAG - Flag to indicate whether or not to calculate confidence intervals (bootstrapping the index). Default=1
#' @param LEV_FLAG - Flag to indicate wether or not to calculate species level leverage plots. Default=0
#' @param SWITCH_PT_FLAG - Flag to indicate whether or not to calculate switching points. Default=0
#' @param BOOT_STRAP_SIZE - If calculating CIs, how many bootstraps to use. Default=100
#' @param save_plots - Should plots be saved. Default=1
#' @param plot_lpi - Should plots be plotted. Default=1
#' @param goParallel - Should the code be executing in parallel, Default=FALSE
#'
#' @param MODEL_SELECTION_FLAG Default=0
#' @param GAM_GLOBAL_FLAG - 1 = process by GAM method, 0 = process by chain method. Default=1
#' @param DATA_LENGTH_MIN - Minimum data length to include in calculations. Default=2
#' @param AVG_TIME_BETWEEN_PTS_MAX - Maximum time between datapoint to include. Default=100
#' @param GLOBAL_GAM_FLAG_SHORT_DATA_FLAG - Set this to 1 GAM model is also to be generated for the short time series else the log linear model will be used. Default=0
#' @param AUTO_DIAGNOSTIC_FLAG - 1=Automatically determine whether GAM models are good enough, 0=Manually ask for each. Default=1
#' @param LAMBDA_MIN - Minimum lambda to include in calculations. Default=1
#' @param LAMBDA_MAX - Minimum lambda to include in calculations. Default=-1
#' @param ZERO_REPLACE_FLAG  - This controls how zeros are dealt with. If this parameter is 0, then populations contining zeros will have a minimum value (1e-17) added to all value; If this flag is 1 then those populations will have +1\% of mean added to all values; If this flag is 2 then those pops will have +1 added. Default is 1, add 1% of the mean
#' @param OFFSET_ALL - 1 = Add offset to all values, to avoid log(0). Default=0
#' @param OFFSET_NONE
#' @param OFFSET_DIFF
#' @param LINEAR_MODEL_SHORT_FLAG
#' @param VERBOSE - Whether to print verbose information. Default=1
#' @return lpi - A data frame containing an LPI and CIs if calculated
#' @examples
#'
#' # Get example data from package
#' # Copy zipped data to local directory
#' file.copy(from = system.file("extdata", "example_data.zip", package = "rlpi"), to = ".")
#' unzip("example_data.zip")
#'
#' # Terrestrial LPI with equal weighting across classes and realms
#' # Default gives 100 boostraps (this will take a few minutes to run (on a 2014 Macbook))
#' terr_lpi <- LPIMain("terrestrial_class_realms_infile.txt")
#'
#' # Nicer plot
#' ggplot_lpi(terr_lpi)
#'
#' # Run same again, but used cached lambdas (force_recalculation == 0), and now weighted by class, but equal across realms (see infile for weights)
#' terr_lpi_b <- LPIMain("terrestrial_class_realms_infile.txt", force_recalculation = 0, use_weightings = 1)
#'
#' # Putting the two LPIs together in a list
#' lpis <- list(terr_lpi, terr_lpi_b)
#' # And plotting them together should show identical means but with different CIs
#' ggplot_multi_lpi(lpis, xlims = c(1970, 2012))
#'
#' # Can also plot these next to each other, and use some more meaningful titles
#' ggplot_multi_lpi(lpis, names = c("Weighted", "Unweighted"), xlims = c(1970, 2012), facet = TRUE)
#'
#' # And can log the y-axis - need to set ylim as log(0) is -Inf
#' ggplot_multi_lpi(lpis, names = c("Weighted", "Unweighted"), xlims = c(1970, 2012), facet = TRUE, ylim = c(0.5, 2), trans = "log")
#'
#' @export
#'
#'
LPIMain <- function(infile = "Infile.txt",
                    basedir = ".",
                    REF_YEAR = 1970,
                    PLOT_MAX = 2017,
                    force_recalculation = 1,
                    use_weightings = 0,
                    use_weightings_B = 0,
                    title = "",
                    CI_FLAG = 1,
                    LEV_FLAG = 0,
                    SWITCH_PT_FLAG = 0,
                    BOOT_STRAP_SIZE = 100,
                    save_plots = 1,
                    plot_lpi = 1,
                    goParallel = FALSE,
                    # CalcLPI options...
                    MODEL_SELECTION_FLAG = 0,
                    GAM_GLOBAL_FLAG = 1, # 1 = process by GAM method, 0 = process by chain method
                    DATA_LENGTH_MIN = 2,
                    AVG_TIME_BETWEEN_PTS_MAX = 100,
                    GLOBAL_GAM_FLAG_SHORT_DATA_FLAG = 0, # set this if GAM model is also to be generated for the short time series else the log linear model will be used.
                    AUTO_DIAGNOSTIC_FLAG = 1,
                    LAMBDA_MIN = -1,
                    LAMBDA_MAX = 1,
                    ZERO_REPLACE_FLAG = 1, # 0 = +minimum value; 1 = +1% of mean value; 2 = +1
                    OFFSET_ALL = 0, # Add offset to all values, to avoid log(0)
                    OFFSET_NONE = FALSE, # Does nothing (leaves 0 unaffected **used for testing will break if there are 0 values in the source data **)
                    OFFSET_DIFF = FALSE, # Offset time-series with 0 values adding 1% of mean if max value in time-series<1 and 1 if max>=1
                    LINEAR_MODEL_SHORT_FLAG = FALSE, # if=TRUE models short time-series with linear model
                    CAP_LAMBDAS = TRUE,
                    VERBOSE = TRUE,
                    SHOW_PROGRESS = TRUE) {
  # Start timing
  ptm <- proc.time()

  # Set parallel mode
  `%op%` <- if (goParallel) foreach::`%dopar%` else foreach::`%do%`
  doParallel::registerDoParallel()

  # RF: Create a working directory to put files in
  success <- dir.create(basedir, showWarnings = FALSE)
  if (success) {
    print(sprintf("** Created folder: %s", basedir))
  }
  dir.create(file.path(basedir, "lpi_temp"), showWarnings = FALSE)
  if (success) {
    print(sprintf("** Created folder: %s", file.path(basedir, "lpi_temp")))
  }

  # RF: Get list of input files
  FileTable <- read.table(infile, header = TRUE)
  # RF: Get names from file
  FileNames <- FileTable$FileName
  # Get groups from file as column vector
  Group <- FileTable[2]

  GroupList <- unique(Group[[1]])

  # print(Group)

  Weightings <- FileTable[3]

  # RF: Get weightings from file
  if (use_weightings == 1) {
    WeightingsA <- FileTable[3]

    # Weightings = Weightings/sum(Weightings)
    cat(sprintf("Weightings...\n"))

    # Make sure group weightings normalise
    for (i in 1:length(GroupList)) {
      print(paste("Group:", GroupList[i]))
      cat("\t")
      print(Weightings[Group == GroupList[i]])
      cat("\t")
      print("Normalised weights (sum to 1)")
      Weightings[Group == GroupList[i]] <- Weightings[Group == GroupList[i]] / sum(Weightings[Group == GroupList[i]])
      cat("\t")
      print(Weightings[Group == GroupList[i]])
    }
    cat("\n")
  }

  if (use_weightings_B == 1) {
    # RF: Get weightings from file
    FileWeightingsB <- FileTable[4]
    WeightingsB <- unique(cbind(Group, FileWeightingsB))$WeightingB
    # WeightingsB = WeightingsB/sum(WeightingsB)
    cat(sprintf("WeightingsB...\n"))
    print(WeightingsB)
    cat("\n")
  }


  # Find max of group to get number of groups
  NoGroups <- length(unique(Group[[1]]))

  cat("Number of groups: ", NoGroups, "\n")

  # CI_FLAG and the Switchpointflag were here

  # Number of files is the size of the maximum dimension of Group
  NoFiles <- max(dim(Group))

  # DSize = 0
  # Create empty matrix to store size of lambdas (number of years) for each species
  # DSizes = matrix(0, ncol=10)

  # writeLines(c(""), "progress_log_files.txt")

  # DSizes <- foreach (FileNo = 1:NoFiles,.combine=cbind) %dopar% {
  DSizes <- foreach::foreach(FileNo = 1:NoFiles, .combine = cbind) %op% {
    # sink("progress_log_files.txt", append=TRUE)
    # Check MD5 here to see if file already processed:
    md5val <- tools::md5sum(toString(FileNames[FileNo]))
    if (
      (force_recalculation == 1) ||
        (!file.exists(file.path(basedir, "lpi_temp", paste0(md5val, "_dtemp.csv")))) ||
        (!file.exists(file.path(basedir, "lpi_temp", paste0(md5val, "_splambda.csv"))))
    ) {
      # DSizes[FileNo] = ProcessFile(toString(FileNames[FileNo]), FileNo)
      cat(sprintf("processing file: %s\n", toString(FileNames[FileNo])))

      ProcessFile(
        DatasetName = toString(FileNames[FileNo]),
        ref_year = REF_YEAR,
        MODEL_SELECTION_FLAG = MODEL_SELECTION_FLAG,
        GAM_GLOBAL_FLAG = GAM_GLOBAL_FLAG,
        DATA_LENGTH_MIN = DATA_LENGTH_MIN,
        AVG_TIME_BETWEEN_PTS_MAX = AVG_TIME_BETWEEN_PTS_MAX,
        GLOBAL_GAM_FLAG_SHORT_DATA_FLAG = GLOBAL_GAM_FLAG_SHORT_DATA_FLAG,
        AUTO_DIAGNOSTIC_FLAG = AUTO_DIAGNOSTIC_FLAG,
        LAMBDA_MIN = LAMBDA_MIN,
        LAMBDA_MAX = LAMBDA_MAX,
        ZERO_REPLACE_FLAG = ZERO_REPLACE_FLAG,
        OFFSET_ALL = OFFSET_ALL,
        OFFSET_NONE = OFFSET_NONE,
        OFFSET_DIFF = OFFSET_DIFF,
        LINEAR_MODEL_SHORT_FLAG = LINEAR_MODEL_SHORT_FLAG,
        CAP_LAMBDAS = CAP_LAMBDAS,
        SHOW_PROGRESS = SHOW_PROGRESS,
        basedir = basedir
      )
      # cat("done processing file: ", toString(FileNames[FileNo]))
    }
    # sink()
  }

  # Get largest dimension size
  # DSize = max(DSizes)
  # *******
  # Trying this - don't know why it wouldn't be ok, just means we're only processing lamdas that
  # we're going to plot?
  # *******
  DSize <- PLOT_MAX - REF_YEAR + 2

  # Create an empty data frame (create matrix, then convert) to put species lambdas in
  # Here we create a data fram with no rows, then use rbind.fill to add to it (which will
  # create NAs for missing columns)
  # SpeciesLambdaArrayTemp = matrix(data=NA,nrow=0,ncol=DSize)
  # Not quite sure why this needs to be transposed as it's empty and has the right dims, but it does
  SpeciesLambdaArray <- data.frame(NULL)
  SpeciesNamesArray <- data.frame(NULL)

  # Create empty (NAs) DTemp array
  DTempArrayTemp <- matrix(data = NA, nrow = NoFiles, ncol = DSize)
  DTempArray <- data.frame(DTempArrayTemp)

  DataSizeArray <- matrix(0, NoFiles, 2)

  fileindex <- NULL

  for (FileNo in 1:NoFiles) {
    md5val <- tools::md5sum(toString(as.character(FileNames[FileNo])))
    # Read SpeciesLambda and DTemp from saved files

    FileName <- file.path(basedir, "lpi_temp", paste0(md5val, "_splambda.csv"))
    SpeciesLambda <- read.table(FileName, header = FALSE, sep = ",")
    debug_print(VERBOSE, sprintf("Loading previously analysed species lambda file for '%s' from MD5 hash: %s\n", as.character(FileNames[FileNo]), FileName))

    species_names <- read.table(file.path(basedir, "lpi_temp/SpeciesName.txt"))

    cat(sprintf("%s, Number of species: %s\n", as.character(FileNames[FileNo]), dim(SpeciesLambda)[1]))

    # Add this species data to the array of all data
    # cat(dim(SpeciesLambdaArray), "\n")
    SpeciesLambdaArray <- plyr::rbind.fill(SpeciesLambdaArray, SpeciesLambda)
    SpeciesNamesArray <- plyr::rbind.fill(SpeciesNamesArray, species_names)
    # cat(dim(SpeciesLambdaArray), "\n")
    # Keep note of which file that data was from (to use as an index later)
    fileindex <- c(fileindex, rep(FileNo, dim(SpeciesLambda)[1]))
    # cat(length(fileindex), "\n")
    # DTemps are the mean annual differences in population for each group/file
    FileName <- file.path(basedir, "lpi_temp", paste0(md5val, "_dtemp.csv"))
    debug_print(VERBOSE, sprintf("Loading previously analysed dtemp file from MD5 hash: %s\n", FileName))
    # DTemp = read.table(FileName, header = F, sep = ",", col.names = FALSE)
    DTemp <- read.table(FileName, header = T, sep = ",")

    # print(DTemp)
    # DTemp = as.numeric(DTemp)
    DTempArray[FileNo, 1:dim(DTemp)[2]] <- t(DTemp)
  }

  # cat("DTempArray: \n")
  # print(DTempArray)
  # cat("\n...DTempArray: \n")


  # write.table(DTempArray, file="dtemp_array.txt")
  f_name <- file <- file.path(basedir, gsub(".txt", "_dtemp_array.txt", infile))
  cat("Saving DTemp Array to file: ", f_name, "\n")
  write.table(DTempArray, f_name)

  dtemp_df <- data.frame(filenames = FileNames, dtemps = DTempArray)
  colnames(dtemp_df) <- c("filename", seq(REF_YEAR, REF_YEAR + DSize - 1))

  if (save_plots) {
    # Bit of a hack to avoid R CMD CHECK NOTE
    # Sets variable names used in ggplot2::aes to be NULL
    variable <- value <- filename <- NULL

    width <- 20
    height <- 8
    pdf(file.path(basedir, gsub(".txt", "_dtemp_array_plot.pdf", infile)), width = width, height = height)
    df.m <- reshape2::melt(dtemp_df, id.vars = "filename")
    df.m$value[df.m$value == -99] <- NA
    p_line <- ggplot2::ggplot(df.m, ggplot2::aes(variable, value, group = filename, col = filename)) +
      ggplot2::geom_line() +
      ggplot2::theme(
        text = ggplot2::element_text(size = 16),
        axis.text.x = ggplot2::element_text(size = 8, angle = 90, hjust = 1),
        legend.position = "bottom"
      ) +
      ggplot2::guides(col = ggplot2::guide_legend(nrow = 6))

    print(p_line)
    dev.off()
  }

  f_name <- file <- file.path(basedir, gsub(".txt", "_dtemp_array_named.csv", infile))
  cat("Saving DTemp Array with filesnames to file: ", f_name, "\n")
  write.csv(dtemp_df, f_name, row.names = FALSE)

  t1 <- proc.time() - ptm
  cat(sprintf("[Calculating LPI...] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))
  # I = calculate_index(DTempArray, fileindex, DSize, Group, Weightings, use_weightings)
  I <- calculate_index(DTempArray, fileindex, DSize, Group, Weightings, use_weightings, use_weightings_B, WeightingsB)


  # cat("I: \n")
  # print(I)
  # cat("\n..I: \n")

  Ifinal <- I # writes the Index 'I', to a new vector called 'Ifinal'
  # plot(Ifinal)
  # Year <- seq(REF_YEAR, (REF_YEAR + length(Ifinal)) - 1)
  # plot(Year, Ifinal, xlim = c(REF_YEAR, PLOT_MAX), ylab = paste("Index (", REF_YEAR, " = 1.0)", sep=""))
  # zeroEffectLine <- rep(1, (length(Ifinal)))
  # lines(Year, zeroEffectLine)
  # lines(Year, Ifinal)
  # title("It's worked!  Please wait while your CI's are calculated")

  # Find those years for which we have a valid index
  # valid_index_years = (!is.na(Ifinal))
  valid_index_years <- ((!is.na(Ifinal)) & (Ifinal != -99))
  cat(sprintf("Number of valid index years: %d (of possible %d)\n", sum(valid_index_years), length(valid_index_years)))

  if (CI_FLAG == 1) {
    # calculate the confidence intervals

    t1 <- proc.time() - ptm
    cat(sprintf("[Calculating CIs...] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))

    # cat(dim(SpeciesLambdaArray))

    # Create matrix for bootstrap indices
    BootI <- matrix(0, BOOT_STRAP_SIZE, DSize)
    BootIFlag <- matrix(0, 1, BOOT_STRAP_SIZE)

    # writeLines(c(""), "progress_log_boot.txt")

    # Converted to parallel *********
    # BootI <- foreach (Loop = 1:BOOT_STRAP_SIZE) %foreach::dopar% {
    BootI <- foreach::foreach(Loop = 1:BOOT_STRAP_SIZE) %op% {
      # sink("progress_log_boot.txt", append=TRUE)
      # bootstrap_lpi(SpeciesLambdaArray, fileindex, DSize, Group, Weightings, use_weightings)
      bootstrap_lpi(SpeciesLambdaArray, fileindex, DSize, Group, Weightings, use_weightings, use_weightings_B, WeightingsB, CAP_LAMBDAS)
      # sink()
    }
    cat("\n")

    t1 <- proc.time() - ptm
    cat(sprintf("[CIs calculated] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))

    # Combine list of vectors from foreach into matrix
    BootI <- do.call(cbind, BootI)
    # Transpose matrix as each bootstrap loop is a column and we'd like them to be rows
    BootI <- t(BootI)

    # cat("BootI", "\n")
    # print(BootI)
    # cat("\n")
    # cat(dim(as.matrix(BootI)), "\n")
    # cat(valid_index_years, "\n")


    # cat(BootI, "\n")

    ####################### I've changed this bit to extract the CIs for the LPI, cos later they get over
    ####################### written
    CIx <- matrix(0, DSize, 2)
    CIx[1, 1] <- 1
    CIx[1, 2] <- 1

    # Estimate confidence intervals using the bootstapped indicies
    for (J in 2:DSize) {
      # If this is a valid index year for this group
      if (valid_index_years[J]) {
        # Get the data
        BootIVal <- BootI[, J]

        # RF: this was used in original, now bootstrap only samples from valid data
        # Index = which(BootIFlag != 1)
        # BootIVal = BootI[Index, J]

        CIx[J, 1] <- quantile(BootIVal, 0.025, names = FALSE)
        CIx[J, 2] <- quantile(BootIVal, 0.975, names = FALSE)
      } else {
        # If we don't have an index for this year, we shouldn't have
        CIx[J, 1] <- NA
        CIx[J, 2] <- NA
      }
    }
  }


  if (LEV_FLAG == 1) {
    # calculate the species leverage

    t1 <- proc.time() - ptm
    cat(sprintf("[Calculating species leverages...] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))

    leverage_results <- list()
    leverage_diff <- list()
    leverage_species <- list()

    overall_lambdas <- calc_lambdas(Ifinal)

    # Calculate LPI with species selectively removed from index
    for (i in 1:nrow(SpeciesLambdaArray)) {
      # SpeciesLambdaArray = SpeciesLambdaArray[-i, ]
      lev_I <- calc_leverage_lpi(SpeciesLambdaArray[-i, ], fileindex, DSize, Group, Weightings, use_weightings, use_weightings_B, WeightingsB)

      leverage_results[[i]] <- lev_I
      leverage_diff[[i]] <- calc_lambdas(lev_I) - overall_lambdas
      leverage_species[[i]] <- SpeciesNamesArray[i, ]
    }


    cat("\n")

    t1 <- proc.time() - ptm
    cat(sprintf("[Species leverages calculated] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))

    # Combine list of vectors from foreach into matrix
    leverage_results <- do.call(cbind, leverage_results)
    # Transpose matrix as each bootstrap loop is a column and we'd like them to be rows
    leverage_results <- t(leverage_results)
    # Combine list of vectors from foreach into matrix
    leverage_diff <- do.call(cbind, leverage_diff)
    # Transpose matrix as each bootstrap loop is a column and we'd like them to be rows
    leverage_diff <- t(leverage_diff)

    leverage_results_table <- data.frame(leverage_results)
    colnames(leverage_results_table) <- seq(REF_YEAR, REF_YEAR + DSize - 1)

    # leverage_results_table$total <- rowSums(leverage_results_table)

    leverage_results_table$id <- unlist(leverage_species)
    write.csv(leverage_results_table, file = file.path(basedir, "species_leverage_lpi_results.csv"))

    leverage_diff_table <- data.frame(leverage_diff)
    colnames(leverage_diff_table) <- seq(REF_YEAR, REF_YEAR + DSize - 1)

    leverage_diff_table$total <- rowSums(leverage_diff_table)

    leverage_diff_table$id <- unlist(leverage_species)
    write.csv(leverage_diff_table, file = file.path(basedir, "species_leverage_diff_lambdas_results.csv"))
  }

  if (SWITCH_PT_FLAG == 1) {
    t1 <- proc.time() - ptm
    cat(sprintf("[Calculating Switch Points...] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))

    sp_prog <- txtProgressBar(min = 0, max = BOOT_STRAP_SIZE, char = "*", style = 3)

    # Calculate the switching points
    SecondDerivBoot <- matrix(0, BOOT_STRAP_SIZE, DSize)

    for (Loop in 1:BOOT_STRAP_SIZE) {
      DTempArrayTemp <- matrix(data = NA, nrow = NoFiles, ncol = DSize)
      DTempArray <- data.frame(DTempArrayTemp)

      for (FileNo in 1:NoFiles) {
        # Read SpeciesLambda from saved file FileName = file.path(basedir, paste0('lpi_temp/SpeciesLambda',FileNo))
        # SpeciesLambda = read.table(FileName, header = FALSE, sep=',')

        # cat('[Loop File] ', FileNo, ' Calculating Switching Points\n')
        SpeciesLambda <- SpeciesLambdaArray[fileindex == FileNo, ]

        n <- length(SpeciesLambda[, 1])
        BootIndex <- 1:n
        BootSam <- sample(BootIndex, replace = T)
        DTemp <- matrix(0, 1, dim(SpeciesLambda)[2])

        for (LoopI in 1:dim(SpeciesLambda)[2]) {
          SpeciesLambdaVal <- SpeciesLambda[, LoopI]
          BootVal <- SpeciesLambdaVal[BootSam]

          Index <- which(BootVal != -1)
          if (length(Index) > 0) {
            DTemp[LoopI] <- mean(BootVal[Index])
            # } else DTemp[LoopI] = -99
          } else {
            DTemp[LoopI] <- NA
          }
        }

        if (dim(SpeciesLambda)[2] > DSize) {
          DSize <- dim(SpeciesLambda)[2]
        }

        # Save DTemp into file
        # *** RF: Again? These bootstrapped DTemps therefore overwrite the LPI ones from previously
        # DataFileName = file.path(basedir, "lpi_temp", paste("DTemp", FileNo, sep = ""))
        # write.table(DTemp, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)

        # Just save them into a temp array instead!

        DTempArray[FileNo, 1:dim(t(DTemp))[1]] <- t(DTemp)
      }

      I <- calculate_index(DTempArray, fileindex, DSize, Group, Weightings)

      # Call second derivative function and save data in an array
      h <- 1
      d <- 6
      interval <- 1
      SecDeriv <- CalcSDev(I, h, d, interval)
      SecondDerivBoot[Loop, ] <- SecDeriv

      setTxtProgressBar(sp_prog, Loop)
    }

    close(sp_prog)

    # Calculate 95% confidence intervals - on the second derivative

    CI <- matrix(0, DSize, 2)

    for (J in 1:DSize) {
      SecondDerivBootVal <- SecondDerivBoot[, J]
      Index <- which(SecondDerivBootVal != -1)
      SecondDerivBootVal <- SecondDerivBoot[Index, J]
      CI[J, 1] <- quantile(SecondDerivBootVal, 0.025, names = FALSE)
      CI[J, 2] <- quantile(SecondDerivBootVal, 0.975, names = FALSE)
    }

    SwitchingPt <- matrix(0, 1, DSize)
    for (J in 1:DSize) {
      if ((CI[J, 1] > 0) & (CI[J, 2] > 0)) {
        SwitchingPt[J] <- 1
      }

      if ((CI[J, 1] < 0) & (CI[J, 2] < 0)) {
        SwitchingPt[J] <- -1
      }
    }
  }

  if(CI_FLAG) {
    CI2 <- data.frame(CIx)
  }

  if (plot_lpi) {
    if (CI_FLAG == 1) {
      # Plot the index with confidence intervals
      lowerCI <- t(CI2$X1)
      upperCI <- t(CI2$X2)
      plot_lpi(Ifinal, REF_YEAR, PLOT_MAX, CI_FLAG, lowerCI, upperCI)
    } else {
      # Plot the index
      plot_lpi(Ifinal, REF_YEAR, PLOT_MAX)
    }

    if (nchar(title) > 0) {
      title <- paste("[", title, "] ", sep = "")
    }

    if (CI_FLAG == 1) {
      title(paste(title, "Calculated Index; Bootstraps = ", BOOT_STRAP_SIZE, sep = ""))
    } else {
      title(paste(title, "Calculated Index"))
    }
  }

  # write out the file
  LPIdata <- data.frame(LPI_final = Ifinal)
  if(CI_FLAG) {
    LPIdata["CI_low"] = CI2$X1
    LPIdata["CI_high"] = CI2$X2
  }
  if(SWITCH_PT_FLAG) {
    LPIdata["SwitchPoint"] = t(SwitchingPt)
  }
  rownames(LPIdata) <- seq(REF_YEAR, REF_YEAR + DSize - 1)

  f_name <- file <- file.path(basedir, gsub(".txt", "_Results.txt", infile))
  cat("Saving final output to file: ", f_name, "\n")
  write.table(LPIdata, f_name)

  # cat("[Min/Max] Create min/max file\n")
  # create minmax file

  # RF: Get list of input files
  FileTable <- read.table(infile, header = TRUE)
  # RF: Get names from file
  FileNames <- FileTable$FileName
  # Get groups from file as column vector
  Group <- FileTable[2]
  # Find max of group to get number of groups
  # NoGroups = max(Group)
  NoGroups <- length(unique(Group))
  # Number of files is the size of the maximum dimension of Group
  NoFiles <- max(dim(Group))

  for (FileNo in 1:NoFiles) {
    Dataset <- toString(FileNames[FileNo])
    # cat(Dataset, "\n")
    Data <- read.table(Dataset, header = TRUE)
    colnames(Data) <- c("Binomial", "ID", "year", "popvalue")

    # bit of a hack to avoid R CMD CHECK, sets variable 'year' used in ddply to be NULL
    year <- NULL

    minmax <- plyr::ddply(Data, "ID", plyr::summarise, min_year = min(year), max_year = max(year))
    # minmax <- tapply(Data$ID, Data$year, range)
    # my.out <- do.call("rbind", minmax)
    f_name <- file <- file.path(basedir, gsub(".txt", "_Minmax.txt", Dataset))
    cat("Saving Min/Max file to: ", f_name, "\n")
    write.table(minmax,
      sep = ",", eol = "\n", f_name,
      quote = FALSE, append = FALSE, row.names = F, col.names = T
    )
  }


  # Delete all variables in memory (bit dangerous this if you're doing other things!)
  # **Should no longer be neccessary as we're in a function!
  # rm(list = ls(all = TRUE))

  # save plot

  if (save_plots) {
    output_file <- file.path(basedir, gsub(".txt", ".pdf", infile))
    cat("Saving Plot to PDF: ", output_file, "\n")
    dev.copy(pdf, output_file)
    dev.off()
    # savePlot()
  }
  t1 <- proc.time() - ptm
  cat(sprintf("[END] System: %f, User: %f, Elapsed: %f\n", t1[1], t1[2], t1[3]))
  # Stop timing

  return(LPIdata)
}
