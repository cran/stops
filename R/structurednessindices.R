#' c-inequality
#' Calculates c-inequality (as in an economic measure of inequality) as Pearsons coefficient of variation of the fitted distance matrix. This can help with avoiding degenerate solutions.   
#' This is one of few c-structuredness indices not between 0 and 1, but 0 and infinity.
#' @param confs a numeric matrix or data frame
#' @param ... additional arguments (don't do anything)
#' 
#' @importFrom stats dist sd
#'
#' @return a numeric value; inequality (Pearsons coefficient of variation of the fitted distance matrix)
#' 
#' @examples
#' x<-1:10
#' y<-2+3*x+rnorm(10)
#' z<- sin(y-x)
#' confs<-cbind(z,y,x)
#' c_inequality(confs)
#' @export
c_inequality <- function(confs,...)
    {
        distm <- stats::dist(confs)
        out <- stats::sd(distm,na.rm=TRUE)/mean(distm,na.rm=TRUE)
    }



#'c-linearity
#'calculates c-linearity as the aggregated multiple correlation of all columns of the configuration.
#'
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' 
#' @importFrom stats lm summary.lm
#'
#' @return a numeric value; linearity (aggregated multiple correlation of all columns of the configuration)
#' 
#' @examples
#' x<-1:10
#' y<-2+3*x+rnorm(10)
#' z<- sin(y-x)
#' confs<-cbind(z,y,x)
#' c_linearity(confs)
#' @export
c_linearity <- function(confs,aggr=NULL)
{
        if(is.null(aggr)) aggr <- max #we need this for the registry mechanism to be able to pass a NULL as second argument after confs
        confs <- scale(confs)
        p <- dim(confs)[2]
        tmp <- numeric()
        for(i in 1:p)
            {
             y <- confs[,i]
#        n <- dim(confs)[1]
             x <- confs[,-i]
             tmp[i] <- summary(stats::lm(y~x))$r.squared
            # rsq[i] <- summary(tmp[i])$r.squared
           }
        out <- aggr(sqrt(tmp))
        out
    }


#'c-dependence
#'calculates c-dependence as the aggregated distance correlation of each pair if nonidentical columns
#'
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' @param index exponent on Euclidean distance, in (0,2]
#'
#'
#' @return a numeric value; dependence (aggregated distance correlation)
#' @importFrom energy dcor
#' 
#' @examples
#' x<-1:10
#' y<-2+3*x+rnorm(10)
#' confs<-cbind(x,y)
#' c_dependence(confs,1.5)
#' @export
c_dependence <- function(confs,aggr=NULL,index=1)
{
        if(is.null(aggr)) aggr <- max      
        if(dim(confs)[2]<2) stop("Distance correlation is not defined for one column.")
        if(dim(confs)[2]==2) {
            x <- confs[,1]
            y <- confs[,2]
            out <- energy::dcor(x,y,index)
        }
        if(dim(confs)[2]>2) {
            n <- ncol(confs)
            #dist cor is symmetric so we just do it for the n(n-1)/2 possibilities
            matpw <- rep(NA,choose(n,2)) 
            j1 <- rep.int(1:(n-1), (n-1):1) #all k
            j2 <- sequence((n-1):1) +j1 #all l<k
            for(i in 1:length(matpw))
                {
                    x1 <- confs[,j1[i]]
                    y1 <- confs[,j2[i]] 
                    matpw[i] <- energy::dcor(x1,y1,index)        
                }
            out <- aggr(matpw)
           }
        out
    }


#'c-manifoldness
#'calculates c-manifoldness as the aggregated maximal correlation coefficient (i.e., Pearson correlation of the ACE transformed variables) of all pairwise combinations of two different columns in confs. If there is an NA (happens usually when the optimal transformation of any variable is a constant and therefore the covariance is 0 but also one of the sds in the denominator), it gets skipped. 
#'
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#'
#' @return a numeric value; manifoldness (aggregated maximal correlation, correlation of ACE tranformed x and y, see \code{\link[acepack]{ace}}) 
#' 
#' @importFrom acepack ace
#' @importFrom stats cor
#' 
#' @examples
#' x<--100:100
#' y<-sqrt(100^2-x^2)
#' confs<-cbind(x,y)
#' c_manifoldness(confs)
#' @export
c_manifoldness <- function(confs,aggr=NULL)
{
        if(is.null(aggr)) aggr <- max  
        if(dim(confs)[2]<2) stop("Maximal correlation is not available for less than two column vectors.")
        #max cor is not symmetric 
        #if(dim(confs)[2]==2){
        #    x <- confs[,1]
        #    y <- confs[,2]
        #    tmp1 <- acepack::ace(x,y)
        #    tmp2 <- acepack::ace(y,x)
        #    out1 <- stats::cor(tmp1$tx,tmp1$ty)
        #    out2 <- stats::cor(tmp1$tx,tmp1$ty)
        #    out <- max(out1,out2)
        #}
        if(dim(confs)[2]>=2) {
            #max cor is not symmetric so we look at all combinations
            n <- ncol(confs)
            matpw <- rep(NA,n^2-n) #all combination apart from k=l
            j1 <- expand.grid(1:n, 1:n) #all k,l combis incl k=l
            j2 <- j1[-which(j1[,1]/j1[,2]==1),] #remove the k=l
            for(i in 1:length(matpw))
                {
                    x <- confs[,j2[i,1]] #first col is k
                    y <- confs[,j2[i,2]] #second col is l
                    tmp <- acepack::ace(x,y)
                    matpw[i] <- stats::cor(tmp$tx,tmp$ty) #all max corr 
                }
            out <- aggr(matpw,na.rm=TRUE) #maximum over all
           }
        out
    }


#'wrapper for getting the mine coefficients
#'
#' @param confs a numeric matrix or data frame with two columns
#' @param master the master column 
#' @param alpha an optional number of cells allowed in the X-by-Y search-grid. Default value is 0.6
#' @param C an optional number determining the starting point of the X-by-Y search-grid. When trying to partition the x-axis into X columns, the algorithm will start with at most C X clumps. Default value is 15. 
#' @param var.thr minimum value allowed for the variance of the input variables, since mine can not be computed in case of variance close to 0. Default value is 1e-5.
#' @param zeta integer in [0,1] (?).  If NULL (default) it is set to 1-MIC. It can be set to zero for noiseless functions, but the default choice is the most appropriate parametrization for general cases (as stated in Reshef et al. SOM; they call it epsilon in the paper). It provides robustness.
#'
#' 
#' @importFrom minerva mine
c_mine <- function(confs,master=NULL,alpha=0.6,C=15,var.thr=1e-5,zeta=NULL)
    {
        #if(dim(confs)[2]>2) stops("MINE is not defined for more than two column vectors.")
        out <- minerva::mine(x=confs,master=master,alpha=alpha,C=C,var.thr=var.thr,eps=zeta)
        out
    }

#' c-association
#' calculates the c-association based on the maximal information coefficient 
#' We define c-association as the aggregated association between any two columns in confs
#' 
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' @param alpha an optional number of cells allowed in the X-by-Y search-grid. Default value is 0.6
#' @param C an optional number determining the starting point of the X-by-Y search-grid. When trying to partition the x-axis into X columns, the algorithm will start with at most C X clumps. Default value is 15. 
#' @param var.thr minimum value allowed for the variance of the input variables, since mine can not be computed in case of variance close to 0. Default value is 1e-5.
#' @param zeta integer in [0,1] (?).  If NULL (default) it is set to 1-MIC. It can be set to zero for noiseless functions, but the default choice is the most appropriate parametrization for general cases (as stated in Reshef et al). It provides robustness.
#' 
#' @importFrom minerva mine
#'
#' @return a numeric value; association (aggregated maximal information coefficient MIC, see \code{\link[minerva]{mine}})
#' 
#' @examples
#' x<-seq(-3,3,length.out=200)
#' y<-sqrt(3^2-x^2)
#' z<- sin(y-x)
#' confs<-cbind(x,y,z)
#' c_association(confs)
#' @export
c_association <- function(confs,aggr=NULL,alpha=0.6,C=15,var.thr=1e-5,zeta=NULL)
{
                                        #symmetric
        if(is.null(aggr)) aggr <- max
        tmp <- c_mine(confs=confs,master=NULL,alpha=alpha,C=C,var.thr=var.thr,zeta=zeta)$MIC
        tmp <- tmp[lower.tri(tmp)] #to get rid of the main diagonal
        out <- aggr(tmp) #the question is how to aggregate this for more than two dimensions, I now use the maximum so the maximum association of any two dimensions is looked at - but perhaps a harmonic mean or even the arithmetic one might be better 
        out
    }

#' c-nonmonotonicity
#' calculates the c-nonmonotonicity based on the maximum asymmetric score 
#' We define c-nonmonotonicity as the aggregated nonmonotonicity between any two columns in confs
#' this is one of few c-structuredness indices not between 0 and 1
#' 
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' @param alpha an optional number of cells allowed in the X-by-Y search-grid. Default value is 1
#' @param C an optional number determining the starting point of the X-by-Y search-grid. When trying to partition the x-axis into X columns, the algorithm will start with at most C X clumps. Default value is 15. 
#' @param var.thr minimum value allowed for the variance of the input variables, since mine can not be computed in case of variance close to 0. Default value is 1e-5.
#' @param zeta integer in [0,1] (?).  If NULL (default) it is set to 1-MIC. It can be set to zero for noiseless functions, but the default choice is the most appropriate parametrization for general cases (as stated in Reshef et al. SOM). It provides robustness.
#' 
#' @importFrom minerva mine
#'
#' @return a numeric value; nonmonotonicity (aggregated maximal asymmetric score MAS, see \code{\link[minerva]{mine}})
#' 
#' @examples
#' x<-seq(-3,3,length.out=200)
#' y<-sqrt(3^2-x^2)
#' z<- sin(y-x)
#' confs<-cbind(x,y,z)
#' c_nonmonotonicity(confs)
#' @export
c_nonmonotonicity <- function(confs,aggr=NULL,alpha=1,C=15,var.thr=1e-5,zeta=NULL)
{
                                        #symmetric
        if(is.null(aggr)) aggr <- max
        tmp <- c_mine(confs=confs,master=NULL,alpha=alpha,C=C,var.thr=var.thr,zeta=zeta)$MAS
        tmp <- tmp[lower.tri(tmp)] #to get rid of the main diagonal
        out <- aggr(tmp) #the question is how to aggregate this for more than two dimensions, I now use the maximum so the maximum association of any two dimensions is looked at - but perhaps a harmonic mean or even the arithmetic one might be better 
        out
    }

#' c-functionality
#' calculates the c-functionality based on the maximum edge value 
#' We define c-functionality as the aggregated functionality between any two columns of confs
#' 
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to mean
#' @param alpha an optional number of cells allowed in the X-by-Y search-grid. Default value is 1
#' @param C an optional number determining the starting point of the X-by-Y search-grid. When trying to partition the x-axis into X columns, the algorithm will start with at most C X clumps. Default value is 15. 
#' @param var.thr minimum value allowed for the variance of the input variables, since mine can not be computed in case of variance close to 0. Default value is 1e-5.
#' @param zeta integer in [0,1] (?).  If NULL (default) it is set to 1-MIC. It can be set to zero for noiseless functions, but the default choice is the most appropriate parametrization for general cases (as stated in Reshef et al.). It provides robustness.
#' 
#' @importFrom minerva mine
#'
#'
#' @return a numeric value; functionality (aggregated maximaum edge value MEV, see \code{\link[minerva]{mine}})
#' 
#' @examples
#' x<-seq(-3,3,length.out=200)
#' y<-sqrt(3^2-x^2)
#' z<- sin(y-x)
#' confs<-cbind(x,y,z)
#' c_functionality(confs)
#' @export
c_functionality <- function(confs,aggr=NULL,alpha=1,C=15,var.thr=1e-5,zeta=NULL)
{
                                        #symmetric
        if(is.null(aggr)) aggr <- max
        tmp <- c_mine(confs=confs,master=NULL,alpha=alpha,C=C,var.thr=var.thr,zeta=zeta)$MEV
        tmp <- tmp[lower.tri(tmp)] #to get rid of the main diagonal
        out <- aggr(tmp) 
        out
    }

#' c-complexity
#' Calculates the c-complexity based on the minimum cell number
#' We define c-complexity as the aggregated minimum cell number between any two columns in confs 
#' This is one of few c-structuredness indices not between 0 and 1, but can be between 0 and (theoretically) infinity
#' 
#' @param confs a numeric matrix or data frame
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to min.
#' @param alpha an optional number of cells allowed in the X-by-Y search-grid. Default value is 1
#' @param C an optional number determining the starting point of the X-by-Y search-grid. When trying to partition the x-axis into X columns, the algorithm will start with at most C X clumps. Default value is 15. 
#' @param var.thr minimum value allowed for the variance of the input variables, since mine can not be computed in case of variance close to 0. Default value is 1e-5.
#' @param zeta integer in [0,1] (?).  If NULL (default) it is set to 1-MIC. It can be set to zero for noiseless functions, but the default choice is the most appropriate parametrization for general cases (as stated in Reshef et al.). It provides robustness.
#' 
#' @importFrom minerva mine
#'
#' @return a numeric value; complexity (aggregated minimum cell number MCN, see \code{\link[minerva]{mine}})
#' 
#' @examples
#' x<-seq(-3,3,length.out=200)
#' y<-sqrt(3^2-x^2)
#' z<- sin(y-x)
#' confs<-cbind(x,y,z)
#' c_complexity(confs)
#' @export
c_complexity <- function(confs,aggr=NULL,alpha=1,C=15,var.thr=1e-5,zeta=NULL)
{
      if(is.null(aggr)) aggr <- min
    #symmetric
        tmp <- c_mine(confs=confs,master=NULL,alpha=alpha,C=C,var.thr=var.thr,zeta=zeta)$MCN
        tmp <- tmp[lower.tri(tmp)]
        out <- aggr(tmp)
        out
    }

#' c-faithfulness 
#' calculates the c-faithfulness based on the index by Chen and Buja 2013 (M_adj) with equal input neigbourhoods 
#'
#' @param confs a numeric matrix or a dist object
#' @param obsdiss a symmetric numeric matrix or a dist object. Must be supplied.
#' @param k the number of nearest neighbours to be looked at
#' @param ... additional arguments passed to dist()  
#'
#' @return a numeric value; faithfulness 
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' dis<-smacofSym(delts)$confdist
#' c_faithfulness(dis,obsdiss=delts,k=3)
#' @export
c_faithfulness<- function(confs,obsdiss,k=3,...)
{
    if(inherits(obsdiss,"dist")) obsdiss <- as.matrix(obsdiss)
    tdiss <- apply(obsdiss,2,sort)[k+1,] 
    nnmat <- ifelse(obsdiss>tdiss, 0, 1)
    n <- nrow(nnmat)
    kv <- apply(nnmat,1,sum)
    kvmat <- matrix(rep(kv,n),ncol=n,byrow=TRUE)
    confdist <- as.matrix(dist(confs,...))
    confrk <- apply(confdist, 2, rank)
    nnconf <- ifelse(confrk>kvmat, 0,1)
    nk <- (apply(nnconf*nnmat, 2, sum)-1)/(kv-1)
    mkadj <- mean(nk)-(sum(nnmat)-n)/n/n
    res <- list(mda=mkadj,nk=nk)
    return(res$mda) #changed to only return the scalar
  }

#'calculate k nearest neighbours from a distance matrix
#' @param dis distance matrix
#' @param k number of nearest neighbours (Note that with a tie, the function returns the alphanumerically first one!)
knn_dist <- function(dis,k)
    {
      dis <- as.matrix(dis)  
      #if(!isSymmetric(dis)) stop("Distance matrix is not symmetric.")  
      n <- nrow(dis)
      knnindex <- matrix(0, nrow = n, ncol = k+1)
      knndist  <- knnindex
      for(i in 1:n){
          knnindex[i,] = order(dis[i,])[1:(k+1)]
          knndist[i,] = dis[i,knnindex[i,]]
      }
      list(index=knnindex[,-1],distance=knndist[,-1])
   }



#' c-clusteredness 
#' calculates c-clusteredness as the OPTICS cordillera. The higher the more clustered. 
#' 
#' @param confs a numeric matrix or a dist object
#' @param voidarg a placeholder to allow to pass NULL as strucpar  and not interfere with the other arguments
#' @param q The norm used for the Cordillera. Defaults to 2. 
#' @param minpts The minimum number of points that must make up a cluster in OPTICS (corresponds to k in the paper). It is passed to \code{\link[dbscan]{optics}} where it is called minPts. Defaults to 2.
#' @param epsilon The epsilon parameter for OPTICS (called epsilon_max in the paper). Defaults to 2 times the maximum distance between any two points.
#' @param distmeth The distance to be computed if X is not a symmetric matrix or a dist object (otherwise ignored). Defaults to Euclidean distance. 
#' @param dmax The winsorization value for the highest allowed reachability. If used for comparisons between different configurations this should be supplied. If no value is supplied, it is NULL (default); then dmax is taken from the data as the either epsilon or the largest reachability, whatever is smaller.
#' @param digits The precision to round the raw Cordillera and the norm factor. Defaults to 10.
#' @param scale Should X be scaled if it is an asymmetric matrix or data frame? Can take values TRUE or FALSE or a numeric value. If TRUE or 1, standardisation is to mean=0 and sd=1. If 2, no centering is applied and scaling of each column is done with the root mean square of each column. If 3, no centering is applied and scaling of all columns is done as X/max(standard deviation(allcolumns)). If 4, no centering is applied and scaling of all columns is done as X/max(rmsq(allcolumns)). If FALSE, 0 or any other numeric value, no standardisation is applied. Defaults to 0. 
#' @param ... Additional arguments to be passed to \code{cordillera::cordillera}
#' 
#' @return a numeric value; clusteredness (see \code{\link[cordillera]{cordillera}})
#' 
#' @importFrom cordillera cordillera
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' dis<-smacofSym(delts)$confdist
#' c_clusteredness(dis,minpts=3)
#' @export
c_clusteredness<- function(confs,voidarg=NULL,minpts=2,q=2,epsilon=2*max(dist(confs)),distmeth="euclidean",dmax=NULL,digits=10,scale=0,...)
{
    out <- cordillera::cordillera(confs,minpts=minpts,q=q,epsilon=epsilon,distmeth=distmeth,dmax=dmax,digits=digits,scale=scale,...)$normed
    return(out)
  }


#' c-regularity 
#' calculates c-regularity as 1 - OPTICS cordillera for k=2. The higher the more regular. 
#' 
#' @param confs a numeric matrix or a dist object
#' @param voidarg a placeholder to allow to pass NULL as strucpar  and not interfere with the other arguments
#' @param q The norm used for the Cordillera. Defaults to 1 (and should always be 1 imo). 
#' @param epsilon The epsilon parameter for OPTICS (called epsilon_max in the paper). Defaults to 2 times the maximum distance between any two points.
#' @param distmeth The distance to be computed if X is not a symmetric matrix or a dist object (otherwise ignored). Defaults to Euclidean distance. 
#' @param dmax The winsorization value for the highest allowed reachability. If used for comparisons this should be supplied. If no value is supplied, it is NULL (default), then dmax is taken from the data as minimum of epsilon or the largest reachability.
#' @param digits The precision to round the raw Cordillera and the norm factor. Defaults to 10.
#' @param scale Should X be scaled if it is an asymmetric matrix or data frame? Can take values TRUE or FALSE or a numeric value. If TRUE or 1, standardisation is to mean=0 and sd=1. If 2, no centering is applied and scaling of each column is done with the root mean square of each column. If 3, no centering is applied and scaling of all columns is done as X/max(standard deviation(allcolumns)). If 4, no centering is applied and scaling of all columns is done as X/max(rmsq(allcolumns)). If FALSE, 0 or any other numeric value, no standardisation is applied. Defaults to 0. 
#' @param ... Additional arguments to be passed to \code{\link[cordillera:cordillera]{cordillera}}
#'
#' @return a numeric value; regularity
#' 
#' @examples
#' hpts<-expand.grid(seq(-5,5),seq(-5,5))
#' c_regularity(hpts)
#' hpts2<-cbind(jitter(hpts[,1]),jitter(hpts[,2]))
#' c_regularity(hpts2)
#' @export
c_regularity<- function(confs,voidarg=NULL,q=1,epsilon=2*max(dist(confs)),distmeth="euclidean",dmax=NULL,digits=10,scale=0,...)
{
    out <- 1-cordillera::cordillera(confs,minpts=2,q=q,epsilon=epsilon,distmeth=distmeth,dmax=dmax,digits=digits,scale=scale,...)$normed
    return(out)
}

#' c-hierarchy
#' captures how well a partition/ultrametric (obtained by hclust) explains the configuration distances. Uses variance explained for euclidean distances and deviance explained for everything else. 
#'
#' @param confs a numeric matrix
#' @param voidarg a placeholder to allow to pass NULL as strucpar  and not interfere with the other arguments
#' @param p the parameter of the Minokwski distances (p=2 euclidean and p=1 is manhattan)
#' @param agglmethod the method used for creating the clustering, see \code{\link[stats]{hclust}}.
#'
#' @importFrom clue cl_validity
#' @importFrom stats hclust
#'
#' @return a numeric value; hierarchy (see \code{\link[clue]{cl_validity}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacofSym(delts)$conf
#' c_hierarchy(conf,p=2,agglmethod="single")
#' @export
#'
c_hierarchy <- function(confs,voidarg=NULL,p=2,agglmethod="complete")
{
     #maybe not using this?
        d <- dist(confs,method="minkowski",p=p)
        hie <- stats::hclust(d,method=agglmethod)
        af <- clue::cl_validity(hie,d)
        if(p==2) return(af[[1]])
        if(p!=2) return(af[[2]])
     }
        
#' c-outlying
#' 
#' Measures the c-outlying structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' @importFrom scagnostics scagnostics
#'
#'
#' @return a numeric value; outlying (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf3<-smacof::smacofSym(delts,ndim=3)$conf
#' c_outlying(conf3)
#' @export
c_outlying<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Outlying"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Outlying",])
    return(out)
}

#' c-convexity
#' 
#' Measures the c-convexity structure 
#' 
#' @param conf A numeric matrix. 
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' @importFrom scagnostics scagnostics
#'
#' @return a numeric value; convexity (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_convexity(conf)
#' @export
c_convexity<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Convex"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Convex",])
    return(out)
}

#' c-skinniness
#' 
#' Measures the c-skinniness structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#' 
#' @importFrom scagnostics scagnostics
#'
#' @return a numeric value; skinniness (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_skinniness(conf)
#' @export
c_skinniness<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Skinny"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Skinny",])
    return(out)
}

#' c-stringiness
#' 
#' Measures the c-stringiness structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max.
#'
#' @return a numeric value; stringiness (see \code{\link[scagnostics]{scagnostics}})
#'  
#' @importFrom scagnostics scagnostics
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_stringiness(conf)
#' @export
c_stringiness<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Stringy"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Stringy",])
    return(out)
}

#' c-sparsity
#' 
#' Measures the c-sparsity structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max. 
#' @importFrom scagnostics scagnostics
#'
#' @return a numeric value; sparsity (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_sparsity(conf)
#' @export
c_sparsity<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Sparse"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Sparse",])
    return(out)
}

#' c-clumpiness
#' 
#' Measures the c-clumpiness structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max. 
#' @importFrom scagnostics scagnostics
#'
#'
#' @return a numeric value; clumpiness (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_clumpiness(conf)
#' @export
c_clumpiness<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Clumpy"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Clumpy",])
    return(out)
}


#' c-striatedness
#' 
#' Measures the c-striatedness structure 
#' 
#' @param conf A numeric matrix.
#' @param aggr the aggregation function for configurations of more than two dimensions. Defaults to max. 
#' @importFrom scagnostics scagnostics
#'
#' @return a numeric value; striatedness (see \code{\link[scagnostics]{scagnostics}})
#' 
#' @examples
#' delts<-smacof::kinshipdelta
#' conf<-smacof::smacofSym(delts)$conf
#' plot(conf,pch=19,asp=1)
#' c_striatedness(conf)
#' @export
c_striatedness<- function(conf,aggr=NULL){
    if(is.null(aggr)) aggr <- max
    if(dim(conf)[2]<2) stop("The configuration X must have at least two columns.")
    if(dim(conf)[2]==2) out <- as.numeric(scagnostics::scagnostics(conf)["Striated"])
    if(dim(conf)[2]>2) out <- aggr(scagnostics::scagnostics(conf)["Striated",])
    return(out)
}



#' c-shepardness 
#' calculates the c-shepardness as the correlation between a loess smoother of the transformed distances and the transformed dissimilarities 
#'
#' @param object an object of class smacofP
#' @param voidarg empty argument to allow passing NULL as strucpar
#'
#' @return a numeric value
#'
#' @importFrom stats predict
#' @examples
#' delts<-smacof::kinshipdelta
#' res<-smacofx::postmds(delts)
#' c_shepardness(res)
#' @export
c_shepardness<- function(object,voidarg=NULL)
{
   wm <- object$tweightmat
   if(is.null(wm)) wm <- object$weightmat 
   notmiss <- as.vector(as.dist(object$weightmat) > 0)
   delts <- as.vector(object$tdelta)
   confd <- as.vector(object$confdist) #Confdist are already transformed
   wm <- as.vector(wm)
        #delta=observed delta Delta
        #tdelta=transformed delta normalized T(Delta) 
        #distances= dhats, optimally scaled transformed Delta and normalized f(T(Delta))
        notmiss.iord <- notmiss[object$iord]
        delts1 <- delts[notmiss]
        confd1 <- confd[notmiss]
        wm1 <- wm[notmiss]
        dhats1 <- as.vector(object$dhat)[notmiss]
        expo <- 1
        disttrans.ind <- names(object$pars)%in%c("kappa","r") 
        disttrans <- object$pars[disttrans.ind]
        if(object$type=="ratio")
        {
        scallm <- stats::lm(confd1~-1+dhats1,weights=wm)
        scallp <- stats::predict(scallm)
        }
        if(object$type=="interval")
        {
            scallm <- stats::lm(confd1~dhats1,weights=wm)
            scallp <- predict(scallm)
        }
        if(object$type=="ordinal")
        {
        expo <- switch(names(disttrans),
                       r=2*disttrans,
                       kappa=disttrans
                       )                   
        scallm <- stats::lm(confd1~I(dhats1^expo),weights=wm)
        scallp <- predict(scallp)
        }
     ptl <- predict(stats::loess(confd1~delts1,weights=wm),family="symmetric")
     res <- cor(ptl,scallp)
     return(res)
  }

