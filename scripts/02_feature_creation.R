# Load libraries
library(data.table)
library(lubridate)

# Load calendar data
calendar <- fread('input/calendar.csv', sep=',')

# Sort on date
if(!"Date" %in% class(calendar[,date])) calendar[,date:= lubridate::ymd(calendar[,date])]
calendar <- calendar[order(date)]

# Trend features
xreg <- data.table(d=calendar[,d], date=calendar[,date])
xreg[,daily_trend:= seq(1, nrow(calendar), 1)]
xreg[,weekly_trend:= as.integer(substr(calendar$wm_yr_wk, 4, 5)) + 52*(calendar$year-2011)]
xreg[,monthly_trend:= calendar$month + 12*(calendar$year-2011)]
xreg[,quarterly_trend:= quarter(ymd(calendar$date)) + 4*(calendar$year-2011)]
xreg[,yearly_trend:= calendar$year-2010]

# Intra-trend features
xreg[,intraweek_trend:= calendar$wday]
xreg[,intramonth_trend:= day(ymd(calendar$date))]
xreg[,intraquarter_trend:= qday(ymd(calendar$date))]
xreg[,intrayear_trend:= yday(ymd(calendar$date))]

# Seasonality features
xreg[,weekly_seas:=as.factor(calendar$weekday)]
xreg[,monthly_seas:=as.factor(calendar$month)]
xreg[,quarterly_seas:=as.factor(quarter(ymd(calendar$date)))]
xreg[,yearly_seas:=as.factor(calendar$year)]

# Snap feature
xreg[,snap:=calendar$snap_CA + calendar$snap_WI + calendar$snap_TX]

# Holiday features
# Ignoring event 2 for now. 
xreg[,event_type:=as.factor(calendar$event_type_1)]
xreg[,event_name:=as.factor(calendar$event_name_1)]
xreg[,holiday:=ifelse(calendar$event_name_1!="", 1, 0)]
xreg[,before_holiday1:=shift(holiday, n=1, fill=0, type="lead")]
xreg[,before_holiday2:=shift(holiday, n=2, fill=0, type="lead")]
xreg[,after_holiday1:=shift(holiday, n=1, fill=0, type="lag")]
xreg[,after_holiday2:=shift(holiday, n=2, fill=0, type="lag")]
# xreg[,before_event_type:=shift(event_type, n=1, fill=0, type="lead")]
# xreg[,before_event_name:=shift(event_name, n=1, fill=0, type="lead")]
# xreg[,after_event_name:=shift(event_name, n=1, fill=0, type="lag")]

# Interactions
xreg[, year_week_interaction:=as.factor(paste(as.character(monthly_seas), as.character(weekly_seas), sep = "_"))]

# Save xreg
save(xreg, file='processed/xreg.Rdata')