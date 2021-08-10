#Retrieve desired NARR files from Hysplit ftp server
source("getMet.R")

#Choose years, months, and save location and place in vectors below
years <- 1979:1980
months <- 5:9
path <- "C:/hysplit/NARR/"

getMet(years, months, path)