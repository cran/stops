% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stop_apstress.R
\name{stop_apstress}
\alias{stop_apstress}
\title{STOPS version of approximated power stress models.}
\usage{
stop_apstress(
  dis,
  theta = c(1, 1, 1),
  type = "ratio",
  ndim = 2,
  weightmat = 1 - diag(nrow(dis)),
  init = NULL,
  itmaxi = 1000,
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

\item{theta}{the theta vector of parameters to optimize over. Must be of length three, with the first the kappa argument, the second the lambda argument and the third the nu argument. One cannot supply upsilon and tau as of yet. Defaults to 1 1 1.}

\item{type}{MDS type.}

\item{ndim}{number of dimensions of the target space}

\item{weightmat}{(optional) a binary matrix of nonnegative weights}

\item{init}{(optional) initial configuration}

\item{itmaxi}{number of iterations. default is 1000.}

\item{...}{additional arguments to be passed to the fitting procedure}

\item{stressweight}{weight to be used for the fit measure; defaults to 1}

\item{structures}{a character vector listing the structure indices to use. They always are called "cfoo" with foo being the structure.}

\item{strucweight}{weight to be used for the structures; defaults to 1/number of structures}

\item{strucpars}{a list of list of parameters for the structuredness indices; each list element corresponds to one index in the order of the appearance in structures vector. See examples.}

\item{verbose}{numeric value hat prints information on the fitting process; >2 is extremely verbose}

\item{stoptype}{which weighting to be used in the multi-objective optimization? Either 'additive' (default) or 'multiplicative'.}

\item{registry}{registry object with c-structuredness indices.}
}
\value{
A list with the components
   \itemize{
        \item{stress:} the stress-1 value (sqrt stress.m)
        \item{stress.m:} default normalized stress
         \item stoploss: the weighted loss value
        \item struc: the structuredness indices
        \item parameters: the parameters used for fitting (kappa, lambda, nu)
        \item fit: the returned object of the fitting procedure
        \item{stopobj:} the stopobj object 
}
}
\description{
This uses an approximation to power stress that can make use of smacof as workhorse. Free parameters are kappa, lambda and nu.
}
\keyword{multivariate}
