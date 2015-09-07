# load libraries
require(dplyr)

# character constants
zip_file <- "household_power_consumption.zip"
txt_file <- "household_power_consumption.txt"
dfSubsetFile <- "dfSubset.RData"

# if subsetted data frame file exists, read it in, otherwise create it
if (file.exists(dfSubsetFile)) {
    dfSubset <- dget(dfSubsetFile)
} else {
    # download file
    download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",
                  "household_power_consumption.zip", method = "curl")

    #unzip file
    unzip("household_power_consumption.zip")
    
    # read in data
    dfSubset <- read.table(txt_file, header=TRUE, sep=";",
                 colClasses=c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"),
                 na.strings="?")
    
    # reformat dates and times
    #dfSubset$Date <- strptime(df$Date, format = "%d/%m/%Y")
    
    # clean up df and subset it
    # filter gets rid of all the dates but 2007-02-01 and 2007-02-02 (note Date is given as day/month/year )
    # mutate turns Date and Time together into a string parseable by srptime 
    # select gets rid of Date/Time columns
    dfSubset <- dfSubset %>% 
                    filter(Date == "1/2/2007" | Date == "2/2/2007") %>%
                    mutate(DateAndTime = paste(Date, Time, sep=" ")) %>%
                    select(-(Date:Time))

    # now, turn DateAndTime into POSIXlt (dplyr mutate can't handle POSIXlt)                      
    dfSubset$DateAndTime <- strptime(dfSubset$DateAndTime, format="%d/%m/%Y %H:%M:%S")
    
    # write out subsetted data fram
    dput(dfSubset, file=dfSubsetFile)
}

# make the plot
# open png device
png("plot4.png")

# 2 x 2 matrix of plots
par(mfcol=c(2,2))

# do plot 1
with(dfSubset, plot(DateAndTime, Global_active_power, xlab="", ylab="Global Active power", type="l"))

# do plot 2
with(dfSubset, plot(DateAndTime, Sub_metering_1, type="l", xlab="", ylab="Energy sub metering"))
with(dfSubset, lines(DateAndTime, Sub_metering_2, col="red"))
with(dfSubset, lines(DateAndTime, Sub_metering_3, col="blue"))
legend("topright", legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col=c("black", "red", "blue"), lty=1, bty="n")

# do plot 3
with(dfSubset, plot(DateAndTime, Voltage, type="l", xlab="datetime"))

# do plot 4
with(dfSubset, plot(DateAndTime, Global_reactive_power, type="l", xlab="datetime"))

#close png device
dev.off()
