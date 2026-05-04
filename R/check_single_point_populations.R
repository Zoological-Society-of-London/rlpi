#'Check input population files for populations with fewer than DATA_LENGTH_MIN
#' non-missing population values. These cannot produce valid interannual lambdas
#' and can cause downstream problems in PopLambda outputs.
#'
#' Internal helper for LPIMain().
#'
#' @keywords internal
#'
check_single_point_populations <- function(FileNames, infile, basedir, DATA_LENGTH_MIN = 2) {

  infile_dir <- dirname(normalizePath(infile, mustWork = FALSE))

  resolve_pop_file <- function(x) {
    candidates <- c(
      x,
      file.path(infile_dir, x),
      file.path(basedir, x)
    )

    candidates[file.exists(candidates)][1]
  }

  problem_rows <- lapply(FileNames, function(f) {

    pop_file <- resolve_pop_file(f)

    if (is.na(pop_file)) {
      stop(sprintf("Could not find population input file listed in infile: %s", f))
    }

    x <- read.table(
      pop_file,
      header = TRUE,
      sep = "\t",
      stringsAsFactors = FALSE,
      quote = "",
      comment.char = ""
    )

    required_cols <- c("Binomial", "ID", "year", "popvalue")

    if (!all(required_cols %in% names(x))) {
      stop(sprintf(
        "Population file %s does not contain required columns: %s",
        f,
        paste(required_cols, collapse = ", ")
      ))
    }

    x <- x[!is.na(x$popvalue), ]

    n_by_pop <- aggregate(
      year ~ Binomial + ID,
      data = x,
      FUN = function(z) length(unique(z[!is.na(z)]))
    )

    names(n_by_pop)[names(n_by_pop) == "year"] <- "n_values"

    bad <- n_by_pop[n_by_pop$n_values < DATA_LENGTH_MIN, ]

    if (nrow(bad) > 0) {
      bad$FileName <- f
      bad
    } else {
      NULL
    }
  })

  problem_rows <- do.call(rbind, problem_rows)

  if (!is.null(problem_rows) && nrow(problem_rows) > 0) {
    problem_rows <- problem_rows[, c("FileName", "Binomial", "ID", "n_values")]

    msg <- paste(
      capture.output(print(problem_rows, row.names = FALSE)),
      collapse = "\n"
    )

    stop(sprintf(
      paste0(
        "Input population files contain populations with fewer than %d ",
        "non-missing population values.\n\n",
        "These populations cannot produce valid interannual lambdas and should be removed ",
        "or corrected before running LPIMain().\n\n",
        "%s",
        "\n\nFix the input data or rerun with check_single_point_pops = FALSE ",
        "(not recommended)."
      ),
      DATA_LENGTH_MIN,
      msg
    ))
  }

  invisible(TRUE)
}
#
# check_single_point_populations(
#   FileNames = FileNames,
#   infile = infile,
#   basedir = basedir,
#   DATA_LENGTH_MIN = DATA_LENGTH_MIN
# )
