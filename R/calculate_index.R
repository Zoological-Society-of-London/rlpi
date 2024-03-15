#' Calculate the index using the annual differences in DTempArray
#'
#' @param DTempArray Array of DTemps (annual differences)
#' @param fileindex The index of the file that this index is for
#' @param DSize The size of the data in DTemp
#' @param Group Which group this file belongs to
#' @param Weightings What the weightings are for this group
#' @param use_weightings Whether or not to use weightings (level 1)
#' @param use_weightings_B Whether or not to use weightings (level 1)
#' @param WeightingsB What the weightingsB are for this group
#'
#' @return index - the calculated index
#' @export
#'
calculate_index <- function(DTempArray, fileindex, DSize, Group, Weightings, use_weightings, use_weightings_B, WeightingsB) {
  # calculate LPI

  NoFiles <- length(unique(fileindex))
  NoGroups <- length(unique(Group[[1]]))

  I <- matrix(0, DSize)
  I[1] <- 1

  # For each year indexed as 'J'
  for (J in 2:DSize) {
    # Create two vectors, one for summing 'lambdas' one for counting number summed
    D <- matrix(0, 1, NoGroups)
    DI <- matrix(0, 1, NoGroups)

    # cat("DI: ", DI, "\n")
    # cat("NoGroups: ", NoGroups, "\n")
    # For each file
    for (FileNo in 1:NoFiles) {
      GroupNo <- Group[FileNo, 1]
      # cat("GroupNo: ", GroupNo, "\n")
      # cat("Group: \n")
      # print(Group)
      # Read SpeciesLambda and DTemp from saved file
      # SpeciesLambdas are the annual differences in population for each species (row for each sp)
      # SpeciesLambda = SpeciesLambdaArray[fileindex == FileNo, ]

      # DTemps are the mean annual differences in population for each group/file
      # DTemp for this group/file
      DTemp <- as.matrix(DTempArray[FileNo, ])

      # cat("DTemp: ", DTemp, "\n")

      if (J <= dim(DTemp)[2]) {
        # If it's not a missing value
        if (!is.na(DTemp[J])) {
          # or an earlier flag value
          if (DTemp[J] != -99) {
            if (use_weightings == 1) {
              # cat(sprintf("Using weighting %f for file number %d\n", Weightings[[1]][FileNo], FileNo))
              D[GroupNo] <- D[GroupNo] + DTemp[J] * Weightings[[1]][FileNo]
            } else {
              D[GroupNo] <- D[GroupNo] + DTemp[J]
            }
            DI[GroupNo] <- DI[GroupNo] + 1
          }
        }
      }
    }

    # cat("\n-D: \n", D, "\n")
    # cat("\n-DI: \n", DI, "\n")

    for (DIndex in 1:length(D)) {
      if (use_weightings == 1) {
        if (DI[DIndex] > 1) DI[DIndex] <- 1
      }
      # If more than one file contributed, take the average
      if (DI[DIndex] > 0) {
        D[DIndex] <- D[DIndex] / DI[DIndex]
      } else {
        # Otherwise, if no files contributed, set to 0??
        # D[DIndex] = 0
        # Surely better to flag missing value
        D[DIndex] <- NA
      }
    }

    # Average over groups
    DT <- 0
    DI <- 0
    # cat("DT: \n", DT, "\n")
    # cat("DI: \n", DI, "\n")
    # cat("WeightingsB: \n", WeightingsB, "\n")
    for (GroupNo in seq(1, NoGroups)) {
      # Changed as d can be 0 I.E zero growth (averaged)
      # if (D[GroupNo] != 0) {
      if (use_weightings_B == 1) {
        # cat(WeightingsB, "\n")
        if (!is.na(D[GroupNo])) {
          DT <- DT + D[GroupNo] * WeightingsB[GroupNo]
          # DI = DI + 1
          # cat("A: ", DT, "\n")
        } else {
          warning(sprintf("Group %d is NA in year %d\n", GroupNo, J))
        }
        DI <- 1
      } else {
        if (!is.na(D[GroupNo])) {
          DT <- DT + D[GroupNo]
          DI <- DI + 1
          # cat("B: ", DT, "\n")
        } else {
          warning(sprintf("Group %d is NA in year %d\n", GroupNo, J))
        }
      }
      # }
    }

    # if (use_weightings == 1) {
    #  if (DI > 1) DI = 1
    # }

    # cat("DT: \n", DT, "\n")
    # cat("DI: \n", DI, "\n")

    # cat("I: ", I, "\n")

    if (is.na(DT)) {
      I[J] <- NA
      warning(sprintf("Year %d is NA\n", J))
      warning(sprintf("**** Assuming lambda of 0 ***** \n"))
      I[J] <- I[J - 1] * 10^(0)
    } else {
      if (DI > 0) {
        if (is.na(I[J - 1]) | (I[J - 1] == -99)) {
          I[J] <- 1 * 10^(DT / DI)
          warning(sprintf("**** [Year %d] Previous year data missing, assuming '1' **** \n", J))
        } else {
          I[J] <- I[J - 1] * 10^(DT / DI)
        }
      } else {
        # I[J] = -99
        I[J] <- NA
        warning(sprintf("Year %d has no groups (DI == 0)\n", J))
        warning(sprintf("**** Assuming lambda of 0 ***** \n"))
        I[J] <- I[J - 1] * 10^(0)
      }
    }
  }
  return(I)
}
