#plot source percentages in a stacked bar graph
library(tidyverse)
library(reshape2)

#Import data
events <- c("rain", "extreme")
heights <- c("3000m", "5000m")#c("1500m", "3000m", "5000m")

all_data_tidy <- tibble()

for(i in 1:length(events)) {
  for(j in 1:length(heights)) {
    event <- events[i]; height <- heights[j]
    
    web_data <- read_csv(paste0("./results/webster_city_", height, "_", event, "_source_percentages.csv"))
    crookston_data <- read_csv(paste0("./results/crookston_", height, "_", event, "_source_percentages.csv"))
    minot_data <- read_csv(paste0("./results/minot_", height, "_", event, "_source_percentages.csv"))
    oakes_data <- read_csv(paste0("./results/oakes_", height, "_", event, "_source_percentages.csv"))
    academy_data <- read_csv(paste0("./results/academy_", height, "_", event, "_source_percentages.csv"))
    
    station <- "Webster\nCity"
    web_data <- cbind(web_data, station)
    
    station <- "Crookston"
    crookston_data <- cbind(crookston_data, station)
    
    station <- "Minot"
    minot_data <- cbind(minot_data, station)
    
    station <- "Oakes"
    oakes_data <- cbind(oakes_data, station)
    
    station <- "Academy"
    academy_data <- cbind(academy_data, station)
    
    #sorted by S to N by latitude
    all_data <- rbind(web_data, academy_data, oakes_data, crookston_data, minot_data)
    
    #add columns to designate event and height for plotting
    all_data <- all_data %>% add_column(event = event, height = height, .before = "source")
    
    #create one large df
    all_data_tidy <- rbind(all_data_tidy, all_data)
  }
}

#multiply percent row by 100 for plotting purposes
all_data_tidy$percent <- round(all_data_tidy$percent*100, 1)

#make event a factor
all_data_tidy$event <- factor(all_data_tidy$event, levels = c("rain", "extreme"))

#make station a factor
all_data_tidy$station <- factor(all_data_tidy$station,
                                levels = c("Webster\nCity", "Academy", "Oakes",
                                           "Crookston", "Minot"))

#plot counts on y axis
# ggplot(all_data) +
#   geom_bar(aes(station, count, fill = source), stat = "identity") +
#   geom_text(aes(station, count, label = paste0(percent, "%")),
#             position = position_stack(vjust = 0.5)) +
#   scale_fill_manual(values = c("blue", "forest green", "red"))

#plot percentages on y axis
ggplot(all_data_tidy) +
  geom_bar(aes(station, percent, fill = source), stat = "identity") +
#  geom_text(aes(station, percent, label = paste0(percent, "%")),
#            position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = c("#2171b5", "#238b45", "#cb181d")) +
  labs(x = "Station", y = "Percent of Events", fill = "Source") +
  facet_grid(height ~ event) +
  theme(#legend.title = element_blank(),
        axis.text = element_text(size = 15),
        #axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 18),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 14),
        strip.text = element_text(face = "bold", size = 14))

