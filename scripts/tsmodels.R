require(forecast)

naive_model <- function(y, h=56, level=c(50, 67, 95, 99)){
  # Generate forecast
  output <- forecast::naive(y=y, h=h, level=level)
  
  return(output)
}

snaive_model <- function(y, freq=7, h=56, level=c(50, 67, 95, 99)){
  # Convert to ts
  yts <- ts(y, frequency = freq)
  
  # Generate forecast
  output <- forecast::snaive(y=yts, h=h, level=level)
  
  return(output)
}

tslmx_model <- function(train, xtest, ycol='units', level=c(50, 67, 95, 99), verbose=FALSE){
  # Build model
  fmla <- as.formula(paste(ycol, "~."))
  model <- lm(formula = fmla, data=train)
  
  # Print model summary
  if (verbose) {print(summary(model))}
  
  # Predict
  output <- predict(model, xtest, interval="prediction", level = level[1])
  
  return(list(model=model, fcst=output))
}

arimax_model <- function(y, xtrain, xtest, freq=7, level=c(50, 67, 95, 99), verbose=FALSE){
  # Convert to ts
  yts <- ts(y, frequency = freq)
  
  # Build model
  model <- auto.arima(yts, xreg=as.matrix(xtrain))
  
  # Print model summary
  if (verbose) {print(summary(model))}
  
  # Forecast
  output <- forecast(model, xreg = as.matrix(xtest), level=level)
  
  return(list(model=model, fcst=output))
}

arima_model <- function(y, freq=7, h=56, level=c(50, 67, 95, 99), verbose=FALSE){
  # Convert to ts
  yts <- ts(y, frequency = freq)
  
  # Build model
  model <- auto.arima(yts)
  
  # Print model summary
  if (verbose) {print(summary(model))}
  
  # Forecast
  output <- forecast(model, h = h, level=level)
  
  return(list(model=model[c('coef', 'aic', 'arma', 'bic')], fcst=output))
}

