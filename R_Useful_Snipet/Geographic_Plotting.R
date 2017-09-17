setwd("~")
a = read.csv('JAB Brand Retail.csv', header = TRUE)
head(a)

library(dplyr)

overview <- a %>% group_by(Business.Vanity.Name, CASS_State) %>% 
  summarize(number = sum(SQUARE.FOOTAGE.ESTIMATOR),
            count = n(),
            avg_sqr_footage = mean(SQUARE.FOOTAGE.ESTIMATOR)) %>%
  arrange(Business.Vanity.Name, desc(count))
View(overview)

library(ggplot2)
state_order = group_by(overview, CASS_State) %>% summarise(total = sum(count))
state = arrange(as.data.frame(state_order), total)

overview$CASS_State <- factor(overview$CASS_State, levels = overview$CASS_State[order(overview$count)])
x$name  # notice the changed order of factor levels
graph1 <- ggplot(overview, aes(x= CASS_State, y=count))+
  geom_bar(aes(fill = Business.Vanity.Name), stat="identity")+
  ggtitle("Retail Stores Count by State")+
  labs(x="State", y="Number of Stores") + scale_fill_discrete(name = "Brand Name")
graph1


graph2 <- ggplot(data=overview, aes(x=Business.Vanity.Name, y=avg_sqr_footage))+
  geom_boxplot(aes(fill = Business.Vanity.Name))+
  ggtitle("Average Store Square Footage")+
  labs(x="Brand", y="Average Store Sqr.ft")
graph2

library('ggmap')

map <- get_map(location = "united states", zoom = 4, maptype = "roadmap", crop =FALSE, color = 'bw')

mapPoints <- ggmap(map) + geom_point(data = a, aes(x = LONG1, y = LATT1, color = Business.Vanity.Name),
             stat = 'identity', alpha = 0.5, size = 1.5)+scale_fill_gradientn(colours=c("red","yellow","green", "blue", "purple", "pink", "orange")) + scale_color_manual(name = "Brand Name",
                            values = c("CARIBOU COFFEE" = "darkred",
                                       "EINSTEIN BROTHERS BAGELS" = "yellow",
                                       "Intelligentsia" = "red",
                                       "KRISPY KREME" = "darkblue",
                                       "PANERA BREAD" = "darkgreen",
                                       "PEETS" = "orange",
                                       "STUMPTOWN" ="purple"))
mapPoints

map_ca <- get_map(location = "california", zoom = 6, maptype = "roadmap", crop =FALSE, color = 'bw')
mapPoints_ca <- ggmap(map_ca) + geom_point(data = a, aes(x = LONG1, y = LATT1, color = Business.Vanity.Name),
                                     stat = 'identity', alpha = 0.5, size = 1.5)+scale_fill_gradientn(colours=c("red","yellow","green", "blue", "purple", "pink", "orange")) + scale_color_manual(name = "Brand Name",
                                                                                                                                                                                                  values = c("CARIBOU COFFEE" = "darkred",
                                                                                                                                                                                                             "EINSTEIN BROTHERS BAGELS" = "yellow",
                                                                                                                                                                                                             "Intelligentsia" = "red",
                                                                                                                                                                                                             "KRISPY KREME" = "darkblue",
                                                                                                                                                                                                             "PANERA BREAD" = "darkgreen",
                                                                                                                                                                                                             "PEETS" = "orange",
                                                                                                                                                                                                             "STUMPTOWN" ="purple"))
mapPoints_ca


map_il <- get_map(location = "illinois", zoom = 6, maptype = "roadmap", crop =FALSE, color = 'bw')
mapPoints_il <- ggmap(map_il) + geom_point(data = a, aes(x = LONG1, y = LATT1, color = Business.Vanity.Name),
                                       stat = 'identity', alpha = 0.5, size = 1.5)+scale_fill_gradientn(colours=c("red","yellow","green", "blue", "purple", "pink", "orange")) + scale_color_manual(name = "Brand Name",
                                                                                                                                                                                                    values = c("CARIBOU COFFEE" = "darkred",
                                                                                                                                                                                                               "EINSTEIN BROTHERS BAGELS" = "yellow",
                                                                                                                                                                                                               "Intelligentsia" = "red",
                                                                                                                                                                                                               "KRISPY KREME" = "darkblue",
                                                                                                                                                                                                               "PANERA BREAD" = "darkgreen",
                                                                                                                                                                                                               "PEETS" = "orange",
                                                                                                                                                                                                               "STUMPTOWN" ="purple"))
mapPoints_il


map_NY <- get_map(location = "new york", zoom = 6, maptype = "roadmap", crop =FALSE, color = 'bw')
mapPoints_ny <- ggmap(map_NY) + geom_point(data = a, aes(x = LONG1, y = LATT1, color = Business.Vanity.Name),
                                           stat = 'identity', alpha = 0.5, size = 1.5)+scale_fill_gradientn(colours=c("red","yellow","green", "blue", "purple", "pink", "orange")) + scale_color_manual(name = "Brand Name",
                                                                                                                                                                                                        values = c("CARIBOU COFFEE" = "darkred",
                                                                                                                                                                                                                   "EINSTEIN BROTHERS BAGELS" = "yellow",
                                                                                                                                                                                                                   "Intelligentsia" = "red",
                                                                                                                                                                                                                   "KRISPY KREME" = "darkblue",
                                                                                                                                                                                                                   "PANERA BREAD" = "darkgreen",
                                                                                                                                                                                                                   "PEETS" = "orange",
                                                                                                                                                                                                                   "STUMPTOWN" ="purple"))
mapPoints_ny




