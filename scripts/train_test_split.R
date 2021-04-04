# Add column with split number from input dates vector
# NOTE: all dates should in ymd format
nsplit <- function(dt, ref_col, dates){
  
  # Check 1 - column format
  vec <- dt[,ref_col, with=F][[1]]
  if (!"Date" %in% class(vec)){
    vec <- lubridate::ymd(vec)
    dt[,ref_col] <- vec
  }
  
  # Sort on date
  setorderv(dt, c(ref_col), c(1))
  vec <- dt[,ref_col, with=F][[1]]
  
  # Check 2 - missing point
  all_dates <- seq(head(vec, 1), tail(vec, 1), by="days")
  if (any(all_dates!=vec)){
    stop("Value error: Missing data point")
  }
  
  # Get indices
  # Check 3 - input date missing
  indices <- which(vec %in% lubridate::ymd(dates))
  if (length(indices)<length(dates)){
    stop("Invalid input: date(s) not present")
    print(length(dates) - length(indices))
  }
  
  # Create new column
  new_col <- c()
  start <- 1
  for(i in 1:length(indices)){
    end <- indices[i]
    new_col <- c(new_col, rep(i, (end-start)))
    start <- end
  }
  
  # Concatenate
  dt$split <- c(new_col, rep(i+1, (nrow(dt)-length(new_col))))
  return(dt)
}