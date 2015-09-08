# load libraries
require(dplyr)

# character constants
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
zip_file <- "household_power_consumption.zip"
txt_file <- "household_power_consumption.txt" 
dfSubsetFile <- "dfSubset.RData"

# if subsetted data frame file exists, read it in, otherwise create it
if (file.exists(dfSubsetFile)) {
    dfSubset <- dget(dfSubsetFile)
} else {
    # download file
    download.file(url, zip_file, method = "curl")

    #unzip file
    unzip(zip_file)
    
    # read in data
    df <- read.table(txt_file, header=TRUE, sep=";",
                 colClasses=c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"),
                 na.strings="?")
    
    # clean up df and subset it
    # filter gets rid of all the dates but 2007-02-01 and 2007-02-02 (note Date is given as day/month/year )
    # mutate turns Date and Time together into a POSIXct object
    # select gets rid of Date/Time columns
    dfSubset <- df %>% 
                    filter(Date == "1/2/2007" | Date == "2/2/2007") %>%
                    mutate(datetime = as.POSIXct(paste(Date, Time, sep=" "), format="%d/%m/%Y %H:%M:%S")) %>%
                    select(-(Date:Time))

    # write out subsetted data frame
    dput(dfSubset, file=dfSubsetFile)
}

# make the plot
# open png device
png("plot1.png", bg="transparent")

# do plot
with(dfSubset, hist(Global_active_power, col="red", main="Global Active Power", xlab="Global Active Power (kilowatts)"))

#close png device
dev.off()
