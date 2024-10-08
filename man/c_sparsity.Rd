% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/structurednessindices.R
\name{c_sparsity}
\alias{c_sparsity}
\title{c-sparsity}
\usage{
c_sparsity(conf, aggr = NULL)
}
\arguments{
\item{conf}{A numeric matrix.}

\item{aggr}{the aggregation function for configurations of more than two dimensions. Defaults to max.}
}
\value{
a numeric value; sparsity (see \code{\link[scagnostics]{scagnostics}})
}
\description{
Measures the c-sparsity structure
}
\examples{
delts<-smacof::kinshipdelta
conf<-smacof::smacofSym(delts)$conf
plot(conf,pch=19,asp=1)
c_sparsity(conf)
}
