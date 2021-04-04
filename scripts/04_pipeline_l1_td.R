# Load libraries
library(data.table)
library(lubridate)
library(zoo)
library(mltools)
library(forecast)
library(rlang)
library(smooth)

# Load functions
source("scripts/evaluation_metrics.R")
source("scripts/train_test_split.R")

# Load data
load(file="input/sales/l1_sales.RData")
load(file='processed/xreg.Rdata')
load(file="processed/last28_props_units.RData")
load(file="processed/prices_mod.RData")
load(file="processed/snaive.RData")

# Parameters
features <- c("d", "date", "snap", "holiday",
              grep("trend", colnames(xreg), value=TRUE))

# One-hot encoding
xreg_bin <- one_hot(xreg[,..features])
xreg_bin[,monthly_seas_12:=NULL]

# Select y col - units/sales
sales[,sales:=units]
sales[,units:=NULL]
sales[,sell_price:=NULL]

# Join xreg
input_dt <- merge(sales, xreg_bin, by = "d")

# Plot ts
sales_ts <- zoo(input_dt$sales, input_dt$date)
plot(sales_ts)

# Auto-correlation plots
acf(sales_ts)
pacf(sales_ts)

# Train-test column
input_dt <- nsplit(input_dt, "date", c("2016-03-28"))
input_dt <- input_dt[,-c("d", "date")]

# Split into train and test
train <- input_dt[split==1, -c("split")]
ytrain <- input_dt[split==1, sales]
ytest <- input_dt[split==2, sales]
xtrain <- input_dt[split==1, -c("split","sales")]
xtest <- input_dt[split==2, -c("split","sales")]
y <- input_dt[,sales]

# # Fit linear model
# model <- lm(sales ~ .,data=train)
# summary(model)
# yhat <- predict(model, xtest)

# Fit arima
model <- auto.arima(ts(ytrain, frequency=7), xreg=as.matrix(xtrain))
summary(model)
yhat <- as.vector(forecast(model, xreg=as.matrix(xtest))$mean)

# # Fit ES model
# model <- es(ts(ytrain, frequency = 7), xreg = input_dt[,-c("split","sales")], h=28)
# summary(model)
# yhat <- as.vector(model$forecast)

# Evaluate metric
rmsse(ytrain, ytest, yhat)
# plot(zoo(model$residuals, input_dt[split==1,]$date))

# # Forecast lm
# linear_model <- lm(sales ~ ., data=input_dt[,..cols])
# summary(linear_model)
# xtest <- xreg[date>="2016-04-25", ..features]
# fcst <- predict(linear_model, xtest)

# # Forecast arima
fcst <- as.vector(forecast(auto.arima(ts(input_dt[,sales], frequency=7), 
                                      xreg=as.matrix(input_dt[,-c("sales","split")])), 
                           xreg=as.matrix(tail(xreg_bin[,-c("d", "date")], 56)))$mean)

# Forecast ES
# fcst <- as.vector(es(ts(y, frequency = 7), xreg = xreg_bin[,-c("d","date")], h=56)$forecast)

# # Top down using proportions
ids <- names(props)
output <- lapply(ids, function(x) fcst*props[x])
# # output <- lapply(ids, function(x) round((fcst*props[x])/prices_mod[id==gsub("_validation", "", x),2:ncol(prices_mod)]))

# # Top down using snaive predictions on day level
# top_level <- colSums(snaive[,2:ncol(snaive)])
# props <- fcst/top_level
# submission <- rlang::duplicate(snaive)
# for (i in seq(1,length(props))){
#   col <- c(colnames(submission)[i+1])
#   submission[[col]] <- round(submission[[col]]*props[i],2)
# }
# top_level_mod <- colSums(submission[,2:ncol(submission)])
# ids <- as.vector(submission[,id])
# submission[,1]<-NULL


# # Top down using snaive on total level
# next28 <- rowSums(snaive[,2:29])
# next28_contrib <- next28*(sum(head(fcst, 28)))/sum(next28)


# Create submission file
submission <- as.data.frame(matrix(data=unlist(output), ncol=56, byrow=TRUE))
validation <- data.frame(id = ids, submission[,1:28])
evaluation <- data.frame(id = gsub("validation", "evaluation", ids), submission[,29:56])
colnames(validation) <- colnames(evaluation) <- c("id", paste("F", seq(1,28), sep=""))
submission_file <- rbind(validation, evaluation)
write.csv(submission_file, "output/submission04_arimax_td.csv", row.names = F)
