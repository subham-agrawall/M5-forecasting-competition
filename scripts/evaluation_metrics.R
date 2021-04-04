# Evaluating RMSSE - Root mean square scaled error
rmsse <- function(ytrain, ytest, yhat){
  
  # Check1 - input type
  if(!is.vector(ytrain) | !is.vector(ytest) | !is.vector(yhat)){
    stop("Invalid input: One of the inputs is not a vector")
  }
  
  # Check2 - input lengths
  if(length(ytest)!=length(yhat)){
    stop("Invalid input: ytest and yhat are of different lengths")
  }
  
  # Evaluate error
  n=length(ytrain)
  numerator = mean((ytest - yhat)^2)
  denominator = mean((ytrain[2:n]-ytrain[1:(n-1)])^2)
  error = (numerator/denominator)^0.5
  
  return(error)
}