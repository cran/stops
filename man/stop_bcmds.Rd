% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stop_bcmds.R
\name{stop_bcmds}
\alias{stop_bcmds}
\title{STOPS version of Box Cox Stress}
\usage{
stop_bcmds(
  dis,
  theta = c(1, 1, 0),
  type = "ratio",
  weightmat = NULL,
  init = NULL,
  ndim = 2,
  itmaxi = 5000,
  ...,
  stressweight = 1,
  structures = c("cclusteredness", "clinearity", "cdependence", "cmanifoldness",
    "cassociation", "cnonmonotonicity", "cfunctionality", "ccomplexity", "cfaithfulness",
    "cregularity", "chierarchy", "cconvexity", "cstriatedness", "coutlying",
    "cskinniness", "csparsity", "cstringiness", "cclumpiness", "cinequality"),
  strucweight = rep(1/length(structures), length(structures)),
  strucpars,
  verbose = 0,
  stoptype = c("additive", "multiplicative"),
  registry = struc_reg
)
}
\arguments{
\item{dis}{numeric matrix or dist object of a matrix of proximities}

\item{theta}{the theta vector of powers; the first is mu (for the fitted distances), the second lambda (for the  proximities), the third nu (for the weights). If a scalar is given it is recycled.  Defaults to 1 1 0.}

\item{type}{MDS type. Is ignored here.}

\item{weightmat}{(not used)}

\item{init}{(optional) initial configuration}

\item{ndim}{number of dimensions of the target space}

\item{itmaxi}{number of iterations}

\item{...}{additional arguments to be passed to the fitting procedure}

\item{stressweight}{weight to be used for the fit measure; defaults to 1}

\item{structures}{which structures to look for}

\item{strucweight}{weight to be used for the structures; defaults to 0.5}

\item{strucpars}{a list of parameters for the structuredness indices; each list element corresponds to one index in the order of the appeacrance in structures}

\item{verbose}{numeric value hat prints information on the fitting process; >2 is extremely verbose}

\item{stoptype}{which weighting to be used in the multi-objective optimization? Either 'additive' (default) or 'multiplicative'.}

\item{registry}{registry object with c-structuredness indices.}
}
\value{
A list with the components
\itemize{
        \item stress: the stress-1
        \item stress.m: default normalized stress
        \item stoploss: the weighted loss value
        \item struc: the structuredness indices
        \item parameters: the parameters used for fitting (kappa, lambda)
        \item fit: the returned object of the fitting procedure
         \item{stopobj:} the stopobj object 
}
}
\description{
STOPS version of Box Cox Stress
}
\keyword{multivariate}
