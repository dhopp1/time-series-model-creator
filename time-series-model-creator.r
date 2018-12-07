#Select time series data file, expects a file with 2 columns, 1 for the period label, 1 for the values
myFile <- file.choose()
data  <- read.csv(myFile)

#rename columns
names(data) <- c("period", "value")

#convert to timeseries datatype
#year of first observation
year <- 2015
#period of first observation
period <- 11
#frequency of observations, 52 for weekly, 12 for yearly, etc.
frequency <- 52 
series <- ts(data$value, start = c(year, period), frequency = frequency)