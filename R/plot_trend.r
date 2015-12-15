#' Plot estimated trend and credible intervals
#'
#' Plot posterior median of trend parameters and associated credible intervals.
#' @param theta A list generated by \code{extractTheta} function.  If \code{theta} is specified, do not specify a value for \code{mfit}.
#' @param mfit An object containing posterior draws from a \code{bsmfit} or \code{stan} model fit.  The object can be of class 'stanfit', 'array', 'matrix', or 'data.frame'.  Do not specify \code{theta} if \code{mfit} is specified.
#' @param obstype Name of probability distribution of observations.  This controls the back-transformation of the process parameters.  Possible obstypes are 'normal', 'poisson', or 'binomial'. Assumed link functions are the log for 'poisson' and logit for 'binomial'.
#' @param alpha Controls level for (1-alpha) Bayesian credible intervals.
#' @param obsvec Vector of observations. Assumed to be ordered by time with one observation per time point. If obsvec is NULL, then data are not plotted.
#' @param timelab Label for time variable.  Can be a numeric or character vector.  Must be the same length as observation vector.  If not specified, then a sequence from 1 to the total number of observations with unit time step is used.
#' @param colset Color set for trend and credible intervals.  These are presets chosen with common color combinations.  Choices are 'blue', 'purple', 'red', 'green', and 'gray'. This parameter is overridden If trend.col and bci.col are specified.
#' @param trend.col Color of the trend line.  Any standard \code{R} plotting colors are allowed. Use this along with bci.col if color choices other than the presets provided by colset are desired.
#' @param bci.col Color of the credible interval band. Any standard \code{R} colors are allowed.
#' @param ... Additional parameters passed to the plot function.
#' @details  The input can be either in the form of a list generated by the \code{extractTheta} function (passed in as the \code{theta} variable) or as a raw model fit object from \code{bnps} or \code{rstan} (passed in as \code{mfit}).  Note that using \code{mfit} is more computationally costly than using \code{theta} because the \code{extract_theta} function is called when \code{mfit} is specified.
#' @return Returns a plot object.
#' @export
#'
#'
plot_trend <- function(theta=NULL, mfit=NULL,  obstype="normal", alpha=0.05, obsvec=NULL, timelab=NULL, colset="blue", trend.col=NULL, bci.col=NULL, ...){


	if (is.null(theta) & is.null(mfit)) stop("Must specify either a list with theta summary or a stan model fit object.")
	if (is.null(theta) & !is.null(mfit))	thp <- extract_theta(mfit, obstype, alpha)
  if (!is.null(theta) & !is.null(mfit)) stop("Must specify either a list with theta summary or a stan model fit object, but not both.")
	if (!is.null(theta) & is.null(mfit)) {
		  if (class(theta)!="list") stop("Argument theta must be a list.")
		  thp <- theta
	}


	if (is.null(trend.col) & is.null(bci.col)) {
		if (!(colset %in% c('blue','green','purple','red','gray')) ) stop("Preset colors for colset are 'blue', 'green', 'red', 'purple', and 'gray'.")
		if (colset=="blue"){
			tcol <- "blue"
			bcol <- "lightblue"
		}
		if (colset=="green"){
			tcol <- "green3"
			bcol <- "lightgreen"
		}
		if (colset=="red"){
			tcol <- "red"
			bcol <- "pink"
		}
		if (colset=="purple") {
			tcol <- "purple"
			bcol <- "lavender"
		}
		if (colset=="gray"){
			tcol <- "black"
			bcol <- "gray80"
		}
	}

	if (is.null(trend.col) & !is.null(bci.col)) stop("Must specify trend.col if specifying bci.col")
	if (!is.null(trend.col) & is.null(bci.col)) stop("Must specify bci.col if specifying trend.col")
	if (!is.null(trend.col) & !is.null(bci.col) ) {
		tcol <- trend.col
		bcol <- bci.col
	}

	nn <- length(thp$postmed)
	tv <- 1:nn
	if (is.null(timelab)) timelab <- tv
	if (!is.null(timelab)) tv <- timelab
	prng <- range(c(thp$bci.lower, thp$bci.upper, obsvec))
  dum <- seq(prng[1], prng[2], length=nn)

	plot(tv, dum, type="n", ylim=prng , xaxt="n",  ...)
	  axis(side=1, at=pretty(tv), labels=pretty(timelab) )
	  polygon(c(tv, rev(tv)), c(thp$bci.lower , rev(thp$bci.upper)), border=NA, col=bcol)
	  if (!is.null(obsvec)) points(tv, obsvec, pch=1, col="gray70",  cex=1)
	  lines(tv, thp$postmed, col=tcol, lwd=3)

}

