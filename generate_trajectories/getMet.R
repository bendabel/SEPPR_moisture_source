getMet <- function (year = 2013, month = 1, path_met = "C:/hysplit4/working/") {
  for (i in seq_along(year)) {
    for (j in seq_along(month)) {
      download.file(url = paste0("ftp://arlftp.arlhq.noaa.gov/narr/", "NARR",
                                 year[i], sprintf("%02d", month[j])),
                    destfile = paste0(path_met, "NARR", year[i],
                                      sprintf("%02d", month[j])), mode = "wb")
    }
  }
}
