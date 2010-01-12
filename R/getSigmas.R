# $LastChangedDate: $
# $LastChangedBy: $
# $Rev: $
# 
# Author: fgochez
###############################################################################


#' Extracts sigma estimates from a NONMEM object
#' @param obj An object of class NMBasicModel, NMRun or NMSimModel
#' @param stdErrors A boolean value that specifies whether standard errors should be returned
#' @param initial A boolean value that specifies whether initial values of sigma should be returned
#' @param ... Additional arguments that apply to different classes. These are problemNum which specifies the run required for NMRun
#'    		  and subProblemNum which specifies the simulation required for NMSimModel
#' @return A 3 dimensional array with a matrix of estimates, and if specified, a matrix of initial values and standard errors
#' @author Mango Solutions <rweeks@mango-solutions.com>

getSigmas <- function(obj, what = "final", ...)
{
	RNMImportStop(msg = "This method is not implemented for this class!")
}
setGeneric("getSigmas")

getSigmas.NMBasicModel <- function(obj, what = "final")
{
	validWhat <- intersect(what, PARAMITEMS)
	invalidWhat <- setdiff(what, PARAMITEMS)
	
	if(length(invalidWhat)) RNMImportWarning("Invalid items chosen:" %pst% paste(invalidWhat, collapse = ","))
	
	sigmas <- obj@sigmaFinal
	oneByOne <- all(dim(sigmas)[1:2] == c(1,1) )
	finalEstimates <- sigmas[,,"estimates", drop = TRUE]
	if(oneByOne) finalEstimates <- matrix(finalEstimates, dimnames = dimnames(sigmas)[1:2])
	if("standardErrors" %in% dimnames(sigmas)[[3]]) 
	{
		stdErrors <- sigmas[,,"standardErrors", drop = TRUE]
		if(oneByOne) stdErrors <- matrix(stdErrors, dimnames = dimnames(sigmas)[1:2])
	}
	
	initialValues <- obj@sigmaInitial
	if(oneByOne) initialValues <- matrix(initialValues, dimnames = dimnames(sigmas)[1:2])
	
	# no valid option selected, thrown an error
	if(length(validWhat) == 0) RNMImportStop("No valid items selected for retrieval!", call = match.call())
	if(length(validWhat) == 1)
	{
		res <- switch(validWhat, 
				"final" = finalEstimates,
				# TODO: if these are length 0, generate an error?
				"initial" = initialValues,
				"stderrors" = {
					if(is.null(stdErrors))
						RNMImportStop("Standard errors not available \n", call = match.call())
					stdErrors
				}
		)
		# this occurs if the sigmas were a 1x1 matrix to begin with.  We wish to force the returned value to be a matrix
		if(is.null(dim(res))) 
		{ 
			dim(res) <- c(1,1)
			dimnames(res) <- dimnames(sigmas)[1:2]	
		}	
	} # end if length(validWhat) == 1
	else
	{
		res <- list()
		# TODO: check for missing initial values?
		if("initial" %in% validWhat) res$initial.estimates <- initialValues
		if("final" %in% validWhat) res$final.estimates <- finalEstimates
		if("stderrors" %in% validWhat) 
		{
			if(is.null(stdErrors)) RNMImportWarning("Standard errors not available \n")
			else res$standard.errors <- stdErrors
		}
	}
	res
}

setMethod("getSigmas", signature(obj = "NMBasicModel"), getSigmas.NMBasicModel)

getSigmas.NMBasicModelNM7 <- function(obj, what = "final")
{
	methodChosen <- .selectMethod(obj@methodNames, method)
	sigmas <- obj@sigmaFinal[[methodChosen]]
	
	validWhat <- intersect(what, PARAMITEMS)
	invalidWhat <- setdiff(what, PARAMITEMS)
	
	if(length(invalidWhat)) RNMImportWarning("Invalid items chosen:" %pst% paste(invalidWhat, collapse = ","))
	
	oneByOne <- all(dim(sigmas)[1:2] == c(1,1) )
	finalEstimates <- sigmas[,,"estimates", drop = TRUE]
	if(oneByOne) finalEstimates <- matrix(finalEstimates, dimnames = dimnames(sigmas)[1:2])
	if("standardErrors" %in% dimnames(sigmas)[[3]]) 
	{
		stdErrors <- sigmas[,,"standardErrors", drop = TRUE]
		if(oneByOne) stdErrors <- matrix(stdErrors, dimnames = dimnames(sigmas)[1:2])
	}
	
	initialValues <- obj@sigmaInitial
	if(oneByOne) initialValues <- matrix(initialValues, dimnames = dimnames(sigmas)[1:2])
	
	# no valid option selected, thrown an error
	if(length(validWhat) == 0) RNMImportStop("No valid items selected for retrieval!", call = match.call())
	if(length(validWhat) == 1)
	{
		res <- switch(validWhat, 
				"final" = finalEstimates,
				# TODO: if these are length 0, generate an error?
				"initial" = initialValues,
				"stderrors" = {
					if(is.null(stdErrors))
						RNMImportStop("Standard errors not available \n", call = match.call())
					stdErrors
				}
		)
		# this occurs if the sigmas were a 1x1 matrix to begin with.  We wish to force the returned value to be a matrix
		if(is.null(dim(res))) 
		{ 
			dim(res) <- c(1,1)
			dimnames(res) <- dimnames(sigmas)[1:2]	
		}	
	} # end if length(validWhat) == 1
	else
	{
		res <- list()
		# TODO: check for missing initial values?
		if("initial" %in% validWhat) res$initial.estimates <- initialValues
		if("final" %in% validWhat) res$final.estimates <- finalEstimates
		if("stderrors" %in% validWhat) 
		{
			if(is.null(stdErrors)) RNMImportWarning("Standard errors not available \n")
			else res$standard.errors <- stdErrors
		}
	}
	res
}

setMethod("getSigmas", signature(obj = "NMBasicModelNM7"), getSigmas.NMBasicModelNM7)

getSigmas.NMRun <- function(obj, what = "final", problemNum = 1)
{
	dat <- getProblem(obj, problemNum)
	sigmas <- getSigmas(dat, what = what)
	sigmas
}
setMethod("getSigmas", signature(obj = "NMRun"), getSigmas.NMRun)

getSigmas.NMSimModel <- function(obj, what = "final", subProblemNum = 1)
{
#	if(stdErrors)
#		RNMImportWarning(msg = "No standard errors are available!")
	numSimulations <- obj@numSimulations
	if(any(!(subProblemNum %in% 1:numSimulations)))
		RNMImportStop(msg = "Subproblem number is not valid!")	
	sigmas <- obj@sigmaFinal[, , subProblemNum, drop = FALSE]
#	if(initial)
#		attr(sigmas, "Initial") <- obj@sigmaInitial
	sigmas
}

setMethod("getSigmas", signature(obj = "NMSimModel"), getSigmas.NMSimModel)