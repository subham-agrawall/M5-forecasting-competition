proportions_sales <- function(dt, start_d = 1886){
  dt_mod  <- dt[as.numeric(substr(d, 3, 6)) >= start_d, .(sales=sum(sales)), by="id"]
  proportions <- dt_mod[,sales]/sum(dt_mod[,sales])
  names(proportions) <- dt_mod[,id]
  return(proportions)
}

proportions_units <- function(dt, start_d = 1886){
  dt_mod  <- dt[as.numeric(substr(d, 3, 6)) >= start_d, .(units=sum(units)), by="id"]
  proportions <- dt_mod[,units]/sum(dt_mod[,units])
  names(proportions) <- dt_mod[,id]
  return(proportions)
}

# Create proportions based on last 28 days i.e. 1886-1913
load(file="input/sales/l12_sales.RData")
props <- proportions_units(sales, start_d=1886)
save(props, file="processed/last28_props_units.RData")

# # Create prices dt for validation and evaluation period
prices <- fread('input/sell_prices.csv', sep = ",")
calendar <- fread('input/calendar.csv', sep = ",")
prices <- prices[wm_yr_wk>=11613,]
prices[,id:=paste(item_id, store_id, sep="_")]
prices_mod <- setDT(expand.grid(id=unique(prices[,id]), d=paste("d", as.character(seq(1914,1969)), sep="_")))
tmp <- c("d", "wm_yr_wk")
prices_mod <- merge(prices_mod, calendar[, ..tmp], by = "d")
prices_mod <- merge(prices_mod, prices, by=c("id", "wm_yr_wk"))
prices_mod <- dcast(prices_mod, id ~ d, value.var = 'sell_price')
save(prices_mod, file="processed/prices_mod.RData")

# Seasonal Naive proportions
train <- fread('input/sales_train_validation.csv', sep = ",")
keep_cols <- c("id", rep(tail(colnames(train), 7), 8))
snaive <- train[,..keep_cols]
colnames(snaive) <- c("id", paste("d", as.character(seq(1914,1969)), sep="_"))
save(snaive, file="processed/snaive.RData")
