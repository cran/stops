% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/jackmds.stops.R
\name{jackmds.stops}
\alias{jackmds.stops}
\title{MDS Jackknife for stops objects}
\usage{
\method{jackmds}{stops}(object, eps = 1e-06, itmax = 5000, verbose = FALSE)
}
\arguments{
\item{object}{Object of class pcops.}

\item{eps}{Convergence criterion}

\item{itmax}{Maximum number of iterations}

\item{verbose}{If 'TRUE', intermediate stress is printed out.}
}
\value{
An object of class 'smacofJK', see \code{\link[smacof]{jackmds}}. With values 
\itemize{
\item smacof.conf: Original configuration
\item jackknife.confboot: An array of n-1 configuration matrices for each Jackknife MDS solution
\item comparison.conf: Centroid Jackknife configurations (comparison matrix)
\item cross: Cross validity
\item stab: Stability coefficient
\item disp: Dispersion
\item loss: Value of the loss function (just used internally)
\item ndim: Number of dimensions
\item call: Model call
\item niter: Number of iterations
\item nobj: Number of objects
}
}
\description{
These functions perform an MDS Jackknife and plot the corresponding solution.
}
\details{
In order to examine the stability solution of an MDS, a Jackknife on the configurations can be performed (see de Leeuw & Meulman, 1986) and plotted. The plot shows the jackknife configurations which are connected to their centroid. In addition, the original configuration (transformed through Procrustes) is plotted. The Jackknife function itself returns also a stability measure (as ratio of between and total variance), a measure for cross validity, and the dispersion around the original smacof solution.

Note that this jackknife only resamples the configuration given the selected hyperparameters, so uncertainty with respect to the hyperparameter selection is not incorporated.
}
\examples{
diso<-kinshipdelta
fit <- stops(diso,loss="stress",lower=1,upper=5)
res.jk <- jackmds(fit) 
plot(res.jk)
}
