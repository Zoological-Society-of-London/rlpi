#' CalcLPI - Main funciton for calculating species lamdbas (interannual changes).
#'
#' @details
#' Input data is a series
#' of 4-value rows: (Species, ID, Year, Popvalue). This function will model the species populations over time
#' using either the chain method (log-linear interpolation) or Generalised Additive Modelling. See GAM_GLOBAL_FLAG
#'
#'
#' @param Species - Vector with name of species for each population value
#' @param ID - Vector of IDs for each population value
#' @param Year - Vector of years for each population value
#' @param Popvalue - Vector of population values
#' @param InitialYear - Initial year to calculate the index from
#' @param FinalYear - Final year to calculate the index to
#' @param DatasetName - Name of the dataset that these value are from (for generating output files)
#' @param MODEL_SELECTION_FLAG Default=0
#' @param GAM_GLOBAL_FLAG  1 = process by GAM method, 0 = process by chain method. Default=1
#' @param DATA_LENGTH_MIN Minimum data length to include in calculations. Default=2
#' @param AVG_TIME_BETWEEN_PTS_MAX Maximum time between datapoint to include. Default=100
#' @param GLOBAL_GAM_FLAG_SHORT_DATA_FLAG # set this to 1 GAM model is also to be generated for the short time series else the log linear model will be used. Default=0
#' @param AUTO_DIAGNOSTIC_FLAG 1=Automatically determine whether GAM models are good enough, 0=Manually ask for each. Default=1
#' @param LAMBDA_MIN Minimum lambda to include in calculations. Default=1
#' @param LAMBDA_MAX Minimum lambda to include in calculations. Default=-1
#' @param ZERO_REPLACE_FLAG  0 = +minimum value; 1 = +1\% of mean value; 2 = +1. Default=2
#' @param OFFSET_ALL 1 = Add offset to all values, to avoid log(0). Default=0
#'
#' @return Returns the species lambda array for the input species
#' @export
#'
CalcLPI <- function(Species,
                    ID,
                    Year,
                    Popvalue,
                    InitialYear,
                    FinalYear,
                    DatasetName,
                    MODEL_SELECTION_FLAG,
                    GAM_GLOBAL_FLAG,  # 1 = process by GAM method, 0 = process by chain method
                    DATA_LENGTH_MIN,
                    AVG_TIME_BETWEEN_PTS_MAX,
                    GLOBAL_GAM_FLAG_SHORT_DATA_FLAG,  # set this if GAM model is also to be generated for the short time series else the log linear model will be used.
                    AUTO_DIAGNOSTIC_FLAG,
                    LAMBDA_MIN,
                    LAMBDA_MAX,
                    ZERO_REPLACE_FLAG,  # 0 = +minimum value; 1 = +1% of mean value; 2 = +1
                    OFFSET_ALL # Add offset to all values, to avoid log(0)
) {
  noRecs = max(dim(Popvalue))
  sNames = unique(Species)
  sID = unique(ID)
  noSpecies = max(dim(sNames))
  noPop = max(dim(unique(ID)))

  PopNotProcessed = matrix(0, 1, noPop)
  MethodFlag = matrix(0, 1, noPop)

  PopNotProcessedCounter = 0
  PopProcessedGAMCounter = 0
  sNamesCounter = 0
  sNamesArray = sNames
  sIDArray = sID
  PopProcessedGAM = matrix(0, 1, noPop)

  cat(sprintf("Number of species: %s (in %s populations)\n", noSpecies, noPop))
  # Calculate index value for each species
  SpeciesLambda = matrix(0, noSpecies, FinalYear - InitialYear + 1)

  prog <- txtProgressBar(min=0, max=noSpecies, char="*", style=3)

  MethodFlagLoop = 0
  for (I in 1:noSpecies) {
    #cat(".")
    Index = 1

    # Delete sIndex if it exists
    if (length(which(objects() == "sIndex")) != 0)
      rm(sIndex)

    # Get indices of this species in 'Species'
    sIndex = which(Species == toString(sNames[I, 1]))

    # Extract population data using that index
    PopID = unique(ID[sIndex, 1])

    # Delete PopLambda if it exists
    if (length(which(objects() == "PopLambda")) != 0)
      rm(PopLambda)

    PopIDSize = length(PopID)
    # Blank matrix of -1s
    PopLambda = matrix(-1, PopIDSize, FinalYear - InitialYear + 1)
    JIndex = 1
    # For each population of this species
    for (J in 1:PopIDSize) {
      IndexPop = which(ID == PopID[J])  # each population
      YearPop = Year[IndexPop, 1]
      PopN = Popvalue[IndexPop, 1]

      # Perform the data filtering
      DataTimeLength = max(YearPop) - min(YearPop)
      AvgTimeBetweenPts = DataTimeLength/length(PopN)
      # Apply data filter based on a series of criteria
      if ((length(PopN) >= DATA_LENGTH_MIN) & (AvgTimeBetweenPts < AVG_TIME_BETWEEN_PTS_MAX)) {

        if (OFFSET_ALL) {
          cat(sprintf("Offsetting all time-series by 1 to avoid log(0)\n"))
          PopN <- PopN + 1
        } else {
          # Replace zero values with 1 percent of average values
          IndexZero = which(PopN == 0)

          #cat(sprintf("Number of zero values: %d\n", length(IndexZero)))

          if (ZERO_REPLACE_FLAG == 1) {
            #cat(sprintf("Replacing zero values with 1 percent of average\n"))
            if (mean(PopN) == 0) {
              OffsetVal = 1e-17
            } else {
              IndexNonZero = which(PopN != 0)
              OffsetVal = mean(PopN[IndexNonZero]) * 0.01
            }
          } else {
            #cat(sprintf("Replacing zero values with min of non-zero\n"))

            IndexNonZero = which(PopN != 0)
            OffsetVal = min(PopN[IndexNonZero])
          }

          if (ZERO_REPLACE_FLAG == 2) {
            #cat(sprintf("Replacing zero values with 1\n"))
            if (mean(PopN) == 0) {
              OffsetVal = 1e-17
            } else {
              IndexNonZero = which(PopN != 0)
              OffsetVal = 1
            }
          }
          if (length(IndexZero) > 0)
            PopN = PopN + OffsetVal
        }


        #pdf()

        SortResults = sort(YearPop, index.return = TRUE)
        YearPop = SortResults$x
        TempI = SortResults$ix
        PopN = PopN[TempI]

        # Perform smoothing and interpolation

        if (length(which(objects() == "YearPopInt")) != 0)
          rm(YearPopInt)

        if (length(which(objects() == "PopNInt")) != 0)
          rm(PopNInt)

        YearPopInt = YearPop[1]:YearPop[length(YearPop)]

        PopNLog = log(PopN)
        Flag = 0

        # if population has the same value then no need to build GAM model and interpolate
        GAMFlag = GAM_GLOBAL_FLAG
        if (mean(PopN) == PopN[1]) {
          GAMFlag = 0
        }

        if (GAMFlag == 1) {
          if (MODEL_SELECTION_FLAG == 0) {

            SmoothParm = round(length(PopN)/2)
            if (SmoothParm >= 3) {
              # Added this as was having trouble refering to mgcv::s in formulae
              s <- mgcv::`s`
              model <- mgcv::gam(PopNLog ~ s(YearPop, k = SmoothParm), fx = TRUE)
              # check if the model is ok
              if (AUTO_DIAGNOSTIC_FLAG == 1) {
                rsd <- residuals(model)
                s <- mgcv::`s`
                modelres <- mgcv::gam(rsd ~ s(YearPop, k = length(PopN), bs = "cs"),
                                gamma = 1.4)
                if ((abs(sum(modelres$edf) - 1)) < 0.01) {
                  # 0.01
                  PopNInt <- predict(model, data.frame(YearPop = YearPopInt))
                  PopNInt = exp(PopNInt)
                  Flag = 1
                  PopProcessedGAMCounter = PopProcessedGAMCounter + 1
                  PopProcessedGAM[PopProcessedGAMCounter] = PopID[J]
                }
              } else {
                summary(model)
                readline(prompt = "Press any key to continue")
                plot(model, pages = 1, residuals = TRUE, all.terms = TRUE, shade = TRUE,
                     shade.col = 2)
                readline(prompt = "Press any key to continue")
                mgcv::gam.check(model)
                Char = readline(prompt = "Press 'Y' to accept model, 'N' to reject GAM model and use default method")
                while ((Char != "Y") & (Char != "N")) {
                  Char = readline(prompt = "Press 'Y' to accept model, 'N' to reject GAM model and use default method")
                }
                if (Char == "Y") {
                  PopNInt <- predict(model, data.frame(YearPop = YearPopInt))
                  PopNInt = exp(PopNInt)
                  Flag = 1
                  PopProcessedGAMCounter = PopProcessedGAMCounter + 1
                  PopProcessedGAM[PopProcessedGAMCounter] = PopID[J]
                }
              }
            }
          } else {
            if (length(PopN) >= 6) {
              SmoothParm = 3  # length(PopN) if K is set to max
              if (AUTO_DIAGNOSTIC_FLAG == 1) {
                while ((length(PopN) >= SmoothParm) & (Flag == 0)) {
                  s <- mgcv::`s`
                  model <- mgcv::gam(PopNLog ~ s(YearPop, k = SmoothParm), fx = TRUE)
                  rsd <- residuals(model)
                  modelres <- mgcv::gam(rsd ~ s(YearPop, k = length(PopN), bs = "cs"),
                                  gamma = 1.4)
                  if ((abs(sum(modelres$edf) - 1)) < 0.01) {
                    Flag = 1
                    PopNInt <- predict(model, data.frame(YearPop = YearPopInt))
                    PopNInt = exp(PopNInt)
                    PopProcessedGAMCounter = PopProcessedGAMCounter + 1
                    PopProcessedGAM[PopProcessedGAMCounter] = PopID[J]
                  } else {
                    SmoothParm = SmoothParm + 1
                  }
                }
              } else {
                while ((length(PopN) >= SmoothParm) & (Flag == 0)) {
                  s <- mgcv::`s`
                  model <- mgcv::gam(PopNLog ~ s(YearPop, k = SmoothParm), fx = TRUE)
                  summary(model)
                  readline(prompt = "Press any key to continue")
                  plot(model, pages = 1, residuals = TRUE, all.terms = TRUE,
                       shade = TRUE, shade.col = 2)
                  readline(prompt = "Press any key to continue")
                  mgcv::gam.check(model)
                  Char = readline(prompt = "Press 'Y' to accept model, 'N' to reject model")
                  while ((Char != "Y") & (Char != "N")) {
                    Char = readline(prompt = "Press 'Y' to accept model, 'N' to reject model")
                  }
                  if (Char == "Y") {
                    PopNInt <- predict(model, data.frame(YearPop = YearPopInt))
                    PopNInt = exp(PopNInt)
                    Flag = 1
                    PopProcessedGAMCounter = PopProcessedGAMCounter + 1
                    PopProcessedGAM[PopProcessedGAMCounter] = PopID[J]
                  } else {
                    SmoothParm = SmoothParm + 1
                  }
                }
              }
            }
          }
        }
        if (Flag == 0) {

          if (GLOBAL_GAM_FLAG_SHORT_DATA_FLAG == 1) {
            SmoothParm = length(PopN)
            s <- mgcv::`s`
            model <- mgcv::gam(PopNLog ~ s(YearPop, k = SmoothParm), fx = TRUE)
            PopNInt <- predict(model, data.frame(YearPop = YearPopInt))
            PopNInt = exp(PopNInt)
            PopProcessedGAMCounter = PopProcessedGAMCounter + 1
            PopProcessedGAM[PopProcessedGAMCounter] = PopID[J]
          } else {
            # Apply the default approach
            MethodFlagLoop = MethodFlagLoop + 1
            MethodFlag[MethodFlagLoop] = PopID[J]
            PopNInt = matrix(-1, 1, length(YearPopInt))

            for (K in 1:length(YearPopInt)) {
              k = which(YearPop == YearPopInt[K])
              if (length(k) > 0) {
                PopNInt[K] = PopN[k]
              } else {
                # find the previous value
                YearStart = YearPopInt[K]
                YearStart = YearStart - 1
                k = which(YearPop == YearStart)
                while (length(k) == 0) {
                  YearStart = YearStart - 1
                  k = which(YearPop == YearStart)
                }
                PopNStart = PopN[k]
                # find the next value
                YearEnd = YearPopInt[K]
                YearEnd = YearEnd + 1
                k = which(YearPop == YearEnd)
                while (length(k) == 0) {
                  YearEnd = YearEnd + 1
                  k = which(YearPop == YearEnd)
                }
                PopNEnd = PopN[k]
                # Calculate the interpolated value
                PopNInt[K] = PopNStart * ((PopNEnd/PopNStart)^((YearPopInt[K] -
                                                                  YearStart)/(YearEnd - YearStart)))
              }
            }
          }
        }

        # only consider from InitialYear onwards
        YearPop = InitialYear:FinalYear
        PopN = matrix(0, 1, length(YearPop))

        k = which(PopNInt == 0)
        k1 = which(PopNInt > 0)
        TempVal = 0
        if (length(k) > 0) {
          if (length(k1) > 0) {
            if (ZERO_REPLACE_FLAG == 1) {
              TempVal = mean(PopNInt[k1]) * 0.01
            } else {
              TempVal = min(PopNInt[k1])
            }
            PopNInt = PopNInt + TempVal
          }
        }
        for (K in InitialYear:FinalYear) {
          k = which(YearPopInt == K)
          if (length(k) > 0) {
            if (PopNInt[k] == 0) {
              PopN[K - InitialYear + 1] = -1
            } else PopN[K - InitialYear + 1] = log10(PopNInt[k])
          } else PopN[K - InitialYear + 1] = -1
        }

        # Calculate the growth rate
        PopLambda[JIndex, 1] = 1
        StartYear = InitialYear + 1
        for (K in StartYear:FinalYear) {
          if ((PopN[K - InitialYear + 1] != -1) & (PopN[K - InitialYear] !=
                                                   -1))
            PopLambda[JIndex, K - InitialYear + 1] = PopN[K - InitialYear +
                                                            1] - PopN[K - InitialYear] else PopLambda[JIndex, K - InitialYear + 1] = -1
        }
        JIndex = JIndex + 1
      } else {
        PopNotProcessedCounter = PopNotProcessedCounter + 1
        PopNotProcessed[PopNotProcessedCounter] = PopID[J]
      }
    }

    # Save the population lamdas to a file:

    PopData<-cbind(as.vector(PopID), PopLambda)
    pop_lambda_filename <- gsub(".txt", "_PopLambda.txt", DatasetName)
    #Pop_Headers<-t(c("population_id", as.vector(InitialYear:FinalYear)))
    #write.table(Pop_Headers,file=pop_lambda_filename, sep=",", eol="\n", quote=FALSE, col.names=FALSE, row.names = FALSE)
    write.table(PopData,sep=",", eol="\n", file=pop_lambda_filename, quote=FALSE, col.names=FALSE, row.names = FALSE, append=TRUE)


    # Save the species average lambda values

    EndYear = FinalYear - InitialYear + 1
    for (K in 1:EndYear) {
      k = which(PopLambda[, K] != -1)
      if (length(k) > 0) {
        # Exclude Lambda values outside range
        PopLambdaTemp = PopLambda[k, K]
        IndexTemp = which(PopLambdaTemp < LAMBDA_MAX)
        # Make sure lambda values below the max
        if (length(IndexTemp) > 0) {
          # Extract them as PopLambdaTemp1
          PopLambdaTemp1 = PopLambdaTemp[IndexTemp]
          IndexTemp = which(PopLambdaTemp1 > LAMBDA_MIN)
          # And above the min
          if (length(IndexTemp) > 0)
            # Then set them
            SpeciesLambda[I, K] = mean(PopLambdaTemp1[IndexTemp]) else SpeciesLambda[I, K] = NA
        } else {
          # Otherwise, set values below the min to be NA
          SpeciesLambda[I, K] = NA
        }
      } else {
        # And values above the max to be NA
        SpeciesLambda[I, K] = NA
      }
    }

    sNamesCounter = sNamesCounter + 1
    sNamesArray[sNamesCounter, 1] = sNames[I, 1]
    sIDArray[sNamesCounter] = ID[I, 1]

    # cat('Results saved\n')
    setTxtProgressBar(prog, I)
  }
  close(prog)
  cat("\n")

  PopNotProcessed1 = PopNotProcessed[1, 1:PopNotProcessedCounter]
  write.table(PopNotProcessed1, file = "lpi_temp/PopNotProcessed.txt")  # insert your desired file name here
  MethodFlag1 = MethodFlag[1, 1:MethodFlagLoop]
  write.table(MethodFlag1, file = "lpi_temp/PopProcessedChain.txt")  # insert your desired file name here
  PopProcessedGAM1 = PopProcessedGAM[1, 1:PopProcessedGAMCounter]
  write.table(PopProcessedGAM1, file = "lpi_temp/PopProcessedGAM.txt")  # insert your desired file name here
  sNamesArray1 = sNamesArray[1:sNamesCounter, 1]
  write.table(sNamesArray1, file = "lpi_temp/SpeciesName.txt", quote = FALSE)

  Headers<-t(c("Species", as.vector(InitialYear:FinalYear)))

  #sNamesT <- sNamesArray[sIDArray, 1]

  # IDs (sIDArray) is per-population and sNamesArray is per species... currently exporting species lambdas
  #SpeciesData<-cbind(sIDArray, as.vector(sNamesT), SpeciesLambda)
  SpeciesData<-cbind(as.vector(sNamesArray), SpeciesLambda)
  lambda_filename <- gsub(".txt", "_Lambda.txt", DatasetName)
  write.table(Headers,file=lambda_filename, sep=",", eol="\n", quote=FALSE, col.names=FALSE, row.names = FALSE)
  write.table(SpeciesData,sep=",", eol="\n", file=lambda_filename, quote=FALSE, col.names=FALSE, row.names = FALSE, append=TRUE)

  #sp_df = melt(SpeciesData)


  return(SpeciesLambda)
  # MethodFlag
}

