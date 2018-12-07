#Select time series data file, expects a file with 2 columns, 1 for the period label, 1 for the values
myFile <- file.choose()
data  <- read.csv(myFile)

#rename columns
names(data) <- c("period", "value")

#