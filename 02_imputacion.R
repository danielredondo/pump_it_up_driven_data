# 02_imputacion
# Daniel Redondo Sánchez

# ----- Ruta de trabajo (Mac y Windows) y semilla -----

setwd("~/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
setwd("C:/Users/dredondo/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
set.seed(1991)

# ----- Carga de paquetes -----

library(mice) # Para imputar

# ----- Importación de conjunto de datos -----

load(file = "data/train.RData")

# ----- Inicialización de imputación -----

init <- mice(train, maxit = 0)
metodos <- init$method # logreg para binarias (public_meeting, permit y source_class) y polyreg para el resto
matriz_de_predictores <- init$predictorMatrix

# ----- Imputación -----

# Ver variables con datos perdidos
names(train[colSums(is.na(train)) > 0])

# Imputación (1 conjunto, 5 iteraciones)
imputed <- mice(train, method = metodos, predictorMatrix = matriz_de_predictores, m = 1, maxit = 5)

# Completar la imputación
train <- mice::complete(imputed)

# Ver variables con datos perdidos - no hay tras imputación
names(train[colSums(is.na(train)) > 0])

# ----- Exportación de conjuntos de datos -----

save(train, file = "data/train_imputado.RData")


# Y análogo para test:

# ----- Importación de conjunto de datos -----

load(file = "data/test.RData")

# ----- Inicialización de imputación -----

init <- mice(test, maxit = 0)
metodos <- init$method
matriz_de_predictores <- init$predictorMatrix

# ----- Imputación -----

# Ver variables con datos perdidos
names(test[colSums(is.na(test)) > 0])

# Imputación (1 conjunto, 5 iteraciones)
imputed <- mice(test, method = metodos, predictorMatrix = matriz_de_predictores, m = 1, maxit = 5)

# Completar la imputación
test <- mice::complete(imputed)

# Ver variables con datos perdidos - no hay tras imputación
names(test[colSums(is.na(test)) > 0])

# ----- Exportación de conjuntos de datos -----

save(test, file = "data/test_imputado.RData")