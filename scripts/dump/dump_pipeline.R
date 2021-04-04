# Get series weight
# merge_cols <- c("store_id", "item_id", "wm_yr_wk")
# select_cols <- c(merge_cols, "units", "split")
# weight_dt <- input[split==3, ..select_cols]
# weight_dt <- merge(weight_dt, prices, by=merge_cols)
# weight_dt[, sales := units*sell_price]
# weight <- sum(weight_dt$sales)


# Call pipeline for each series
# Parallel
# ncores <- detectCores()
# clust <- makeCluster(2)
# clusterEvalQ(clust, library(forecast))
# clusterEvalQ(clust, library(data.table))
# clusterEvalQ(clust, library(lubridate))
# clusterExport(clust, c("train", "calendar", "prices", "nsplit", "naive_model", "snaive_model"), envir = environment())
# output <- parLapply(clust, ids, pipeline)
# stopCluster(clust)


# # Output dt
# merge_cols <- c("store_id", "item_id", "wm_yr_wk")
# select_cols <- c("d", "id", merge_cols, "units", "split")
# weight_dt <- input[split==3, ..select_cols]
# weight_dt <- merge(weight_dt, prices, by=merge_cols)
# weight_dt[, actual_sales := units*sell_price]
# weight_dt[, pred_units := fcst$mean]
# weight_dt[, pred_sales := pred_units*sell_price] 
