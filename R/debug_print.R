#' Function to print if the global variable 'DEBUG' is set
#'
#' @param text Text to print
#'
#' @export
#'
debug_print <- function(text) {
  if (DEBUG) {
    cat(paste("[debug] ", text, sep=""))
  }
}
