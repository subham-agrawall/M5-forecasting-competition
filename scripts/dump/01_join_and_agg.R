## Load libraries
library(data.table)
library(stringr)

## Directory path
path <- "input/"
output_path <- "agg_data/" 

## Load data
train <- fread(str_c(path,'sales_train_validation.csv'), sep = ",")
prices <- fread(str_c(path,'sell_prices.csv'), sep = ",")
calendar <- fread(str_c(path,'calendar.csv'), sep=",")

## Data transformations

# Reshape input data
train <- melt(train, 
              id.vars = grep("id", colnames(train), value=TRUE), 
              variable.name = "d", 
              value.name = "units")

# Merge prices
tmp <- c("d", "wm_yr_wk")
train <- merge(train, calendar[, ..tmp], by = "d")
train <- merge(train, prices, by=c("store_id", "item_id", "wm_yr_wk"))
rm(prices)

# Total amount
train[, sales := units*sell_price]

# Aggregate to total sales level
# Change it according to the desired level
total_sales <- train[, .(sum(sales)), by="d"]
state_sales <- train[, .(sum(sales)), by=c("d", "state_id")]
setnames(total_sales, "V1", "sales")
setnames(state_sales, "V1", "sales")
rm(train)

# Create snap data
snap_cols <- grep('snap', colnames(calendar), value=TRUE)
keep_cols <- c("d", snap_cols)

snap <- calendar[, ..keep_cols]
for (col in snap_cols){
  setnames(snap, col, unlist(strsplit(col, split="_"))[2])
}

snap_t <- melt(snap, id.vars = c("d"), variable.name = "state_id", value.name = "snap")

# Merge calendar
tmp <- setdiff(colnames(calendar), snap_cols)

# total
total_sales <- merge(total_sales, calendar[,..tmp], by = "d")
total_sales <- merge(total_sales, snap, by = c("d"))
total_sales <- total_sales[order(date,decreasing=FALSE),]

# store level
state_sales <- merge(state_sales, calendar[,..tmp], by = "d")
state_sales <- merge(state_sales, snap_t, by = c("d", "state_id"))
state_sales <- state_sales[order(state_id, date, decreasing=FALSE),]

# write aggregates
save(total_sales, file=str_c(output_path, "total_sales.RData"))
save(state_sales, file=str_c(output_path, "state_sales.RData"))
