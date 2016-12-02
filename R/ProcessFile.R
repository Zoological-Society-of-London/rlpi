#' Process an LPI dataset (DatasetName using the refernce year ref_year)
#'
#' @param DatasetName - The name of the dataset to process
#' @param ref_year Reference year for the LPI - when the index == 1
#' @param MODEL_SELECTION_FLAG Default=0
#' @param GAM_GLOBAL_FLAG  1 = process by GAM method, 0 = process by chain method. Default=1
#' @param DATA_LENGTH_MIN Minimum data length to include in calculations. Default=2
#' @param AVG_TIME_BETWEEN_PTS_MAX Maximum time between datapoint to include. Default=100
#' @param GLOBAL_GAM_FLAG_SHORT_DATA_FLAG # set this to 1 GAM model is also to be generated for the short time series else the log linear model will be used. Default=0
#' @param AUTO_DIAGNOSTIC_FLAG 1=Automatically determine whether GAM models are good enough, 0=Manually ask for each. Default=1
#' @param LAMBDA_MIN Minimum lambda to include in calculations. Default=1
#' @param LAMBDA_MAX Minimum lambda to include in calculations. Default=-1
#' @param ZERO_REPLACE_FLAG  0 = +minimum value; 1 = +1\% of mean value; 2 = +1. Default=1
#' @param OFFSET_ALL 1 = Add offset to all values, to avoid log(0). Default=0
#' @param OFFSET_NONE=FALSE # Does nothing (leaves 0 unaffected **used for testing will break if there are 0 values in the source data **)
#' @param OFFSET_DIFF=FALSE # Offset time-series with 0 values adding 1% of mean if max value in time-series<1 and 1 if max>=1
#' @param LINEAR_MODEL_SHORT_FLAG # if=TRUE models short time-series with linear model
#' @return Return length of lamda array (number of lamda values?) - results are saved to file
#' @export
#'
ProcessFile <-function(DatasetName,
                       ref_year,
                       MODEL_SELECTION_FLAG,
                       GAM_GLOBAL_FLAG,
                       DATA_LENGTH_MIN,
                       AVG_TIME_BETWEEN_PTS_MAX,
                       GLOBAL_GAM_FLAG_SHORT_DATA_FLAG,
                       AUTO_DIAGNOSTIC_FLAG,
                       LAMBDA_MIN,
                       LAMBDA_MAX,
                       ZERO_REPLACE_FLAG,
                       OFFSET_ALL,
                       OFFSET_NONE,
                       OFFSET_DIFF,
                       LINEAR_MODEL_SHORT_FLAG,
                       SHOW_PROGRESS) {

  md5val <- tools::md5sum(DatasetName)
  # Read data file
  Data = read.table(DatasetName, header = TRUE)

  # Get data from file as column vectors
  SpeciesSSet = Data[1]
  IDSSet = Data[2]
  YearSSet = Data[3]
  PopvalueSSet = Data[4]

  # Forget 'data' variable
  rm(Data)

  FinalYear = max(YearSSet)

  # Note that data could be later than ref_year
  if (min(YearSSet) < ref_year) {
    InitialYear = ref_year
  } else {
    InitialYear = min(YearSSet)
  }
  InitialYear = ref_year

  # Call the LPI function sNames = unique(SpeciesSSet); noSpecies = max(dim(sNames))
  # MethodFlag = matrix(0,1,noSpecies)

  cat("Calculating LPI for Species\n")

  pop_lambda_filename <- gsub(".txt", "_PopLambda.txt", DatasetName)
  Pop_Headers<-t(c("population_id", as.vector(InitialYear:FinalYear)))
  write.table(Pop_Headers,file=pop_lambda_filename, sep=",", eol="\n", quote=FALSE, col.names=FALSE, row.names = FALSE)

  SpeciesLambda = CalcLPI(SpeciesSSet,
                          IDSSet,
                          YearSSet,
                          PopvalueSSet,
                          InitialYear,
                          FinalYear,
                          DatasetName,
                          MODEL_SELECTION_FLAG,
                          GAM_GLOBAL_FLAG,
                          DATA_LENGTH_MIN,
                          AVG_TIME_BETWEEN_PTS_MAX,
                          GLOBAL_GAM_FLAG_SHORT_DATA_FLAG,
                          AUTO_DIAGNOSTIC_FLAG,
                          LAMBDA_MIN,
                          LAMBDA_MAX,
                          ZERO_REPLACE_FLAG,
                          OFFSET_ALL,
                          OFFSET_NONE,
                          OFFSET_DIFF,
                          LINEAR_MODEL_SHORT_FLAG,
                          show_progress=SHOW_PROGRESS)

  # Save Species Lambda matrix into a file

  # FileNo removed - could use name?! *** #DataFileName = paste("lpi_temp/SpeciesLambda", FileNo, sep = "")
  #cat(sprintf("Saving species lambda to file: %s\n", DataFileName))
  #write.table(SpeciesLambda, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)

  #cat(dim(SpeciesLambda), "\n")
  #cat(dim(unique(SpeciesSSet)), "\n")

  DataFileName = paste("lpi_temp/", md5val, "_splambda.csv", sep = "")
  cat(sprintf("Saving species lambda to file: %s\n", DataFileName))
  write.table(SpeciesLambda, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)

  # Adding count of pops per species:
  # *****
  sp.count <- as.data.frame(table(SpeciesSSet))

  DataFileName = gsub(".txt", "_lambda.csv", DatasetName)
  rownames(SpeciesLambda) <- t(unique(SpeciesSSet))
  colnames(SpeciesLambda) <- InitialYear:FinalYear
  sorted_lambdas <- SpeciesLambda[order(rownames(SpeciesLambda)), ]
  sorted_lambdas_count = cbind(sp.count, sorted_lambdas)

  cat(sprintf("Saving species lambda to file: %s\n", DataFileName))
  write.table(sorted_lambdas_count, DataFileName, sep = ",", col.names=NA)

  #rm(SpeciesSSet, IDSSet, YearSSet, PopvalueSSet)

  cat("Calculating DTemp\n")
  DTemp = matrix(0, 1, dim(SpeciesLambda)[2])
  # For each year
  for (I in 1:dim(SpeciesLambda)[2]) {
    # Get data for this year 'I'
    YearData = SpeciesLambda[, I]

    # Find populations that have data
    Index = which(YearData != -1)

    # If there are some populations
    if (length(Index) > 0) {
      # DTemp is mean lambda for those populations
      DTemp[I] = mean(YearData[Index])
      # Otherwise -99
    } else DTemp[I] = -99
  }

  # RF: Each file returns dimensions now
  #if (dim(SpeciesLambda)[2] > DSize)
  #  DSize = dim(SpeciesLambda)[2]

  # Save DTemp into file
  # FileNo removed - could use name?! *** #DataFileName = paste("lpi_temp/DTemp", FileNo, sep = "")
  #write.table(DTemp, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)

  DataFileName = paste("lpi_temp/", md5val, "_dtemp.csv", sep = "")

  cat("Saving DTemp to file: ", DataFileName, "\n")
  #write.table(DTemp, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)

  colnames(DTemp) <- InitialYear:FinalYear

  write.table(DTemp, DataFileName, sep = ",", row.names = FALSE)

  DataFileName = gsub(".txt", "_dtemp.csv", DatasetName)
  cat("Saving DTemp to file: ", DataFileName, "\n")
  #write.table(DTemp, DataFileName, sep = ",", col.names = FALSE, row.names = FALSE)
  write.table(DTemp, DataFileName, sep = ",", row.names = FALSE)

  # Return length of lamda array (number of lamda values?)
  #cat("Returning length of lambda\n")
  return(dim(SpeciesLambda)[2])
}
