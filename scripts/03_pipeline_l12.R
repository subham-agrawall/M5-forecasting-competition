## Load libraries
library(data.table)
library(stringr)
library(lubridate)
library(forecast)
library(parallel)
library(mltools)
library(MASS)

## Load functions
source("scripts/evaluation_metrics.R")
source("scripts/train_test_split.R")
source("scripts/tsmodels.R")

## Load data
load(file="input/sales/l12_sales.RData")
load(file='processed/xreg.RData')

# Subset
keep_cols <- c("id", "d", "units")
sales <- sales[,..keep_cols]

# Parameters
features <- c("d", "date", "snap") 
              # "year_week_interaction",
              # grep("trend", colnames(xreg), value=TRUE),
              # grep("seas", colnames(xreg), value=TRUE)[1:3],
              # grep("holiday", colnames(xreg), value=TRUE),
              # grep("event", colnames(xreg), value=TRUE))

# One-hot encoding
xreg_bin <- one_hot(xreg[,..features])
# xreg_bin[,monthly_seas_12:=NULL]
# xreg_bin[,weekly_seas_Sunday:=NULL]
# xreg_bin[,quarterly_seas_4:=NULL]
# xreg_bin[,event_type_:=NULL]
# xreg_bin[,event_name_:=NULL]
# xreg_bin[,year_week_interaction_12_Sunday:=NULL]


# Pipeline
pipeline <- function(series_id, model, verbose=FALSE){
  print(series_id)
  
  # Filter
  input <- sales[id==series_id,]
  
  # Merge calendar
  input <- merge(input, xreg_bin, by = "d")
  
  # Train-test-validation column
  input <- nsplit(input, "date", c("2016-02-29","2016-03-28"))
  
  # Trim series
  start <- min(which(input$units>0))
  input <- input[start:nrow(input),]
  
  # Validate model
  input <- input[,-c("d", "id", "date")]
  train <- input[split!=3, -c("split")]
  ytrain <- input[split!=3, units]
  ytest <- input[split==3, units]
  xtrain <- input[split!=3, -c("units", "split")]
  xtest <- input[split==3, -c("units", "split")]
  input <- input[,-c("split")]
  y <- input[,units]
  X <- input[,-c("units")]
  Xh <- tail(xreg_bin[,-c("d", "date")], 56)
  
  if(model=="arimax"){
    yhat <- as.vector(arimax_model(y=ytrain, xtrain, xtest, verbose=verbose)$mean)
    fcst <- as.vector(arimax_model(y=y, X, Xh)$mean)
  }
  
  if(model=="arima"){
    # yhat <- as.vector(arima_model(y=ytrain, h=28, verbose=verbose)$mean)
    output <- arima_model(y=y, h=56)
  }
  
  if(model=="tslmx"){
    yhat <- tslmx_model(train, xtest, verbose=verbose)[,"fit"]
    fcst <- tslmx_model(input, Xh)[,"fit"]
  }
  
  if (model=="snaive"){
    yhat <- as.vector(snaive_model(y=ytrain, h=28)$mean)
    fcst <- as.vector(snaive_model(y=y, h=56)$mean)
  }
  
  # Print validation error
  # error <- rmsse(ytrain, ytest, yhat)
  # print(paste(series_id, "RMSSE error:", error))
 
  return(output)
}

# IDs
ids <- unique(sales$id)
output <- lapply(ids, pipeline, model="arima", verbose=FALSE)

# Create submission file
submission <- as.data.frame(matrix(data=unlist(output), ncol=56, byrow=TRUE))
validation <- data.frame(id = ids, submission[,1:28])
evaluation <- data.frame(id = gsub("validation", "evaluation", ids), submission[,29:56])
colnames(validation) <- colnames(evaluation) <- c("id", paste("F", seq(1,28), sep=""))
submission_file <- rbind(validation, evaluation)
write.csv(submission_file, "output/submission02_snaive.csv", row.names = F)