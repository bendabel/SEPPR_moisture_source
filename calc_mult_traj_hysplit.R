## For running multiple HYSPLIT trajectories:
library(tidyverse)
library(openair)

setwd("H:/CUBoulder_Student_Documents/Dissertation/PPR_Moisture_Tracking/")

#source('D:/PPR_moisture_tracking/procTraj.R')
source('./procTraj.R')

#designated lat and lon points for each region:
chosen_stations <- read_csv("./chosen_stations_loc_name.csv")
cur_stat <- 2
city_coords <- list(c(chosen_stations$lat[cur_stat], chosen_stations$lon[cur_stat]))
region.name <- chosen_stations$name[cur_stat]
#city_coords <- list(c(42.47, -93.80))
#city_coords <- list(c(47.80, -96.60))
#city_coords <- list(c(48.18, -101.30))
#city_coords <- list(c(43.49, -99.06))
#city_coords <- list(c(46.15, -98.09))
#region.name <- c('webster_city')
#region.name <- c('crookston')
#region.name <- c('minot')
#region.name <- c('academy')
#region.name <- c('oakes')
region.coord <- list(city_coords)

#Import file with dates
#dates <- read_csv("D:/PPR_moisture_tracking/moisture_track_days/webster_city_rain_days.csv")
#dates <- read_csv("D:/PPR_moisture_tracking/moisture_track_days/webster_city_extreme_days.csv")
dates <- read_csv("./moisture_track_days/crookston_rain_days.csv")

#Heights at which the trajectory will be calculated
ht <- seq(500, 5000, 500)
ht.nm <- c('500m', '1000m', '1500m', '2000m', '2500m',
           '3000m', '3500m', '4000m', '4500m', '5000m')

#setup directories:
main.path <- 'C:/hysplit4/working'
sub.path <- 'crookston_rain'
#sub.path <- 'web_city_extreme'
dir.create(file.path(main.path, sub.path))
setwd(main.path)

#Track execution time
start <- Sys.time()

#Region loop
for(i in 1:length(region.name)) {
  city <- region.name[[i]]
  coord <- region.coord[[i]]
  
  dir.create(file.path(main.path, sub.path, city))
  setwd(file.path(main.path, sub.path, city))
  
  #Coordinate loop
  for(j in 1:length(region.coord[[i]])) {
    coord.path <- paste0(region.name[[i]], '_', coord[[j]][1], '_', coord[[j]][2])
    #dir.create(file.path(main.path, sub.path, nm, coord.path))
    #setwd(file.path(main.path, sub.path, nm, coord.path))
    
    #Height loop
    for(k in 1:length(ht.nm)) {
      dir.create(file.path(main.path, sub.path, city, ht.nm[k]))
      setwd(file.path(main.path, sub.path, city, ht.nm[k]))
      
      #Date loop
      for(x in 1:nrow(dates)) {
        traj.temp <- procTraj(lat = coord[[j]][1],
                              lon = coord[[j]][2],
                              year = dates[x, 1],
                              month = dates[x, 2],
                              day = dates[x, 3],
                              name = paste(city, ht.nm[k],
                                           dates[x,1], dates[x,2], dates[x,3],
                                           sep = "_"),
                              #met = 'D:/PPR_moisture_tracking/hysplit/NARR/',
                              met = 'H:/CUBoulder_Student_Documents/Dissertation/PPR_Moisture_Tracking/hysplit_reanalysis_data/NARR/',
                              out = './',
                              hours = 192,
                              height = ht[k])
      
        colnames(traj.temp) <- c("receptor", "year", "month", "day",
                                 "hour", "hour.inc", "lat", "lon", 
                                 "height", "pressure", "theta", "air_temp", 
                                 "rainfall","mixdepth", "rh", 
                                 "sp_humidity", "h2o_mixrate", 
                                 "terr_msl", "sun_flux","date2","date")
        
        if(dates[x,3] < 10) {
          write.table(traj.temp, paste0(dates[x,1], '0', dates[x,2], '0', dates[x,3],
                                        '_', ht.nm[k], '.txt'), sep = "\t", row.names = FALSE)
        } else {
          write.table(traj.temp, paste0(dates[x,1], '0', dates[x,2], dates[x,3],
                                        '_', ht.nm[k], '.txt'), sep = "\t", row.names = FALSE)
        }
      }
    }
  }
}

end <- Sys.time()
end-start
