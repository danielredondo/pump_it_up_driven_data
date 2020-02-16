# 03_svm
# Daniel Redondo Sánchez

# ----- Ruta de trabajo (Mac y Windows) y semilla -----

setwd("~/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
setwd("C:/Users/dredondo/Dropbox/Transporte_interno/Máster/Ciencia de Datos/MDPC/Trabajo_final")
set.seed(1991)

# ----- Carga de paquetes -----

library(dplyr)
library(caret)
library(tictoc)
library(e1071)

# ----- Importación de conjunto de datos imputados -----

load("data/train_imputado.RData")
load("data/test_imputado.RData")

# ----- Creación de variables dummy -----

# train
# status_group se guarda aparte porque se va a hacer dummy
clase <- train$status_group
# Se crean las dummy de todos los factores
train <- fastDummies::dummy_cols(train)
train <- train %>%
  # Se eliminan los factores, que están como dummy también
  select_if(Negate(is.factor)) %>%
  # Hay que borrar manualmente las dummys que crea para status_group
  select(-status_group_functional, -`status_group_functional needs repair`, -`status_group_non functional`) %>%
  # Y se vuelve a agregar status_group
  cbind(status_group = clase)

# test (análogo pero más simple porque no tenemos status_group)
test <- fastDummies::dummy_cols(test)
test <- test %>%
  select_if(Negate(is.factor))

# ----- Normalización de variables numéricas al intervalo [0, 1] -----
# train
for (i in 1:ncol(train)) {
  if (is.numeric(train[, i])) {
    train[, i] <- (train[, i] - min(train[, i])) / (max(train[, i]) - min(train[, i]))
  }
}

# test
for (i in 1:ncol(test)) {
  if (is.numeric(test[, i])) {
    test[, i] <- (test[, i] - min(test[, i])) / (max(test[, i]) - min(test[, i]))
  }
}

# ----- Comprobación previa a entrenar el modelo -----

# Todas las variables se llaman igual (menos status_group, la última de train)
table(names(test) == names(train)[-ncol(train)])

# No hay datos faltantes
names(test[colSums(is.na(test)) > 0])
names(train[colSums(is.na(train)) > 0])

# ----- Entrenamiento del modelo -----

# Validación cruzada 5-folds, balanceados por status_group
folds <- createFolds(train$status_group, k = 5)

# Entrenamiento del modelo
cv <- lapply(folds, function(x) {
  
  # Para empezar a medir el tiempo
  tic("CV") 
  
  # Se definen training y test
  training_fold <- train[-x, ]
  test_fold <- train[x, ]
  
  # Se entrena el clasificador (kernel radial, con coste = 5)
  classifier <- svm(
    formula = status_group ~ .,
    data = training_fold,
    kernel = "radial",
    cost = 5
  )

  # Se crea la predicción
  y_pred <- predict(classifier, newdata = test_fold[-ncol(train)])
  
  # Se imprime la matriz de confusión
  cm <- table(test_fold[, ncol(train)], y_pred)
  print(cm)
  
  # Porcentaje de aciertos (que es la medida objetivo de la competición)
  aciertos <- which(y_pred == test_fold[, ncol(train)])
  porcentaje <- length(aciertos) / length(test_fold[, ncol(train)]) * 100
  
  # Se imprime el porcentaje de aciertos 
  print(porcentaje)
  
  # Se para de medir el tiempo
  toc()
  
  # Se devuelve el porcentaje
  return(porcentaje)
})

# Finalmente, se calcula el porcentaje medio de la validación cruzada
porcentaje_medio <- mean(as.numeric(cv))
porcentaje_medio

# ----- Creación del modelo -----

# Predicción - con todo el train
modelo <- svm(
  formula = status_group ~ .,
  data = train,
  kernel = "radial",
  cost = 5
)

# ----- Predicción de test -----

y_pred <- predict(modelo, newdata = test)

# ----- Creación de fichero para subir a DrivenData -----

# Se cambian las labels de y_pred para que exporte texto y no números ("functional" y no 1)
y_pred <- factor(y_pred, levels = levels(y_pred), labels = levels(y_pred))

# Se recupera el id del test
id_test <- read.csv("data/test_set_values.csv",
  na.strings = c("", "Unknown", "unknown", "none")
) %>%
  select(id)

# Se crea data.frame
export <- data.frame(id_test, y_pred)
head(export)

# ----- Exportación de fichero para subir a DrivenData -----

write.csv(export, "submission.csv", row.names = FALSE, quote = FALSE)