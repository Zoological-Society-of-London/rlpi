
#' calc_lambdas - calculate interannual differences from an index
#'
#' @param lpi - The index to calculate lambdas from
#'
#' @return Returns lamdbas for the lpi given
#' @export
#'
calc_lambdas <- function(lpi) {
  N = length(lpi)
  lambdas = matrix(0, N)
  lambdas[1] = 1
  for (k in 2:N) {
    lambdas[k] = log10(lpi[k]) - log10(lpi[k-1])
  }
  return(lambdas)
}



#' #' Calculate the index using the annual differences in SpeciesLambdaArray
#' @param SpeciesLambdaArray Array of DTemps (annual differences)
#' @param fileindex The index of the file that this index is for
#' @param DSize The size of the data in DTemp
#' @param Group Which group this file belongs to
#' @param Weightings What the weightings are for this group
#' @param use_weightings Whether or not to use weightings (level 1)
#' @param use_weightings_B Whether or not to use weightings (level 1)
#' @param WeightingsB What the weightingsB are for this group
#'
#' @return Returns an index
#' @export
#'
calc_leverage_lpi <- function(SpeciesLambdaArray, fileindex, DSize, Group, Weightings, use_weightings, use_weightings_B, WeightingsB) {

  NoFiles = length(unique(fileindex))
  NoGroups = length(unique(Group[[1]]))

  I = matrix(0, DSize)
  I[1] = 1

  cat(".")

  # For each year
  for (J in 2:DSize) {
    # Make two matrices of 0s of size 1xNoGroups
    D = matrix(0, 1, NoGroups)
    DI = matrix(0, 1, NoGroups)

    # For each file (population) in this file/set of species lambdas
    for (FileNo in 1:NoFiles) {

      GroupNo = Group[FileNo, 1]

      # Read SpeciesLambda from saved file FileName = paste('lpi_temp/SpeciesLambda',FileNo,sep='')
      # SpeciesLambda = read.table(FileName, header = FALSE, sep=',')

      SpeciesLambda = SpeciesLambdaArray[fileindex == FileNo, ]

      if (J <= dim(SpeciesLambda)[2]) {

        # If there's still some left to get
        # Get the lamdas for this pop (species?)
        SpeciesLambdaVal = SpeciesLambda[, J]

        # We shouldn't be sampling missing values....
        SpeciesLambdaVal = SpeciesLambdaVal[!is.na(SpeciesLambdaVal)]
        # If we've got some meaningful data
        Index = which(SpeciesLambdaVal != -1)
        if (length(Index) > 0) {

          if (use_weightings) {
            D[GroupNo] = D[GroupNo] + mean(SpeciesLambdaVal[Index])*Weightings[[1]][FileNo]
          } else {
            D[GroupNo] = D[GroupNo] + mean(SpeciesLambdaVal[Index])
          }

          DI[GroupNo] = DI[GroupNo] + 1
        }
      }
    }

    # For each D
    # Take average if there's values (otherwise 0) - so this gives group average
    for (DIndex in 1:length(D)) {
      if (use_weightings == 1) {
        if (DI[DIndex] > 1) DI[DIndex] = 1
      }
      if (DI[DIndex] > 0) {
          D[DIndex] = D[DIndex]/DI[DIndex]
      } else {
        D[DIndex] = 0
      }
    }

    DT = 0
    DI = 0
    # Sum over groups
    for (GroupNo in 1:NoGroups) {
      # CHANGED AS D CAN BE 0 I.E ZERO GROWTH (AVERAGED)
      #if (D[GroupNo] != 0) {
      if (use_weightings_B == 1) {
        # Catch any groups which have no data.
        if (!is.na(D[GroupNo])) {
          DT = DT + D[GroupNo]*WeightingsB[GroupNo]
          #DI = DI + 1
        }
        DI = 1
      } else {
        # Catch any groups which have no data.
        if (!is.na(D[GroupNo])) {
          DT = DT + D[GroupNo]
          DI = DI + 1
        }
      }
      #}
    }

    # Return the bootstrapped index
    if (DI == 0) {
      # If there was no data in this run, set to -1
      I[J] = -1
      I[J] = NA
    } else {
      if (is.na( I[J - 1])) {
        I[J] = 1 * 10^(DT/DI)
      } else {
        I[J] = I[J - 1] * 10^(DT/DI)
      }
    }
  }
  return(I)
}
