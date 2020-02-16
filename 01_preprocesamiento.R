# 01_preprocesamiento
# Daniel Redondo Sánchez

# ----- Ruta de trabajo (Mac y Windows) y semilla -----

setwd("~/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
setwd("C:/Users/dredondo/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
set.seed(1991)

# ----- Carga de paquetes -----

library(dplyr) # Para usar pipes, select, mutate...
library(VIM)   # Para visualizar datos faltantes

# ----- Importación de conjunto de datos -----

# Train
# Se importa el conjunto de datos
train <- read.csv("data/training_set_values.csv",
  na.strings = c("", "Unknown", "unknown", "none")
)
trainlabel <- read.csv("data/training_set_labels.csv")
# Se juntan los valores con las etiquetas
train <- merge(train, trainlabel, by = "id")

# Test
# Se importa el conjunto de datos
test <- read.csv("data/test_set_values.csv",
  na.strings = c("", "Unknown", "unknown", "none")
)

# ----- Eliminar variables -----

# Variables que se repiten y se pueden eliminar del conjunto de datos
table(train$quality, train$quality_group)
table(train$payment, train$payment_type)
table(train$quantity, train$quantity_group)
train <- train %>% select(-quality_group, -payment_type, -quantity_group)
test <- test %>% select(-quality_group, -payment_type, -quantity_group)

# No exactamente repetidas, pero casi. Eliminamos la variable más general
table(train$waterpoint_type, train$waterpoint_type_group)
train <- train %>% select(-waterpoint_type_group)
test <- test %>% select(-waterpoint_type_group)

# Se eliminan variables que no aportan nada
# recorded_by que sólo tiene un valor, y el id tras comprobar que no hay duplicados
table(train$recorded_by)
table(table(train$id) > 1)

train <- train %>% select(-recorded_by, -id)
test <- test %>% select(-recorded_by, -id)

# ----- Análisis de valores perdidos -----

# Valores perdidos de todo el conjunto
table(is.na(train))

# Valores perdidos de cada variable
train %>%
  is.na() %>%
  colSums()

# Variables con valores perdidos
names(train)[colSums(is.na(train)) > 0]

# Gráfico con valores perdidos (train)
aggr(train,
  col = c("blue", "red"), numbers = TRUE, sortVars = TRUE,
  labels = names(train), cex.axis = .7,
  cex.numbers = .5, gap = 0,
  ylab = c("Histogram of missing data", "Pattern")
)

# Gráfico con valores perdidos (test)
aggr(test,
  col = c("blue", "red"), numbers = TRUE, sortVars = TRUE,
  labels = names(test), cex.axis = .7,
  cex.numbers = .5, gap = 0,
  ylab = c("Histogram of missing data", "Pattern")
)

# ----- Creación de nuevas variables -----

# Se extrae el mes de registro (la temperatura podría estar relacionada con status_group)
# Y la fecha se pasa a numérico (está en carácter)

# Train
train <- train %>%
  mutate(
    date_recorded = as.numeric(as.Date(date_recorded)),
    mes = factor(format(as.Date(train$date_recorded), "%b"))
  )

# Se vuelve a poner status_group como última variable
train <- train %>% select(-status_group, everything(), status_group)

# Test
test <- test %>%
  mutate(
    date_recorded = as.numeric(as.Date(date_recorded)),
    mes = factor(format(as.Date(test$date_recorded), "%b"))
  )

# ----- Reducción de categorías + Recodificación de valores perdidos -----

# Todos los niveles por debajo de este corte, se recodificarán como "Otros"
# Los datos faltantes también se recodifican como "Otros"
# El corte va cambiando en función de la variable a cortar
corte <- 1000

# Reducción de categorías - funder
# Train
niveles_frecuentes_corte <- levels(train$funder)[table(train$funder) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte) # Se muestran los niveles resultantes de la recodificación
v <- factor(train$funder, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros" # Los datos faltantes se pasan a "Otros"
train$funder <- v
# Test
v <- factor(test$funder, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$funder <- v

# Reducción de categorías - lga
niveles_frecuentes_corte <- levels(train$lga)[table(train$lga) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$lga, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$lga <- v
# Test
v <- factor(test$lga, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$lga <- v

# Reducción de categorías - construction_year
train$construction_year <- factor(train$construction_year)
niveles_frecuentes_corte <- levels(train$construction_year)[table(train$construction_year) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$construction_year, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$construction_year <- v
# test
v <- factor(test$construction_year, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$construction_year <- v

# Se rebaja el nivel del corte para permitir más niveles en variables que tienen niveles menos frecuentes
corte <- 500

# Reducción de categorías - installer
niveles_frecuentes_corte <- levels(train$installer)[table(train$installer) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$installer, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$installer <- v
# Test
v <- factor(test$installer, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$installer <- v

# Reducción de categorías - scheme_management
niveles_frecuentes_corte <- levels(train$scheme_management)[table(train$scheme_management) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$scheme_management, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$scheme_management <- v
# Test
v <- factor(test$scheme_management, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$scheme_management <- v

# Reducción de categorías - management
niveles_frecuentes_corte <- levels(train$management)[table(train$management) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$management, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$management <- v
# Test
v <- factor(test$management, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$management <- v

# Reducción de categorías - waterpoint_type
# Es un caso algo especial porque "other" ya es un nivel que supera el corte
niveles_frecuentes_corte <- levels(train$waterpoint_type)[table(train$waterpoint_type) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte), " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$waterpoint_type, levels = c(niveles_frecuentes_corte))
v[is.na(v)] <- "other"
train$waterpoint_type <- v
# test
v <- factor(test$waterpoint_type, levels = c(niveles_frecuentes_corte))
v[is.na(v)] <- "other"
test$waterpoint_type <- v

# Reducción de categorías - extraction_type
niveles_frecuentes_corte <- levels(train$extraction_type)[table(train$extraction_type) > corte]
print(paste0("Se va a restringir a ", length(niveles_frecuentes_corte) + 1, " niveles"))
print(niveles_frecuentes_corte)
v <- factor(train$extraction_type, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
train$extraction_type <- v
# test
v <- factor(test$extraction_type, levels = c(niveles_frecuentes_corte, "Otros"))
v[is.na(v)] <- "Otros"
test$extraction_type <- v

# Quitar variables con 3 niveles o menos que superen el corte de 500 casos
levels(train$wpt_name)[table(train$wpt_name) > corte]
levels(train$num_private)[table(train$num_private) > corte]
levels(train$subvillage)[table(train$subvillage) > corte]
levels(train$region_code)[table(train$region_code) > corte]
levels(train$district_code)[table(train$district_code) > corte]
levels(train$ward)[table(train$ward) > corte]
levels(train$scheme_name)[table(train$scheme_name) > corte]

# train
train <- train %>% select(
  -wpt_name, -num_private, -subvillage, -region_code, -district_code,
  -ward, -scheme_name
)

# test
test <- test %>% select(
  -wpt_name, -num_private, -subvillage, -region_code, -district_code,
  -ward, -scheme_name
)

# ----- Exportación del conjunto de datos -----
save(train, file = "data/train.RData")
save(test, file = "data/test.RData")
