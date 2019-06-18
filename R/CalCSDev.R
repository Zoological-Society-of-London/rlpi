#' CalcSDev - Calculates the difference operator on vector x to give an approximate
#' second derivative curve for x.
#'
#' @param x the vector to calculate differences on
#' @param h is the desired window size. Corresponds to the quantity r in eqns 9, 10, and 11 of the Ecology paper.  Usually h will be chosen to be the smallest possible (h=1) but try experimenting with h=2 and h=3 to see if it has much effect on the changepoints.
#' @param d d is the order of the difference operator: can be 2, 4, or 6, representing the second derivative estimates obtained from 2nd differences, 4th differences, or 6th differences (eqns 9, 10, and 11 in the Ecology paper)  d=6 should give the most accurate results, but again try experimenting with d=4 and d=2.
#' @param interval is the time elapsed between points of x, which will be treated as 1 unit: e.g. if x consists of records taken every 2 years, then 2 years is equal to 1 unit, and interval=2.  Usually interval=1.
#'
#' @return Returns the approx second derivative of a curve for x
#' @export
#'
CalcSDev <- function(x, h, d, interval) {
  # diffop.func: Calculates the difference operator on vector x to give an approximate
  # second derivative curve for x.  h is the desired window size (see below).
  # Corresponds to the quantity r in eqns 9, 10, and 11 of the Ecology paper.  Usually
  # h will be chosen to be the smallest possible (h=1) but try experimenting with h=2
  # and h=3 to see if it has much effect on the changepoints.  d is the order of the
  # difference operator: can be 2, 4, or 6, representing the second derivative
  # estimates obtained from 2nd differences, 4th differences, or 6th differences (eqns
  # 9, 10, and 11 in the Ecology paper).  d=6 should give the most accurate results,
  # but again try experimenting with d=4 and d=2.
  # 'interval' is the time elapsed between points of x, which will be treated
  # as 1 unit: e.g. if x consists of records taken every 2 years, then 2 years is
  # equal to 1 unit, and interval=2.  Usually interval=1.  The window size h is
  # measured relative to the interval variable, so if the window extends h units then
  # it covers (h*interval) of actual time: e.g. if interval = 2 years, and h = 3
  # units, then actual window size is 2*3=6 years).  [The reason for this setup is
  # because the function works with the quantity x[t+h], not x(t+h) --- i.e. h is the
  # index of a vector element, not a measurement of time.  Note however that to obtain
  # the 2nd derivative, the h^2 on the denominator of eqns 9, 10, and 11 is supposed
  # to be a measurement of time; so in this function we have to divide by
  # (h*interval)^2 (see penultimate line of code where the adjustment by interval^2 is
  # made), instead of just by h^2.] d must be 2, 4 or 6 so check this
  if (is.na(match(d, c(2, 4, 6))))
    stop("d must be 2, 4 or 6.")  #
  # now work out the vector of window sizes: at endpoints it is not possible to use
  # d=4 or d=6, or h>1, because there are insufficiently many points at the end of the
  # series to accommodate the larger windows required.  Thus whatever values were
  # specified for d and h, the endpoints of the series must have d=2 and h=1.  This
  # function maintains h at 1 until sufficiently far from the endpoints to allow d to
  # increase (if necessary) to its specified value, after which h is also allowed to
  # increase (if necessary) to its specified value.  The actual window sizes used for
  # every time point in the series are stored in vector hvec:
  N <- length(x)  # x is recorded at N equally spaced points
  hvec <- 1:(N/2)
  hvec <- (hvec - 1)%/%(d/2)
  hvec[hvec > h] <- h
  if (N%%2) {
    hvec <- c(hvec, max(hvec), rev(hvec))
  } else {
    # (N odd)
    hvec <- c(hvec, rev(hvec))
  }
  hvec[hvec == 0] <- 1  #
  # similarly, dvec stores the actual values (2, 4, or 6) for the difference operator
  # d along the series:
  dvec <- rep(d, N)
  if (d == 6) {
    dvec[c(2, N - 1)] <- 2
    dvec[c(3, N - 2)] <- 4
  } else if (d == 4) {
    dvec[c(2, N - 1)] <- 2
  }
  dvec[c(1, N)] <- 0  #
  # Now code the various difference operators approximating 2nd derivative,
  # corresponding to d=2, 4, or 6.  xinds is the set of indices of x for which the
  # derivative is to be calculated (usually all those with d taking a certain value).
  # hvals are the h-values corresponding to those indices in xinds.
  diff.op2 <- function(xinds, hvals) {
    (x[xinds + hvals] - 2 * x[xinds] + x[xinds - hvals])/hvals^2
  }
  diff.op4 <- function(xinds, hvals) {
    (-x[xinds + 2 * hvals] + 16 * x[xinds + hvals] - 30 * x[xinds] + 16 * x[xinds -
                                                                              hvals] - x[xinds - 2 * hvals])/(12 * hvals^2)
  }
  diff.op6 <- function(xinds, hvals) {
    (2 * x[xinds + 3 * hvals] - 27 * x[xinds + 2 * hvals] + 270 * x[xinds + hvals] -
       490 * x[xinds] + 270 * x[xinds - hvals] - 27 * x[xinds - 2 * hvals] + 2 *
       x[xinds - 3 * hvals])/(180 * hvals^2)
  }

  secderiv <- numeric(N)
  secderiv[0] <- 0
  secderiv[N] <- 0
  # apply the relevant difference operators throughout the series to get the estimate
  # secderiv of the second derivative vector:
  secderiv[dvec == 2] <- diff.op2((1:N)[dvec == 2], hvec[dvec == 2])
  secderiv[dvec == 4] <- diff.op4((1:N)[dvec == 4], hvec[dvec == 4])
  secderiv[dvec == 6] <- diff.op6((1:N)[dvec == 6], hvec[dvec == 6])
  # correct for interval^2 as described above:
  SecDeriv <- secderiv/(interval^2)
  SecDeriv
}
