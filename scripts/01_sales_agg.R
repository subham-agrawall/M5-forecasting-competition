## Load libraries
library(data.table)
library(stringr)

## Directory path
path <- "input/"
output_path <- "input/sales/" 

## Load data
sales <- fread(str_c(path,'sales_train_validation.csv'), sep = ",")
prices <- fread(str_c(path,'sell_prices.csv'), sep = ",")
calendar <- fread(str_c(path,'calendar.csv'), sep=",")

## Data transformations

# Reshape input data
sales <- melt(sales, 
              id.vars = grep("id", colnames(sales), value=TRUE), 
              variable.name = "d", 
              value.name = "units")

# Merge prices
tmp <- c("d", "wm_yr_wk")
sales <- merge(sales, calendar[, ..tmp], by = "d")
sales <- merge(sales, prices, by=c("store_id", "item_id", "wm_yr_wk"))
sales[,wm_yr_wk:=NULL]

# Total amount
sales[, sales := units*sell_price]

# save Level 12 sales
save(sales, file=str_c(output_path, "l12_sales.RData"))

# Save Level 1 to 11 sales
source("scripts/bottom_up.R")
levels_agg(sales, output_path)
