#' MDS Jackknife for stops objects
#'
#' These functions perform an MDS Jackknife and plot the corresponding solution. 
#'
#' @param object  Object of class pcops.
#' @param eps Convergence criterion
#' @param itmax Maximum number of iterations 
#' @param verbose If 'TRUE', intermediate stress is printed out.
#'
#' @details  In order to examine the stability solution of an MDS, a Jackknife on the configurations can be performed (see de Leeuw & Meulman, 1986) and plotted. The plot shows the jackknife configurations which are connected to their centroid. In addition, the original configuration (transformed through Procrustes) is plotted. The Jackknife function itself returns also a stability measure (as ratio of between and total variance), a measure for cross validity, and the dispersion around the original smacof solution.
#'
#' Note that this jackknife only resamples the configuration given the selected hyperparameters, so uncertainty with respect to the hyperparameter selection is not incorporated.
#'
#' @return An object of class 'smacofJK', see \code{\link[smacof]{jackmds}}. With values 
#' \itemize{
#' \item smacof.conf: Original configuration
#' \item jackknife.confboot: An array of n-1 configuration matrices for each Jackknife MDS solution
#' \item comparison.conf: Centroid Jackknife configurations (comparison matrix)
#' \item cross: Cross validity
#' \item stab: Stability coefficient
#' \item disp: Dispersion
#' \item loss: Value of the loss function (just used internally)
#' \item ndim: Number of dimensions
#' \item call: Model call
#' \item niter: Number of iterations
#' \item nobj: Number of objects
#' }
#'
#'
#' @importFrom smacof jackmds
#' 
#' @export
#' @examples
#' diso<-kinshipdelta
#' fit <- stops(diso,loss="stress",lower=1,upper=5)
#' res.jk <- jackmds(fit) 
#' plot(res.jk)
jackmds.stops<- function(object, eps = 1e-6, itmax = 5000, verbose = FALSE) 
{
    calli <- match.call()
    result <- smacof::jackmds(object$fit,eps=eps,itmax=itmax,verbose=verbose)
    result$call <- calli
    result
}

