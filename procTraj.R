
read.files <- function(hours = 96, hy.path) { 
  ## find tdump files 
  files <- Sys.glob("tdump*") 
  output <- file('Rcombined.txt', 'w')
  
  ## read through them all, ignoring 1st 7 lines 
  for (i in files) { 
    input <- readLines(i) 
    input <- input[-c(1:7)] 
    # delete header 
    writeLines(input, output) 
    
  } 
  close(output)
 
  ## read the combined txt file 
  traj <- read.table(paste0(hy.path, "working/Rcombined.txt"), header = FALSE) 
  traj <- subset(traj, select = -c(V2, V7, V8))
    traj <- rename(traj, c(V1 = "receptor", V3 = "year", V4 = "month", V5 = "day", 
                         V6 = "hour", V9 = "hour.inc", V10 = "lat", V11 = "lon", 
                         V12 = "height", V13 = "pressure"))
  
  ## hysplit uses 2-digit years ... 
  year <- traj$year[1] 
  if (year < 50) traj$year <- traj$year + 2000 else traj$year <- traj$year + 1900
  
  traj$date2 <- with(traj, ISOdatetime(year, month, day, hour, min = 0, sec = 0, 
                                       tz = "GMT")) 
  
  ## arrival time 
  traj$date <- traj$date2 - 3600 * traj$hour.inc 
  traj
}

#####################

add.met <- function(month, Year, met, bat.file) {
  ## if month is one, need previous year and month = 12 
  if (month == 0){ 
    month <- 12 
    Year <- as.numeric(Year) - 1 
  }
  
  if (month < 10) month <- paste("0", month, sep = "") 
  ## add first line
    write.table(paste("echo", met, ">>CONTROL"), 
              bat.file, col.names = FALSE, 
              row.names = FALSE, quote = FALSE, append = TRUE)
  
  x <- paste("echo NARR", Year, month, ">>CONTROL", sep = "") 
  write.table(x, bat.file, col.names = FALSE, 
              row.names = FALSE, quote = FALSE, append = TRUE)
}

#####################

procTraj <- function(lat = 51.5, lon = -0.1, year = 2010, month = 9, day = 25,
                     name = "london", 
                     met = "c:/hysplit4/working/meteo/", 
                     out = "c:/Users/seho5515/Documents/Research/HYSPLIT/data/default/", 
                     hours = 96, height = 10, hy.path = "c:/hysplit4/") { 
  
  ## get starting working directory
  path.wd <- getwd()
  
  ## hours is the back trajectory time e.g. 96 = 4-day back trajectory 
  ## height is start height (m) 
  lapply(c("openair", "plyr", "reshape2"), require, character.only = TRUE)
  
  setwd(paste0(hy.path, "working/"))
  
  ## remove existing "tdump" files 
  path.files <- paste0(hy.path, "working/") 
  bat.file <- paste0(hy.path, "working/test.bat") ## name of BAT file to add to/run 
  files <- list.files(path = path.files, pattern = "tdump") 
  lapply(files, function(x) file.remove(x))
  
  start <- paste(year, "-", month, "-", day, " 00:00", sep = "")
  end <- paste(year, "-", month, "-", day, " 21:00", sep = "") 
  dates <- seq(as.POSIXct(start, "GMT"), as.POSIXct(end, "GMT"), by = "6 hour")
  
  for (i in 1:length(dates)) {
   
     year <- format(dates[i], "%y") 
     Year <- format(dates[i], "%Y") # long format 
     month <- format(dates[i], "%m") 
     day <- format(dates[i], "%d") 
     hour <- format(dates[i], "%H")
     
    x <- paste("echo", year, month, day, hour, "      >CONTROL") 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE)
    
    x <- "echo 1 >>CONTROL" 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    x <- paste("echo", lat, lon, height, "      >>CONTROL") 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    x <- paste("echo ", "-", hours, "             >>CONTROL", sep = "") 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    x <- "echo 0                 >>CONTROL 
          echo 10000.0           >>CONTROL 
          echo 2                 >>CONTROL"
    
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    #Since these are back trajectories -> always add met file from previous month
    months <- as.numeric(unique(format(dates[i], "%m"))) 
    months <- c(months, months-1)
    
    for (i in 1:2) {
      add.met(months[i], Year, met, bat.file)
    }
    
    x <- "echo ./          >>CONTROL" 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    x <- paste("echo tdump", year, month, day, hour, "         >>CONTROL", sep = "") 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    x <- "c:\\hysplit4\\exec\\hyts_std" 
    write.table(x, bat.file, col.names = FALSE, 
                row.names = FALSE, quote = FALSE, append = TRUE)
    
    ## run the file 
    system(paste0(hy.path, 'working/test.bat'))
  }
 
   ## combine files and make data frame
  
  traj <- read.files(hours, hy.path)
  
  ## write R object to file 
  file.name <- paste(out, name, Year, ".RData", sep = "") 
  save(traj, file = file.name)
  
  #reset to starting directory:
  setwd(path.wd)
  
  return(traj)
}