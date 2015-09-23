#' Function to print if the global variable 'DEBUG' is set
#'
#' @param verbose Flag to control printing
#' @param text Text to print
#'
#' @export
#'
debug_print <- function(verbose = FALSE, text) {
  if (verbose) {
    cat(paste("[debug] ", text, sep=""))
  }
}
