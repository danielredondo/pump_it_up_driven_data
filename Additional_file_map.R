# ----- Carga de paquetes -----

library(readr)
library(dplyr)
library(rgdal)
library(leaflet)
library(rgeos)
library(htmlwidgets)

# ----- Importación de ficheros -----

train <- read.csv(file = "Data/training_set_values.csv")
labels <- read.csv(file = "Data/training_set_labels.csv")
train <- cbind(train, status_group = labels$status_group)

# ----- Se eliminan casos con longitud 0 -----

nrow(train)
train <- train %>% filter(train$longitude != 0)
nrow(train)

# ----- Creación de código de colores -----

color <- ifelse(train$status_group == "functional",
  "green",
  ifelse(train$status_group == "non functional",
    "red",
    "orange"
  )
)

# ----- Mapa en leaflet -----

leaflet() %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  addCircles(lng = train$longitude,
              lat = train$latitude,
              fillColor = color,
             stroke = FALSE, radius = 5000) -> mapa

# ----- Exportación de mapa -----

saveWidget(mapa, "mapa.html")
