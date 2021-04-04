levels_agg <- function(dt, output_dir, levels = seq(1,11)){
  
  # Fixed Parameters
  l11 <- c("d", "item_id", "state_id", "dept_id", "cat_id")
  l10 <- c("d", "item_id", "dept_id", "cat_id")
  l9 <- c("d", "store_id", "state_id", "dept_id", "cat_id")
  l8 <- c("d", "store_id", "state_id", "cat_id")
  l7 <- c("d", "state_id", "dept_id", "cat_id")
  l6 <- c("d", "state_id", "cat_id")
  l5 <- c("d", "dept_id", "cat_id")
  l4 <- c("d", "cat_id")
  l3 <- c("d", "store_id", "state_id")
  l2 <- c("d", "state_id")
  l1 <- c("d")
  
  # Aggregation  
  for (l in levels){
    ids <- get(str_c("l",l))
    sales <- dt[, .(sales = sum(sales), units = sum(units), sell_price = mean(sell_price)), by=ids]
    save(sales, file=str_c(output_dir, str_c("l", l, "_sales.RData")))
  }
}