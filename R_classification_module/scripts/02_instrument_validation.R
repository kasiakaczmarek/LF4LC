rm(list = ls())

# config -------------------------------------------------------------------------------------------
library(tidyverse)
library(caret)
library(kernlab)
library(xgboost)
library(readr)

name_of_run <- "20220928"
no_of_scenarios <- 3

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")

classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)
dir.create(CLASSIFICATION_OUTPUT_PATH, showWarnings = FALSE)

source(file.path(classification_dir, "scripts", "_functions.R"))

portfolio_for_training <- "324"
portfolio_for_testing <- "323"

search_id <- c("FN", "TN")

# portfolio_for_training <- "323"
# portfolio_for_testing <- "324"
# search_id <- c("FN", "TN")


# rfe ----------------------------------------------------------------------------------
selection_method <- "RFE"

if(portfolio_for_training == "324"){
  rfe_selection <- read_csv(file.path(CLASSIFICATION_OUTPUT_PATH, "rfe_selection_on_324.csv"))
  data_wide_train <- readRDS(file.path(DATA_WIDE_PATH, "data_wide324normalized01.RDS"))
  data_wide_test <- readRDS(file.path(DATA_WIDE_PATH, "data_wide323normalized01.RDS"))
} else {
  rfe_selection <- read_csv(pastfile.pathe0(CLASSIFICATION_OUTPUT_PATH, "rfe_selection_on_323.csv"))
  data_wide_train <- readRDS(file.path(DATA_WIDE_PATH, "data_wide323normalized01.RDS"))
  data_wide_test <- readRDS(file.path(DATA_WIDE_PATH, "data_wide324normalized01.RDS"))
}

no_of_scenarios <- max(rfe_selection$scenario_id)
s <- rfe_selection$scenario_id %>% unique()

rfe <- vector("list")
for(i in s){
  rfe[[i]] <- rfe_selection %>% filter(scenario_id == i) %>% 
    select(variable) %>% pull()
}



data_wide_train <- data.frame(data_wide_train) %>% 
  mutate(label = as.numeric(as.factor(data_wide_train$label)) - 1)

data_wide_test <- data.frame(data_wide_test) %>% 
  mutate(label = as.numeric(as.factor(data_wide_test$label)) - 1) 


scenarios_datasets_train <- prepare_input_datasets(future_selection = rfe,
                                                   dim_red_method = "rfe",
                                                   dataset = data_wide_train)

scenarios_datasets_test <- prepare_input_datasets(future_selection = rfe,
                                                  dim_red_method = "rfe",
                                                  dataset = data_wide_test)



# xgboost --------------------------------------------------------------
xgboost_train_vs_test <- vector("list")
conf_matrix_xgboost <- vector("list")
for(i in s){
input_data <- scenarios_datasets_train[[i]] %>% select(-id)

dataset_model <- xgboost(data = data.matrix(input_data[-1]),
                         label = input_data$label,
                         max.depth = 20,
                         eta = 0.1,
                         nthread = 3,
                         nrounds = 50,
                         objective = "binary:logistic"
)

newdata <- data.matrix(scenarios_datasets_test[[i]] %>% select(-id, -label))
dataset_predict <-predict(dataset_model, newdata = newdata, reshape = T)
dataset_predict <- ifelse(dataset_predict >= 0.5, "_poor_", "_good_") %>% as.factor()

xgboost_train_vs_test[[i]] <- cbind(scenarios_datasets_test[[i]][, 1:2], dataset_predict) %>% 
  mutate(x = ifelse(label == 0 & dataset_predict == "_good_", "TP",
                    ifelse(label == 0 & dataset_predict == "_poor_", "FN",
                           ifelse(label == 1 & dataset_predict == "_poor_", "TN", "FP"))))

conf_matrix_xgboost[[i]] <- table(scenarios_datasets_test[[i]][, 2], dataset_predict)
}

xgboost_results <- prepare_classification_results(conf_matrix_xgboost, length = no_of_scenarios) #lenght = no of scenarios
xgboost_results <- xgboost_results %>% cbind(s) %>% mutate(model = "xgboost")


xgboost_ids_list <- map(xgboost_train_vs_test, ~filter(., x %in% search_id))
scenarios_ids <- s
xgboost_ids_list <- Map(cbind, xgboost_ids_list, scenario = scenarios_ids)
xgboost_ids <- bind_rows(xgboost_ids_list) %>% select(id, scenario, x) %>% mutate(model = "xgboost")


# C5.0 ----------------------------------------------------------------------
C5.0_train_vs_test <- vector("list")
conf_matrix_C5.0 <- vector("list")
for(i in s){
  input_data <- scenarios_datasets_train[[i]] %>% select(-id)
  input_data$label <- as.factor(input_data$label)
  
  dataset_model <- train(y = input_data$label, 
                         x = data.matrix(input_data[-1]),
                         method = "C5.0")
  newdata <- data.matrix(scenarios_datasets_test[[i]] %>% select(-id, -label))
  dataset_predict <-predict(dataset_model, newdata = newdata, reshape = T)
  dataset_predict <- ifelse(dataset_predict == 1, "_poor_", "_good_") %>% as.factor()
  
  C5.0_train_vs_test[[i]] <- cbind(scenarios_datasets_test[[i]][, 1:2], dataset_predict) %>% 
    mutate(x = ifelse(label == 0 & dataset_predict == "_good_", "TP",
                      ifelse(label == 0 & dataset_predict == "_poor_", "FN",
                             ifelse(label == 1 & dataset_predict == "_poor_", "TN", "FP"))))
  
  conf_matrix_C5.0[[i]] <- table(scenarios_datasets_test[[i]][, 2], dataset_predict)
}

C5.0_results <- prepare_classification_results(conf_matrix_C5.0, length = no_of_scenarios)
C5.0_results <- C5.0_results %>% cbind(s) %>% mutate(model = "C5.0")

C5.0_ids_list <- map(C5.0_train_vs_test, ~filter(., x %in% search_id))
scenarios_ids <- s
C5.0_ids_list <- Map(cbind, C5.0_ids_list, scenario = scenarios_ids)
C5.0_ids <- bind_rows(C5.0_ids_list) %>% select(id, scenario, x) %>% mutate(model = "C5.0")


# rf ------------------------------------------------------------------------
rf_train_vs_test <- vector("list")
conf_matrix_rf <- vector("list")
for(i in s){
  input_data <- scenarios_datasets_train[[i]] %>% select(-id)
  input_data$label <- as.factor(input_data$label)
  
  dataset_model <- train(y = input_data$label, 
                         x = data.matrix(input_data[-1]),
                         method = "rf")
  newdata <- data.matrix(scenarios_datasets_test[[i]] %>% select(-id, -label))
  dataset_predict <-predict(dataset_model, newdata = newdata, reshape = T)
  dataset_predict <- ifelse(dataset_predict == 1, "_poor_", "_good_") %>% as.factor()
  
  rf_train_vs_test[[i]] <- cbind(scenarios_datasets_test[[i]][, 1:2], dataset_predict) %>% 
    mutate(x = ifelse(label == 0 & dataset_predict == "_good_", "TP",
                      ifelse(label == 0 & dataset_predict == "_poor_", "FN",
                             ifelse(label == 1 & dataset_predict == "_poor_", "TN", "FP"))))
  
  conf_matrix_rf[[i]] <- table(scenarios_datasets_test[[i]][, 2], dataset_predict)
}


rf_results <- prepare_classification_results(conf_matrix_rf, length = no_of_scenarios)
rf_results <- rf_results %>% cbind(s) %>% mutate(model = "rf")

rf_ids_list <- map(rf_train_vs_test, ~filter(., x %in% search_id))
scenarios_ids <- s
rf_ids_list <- Map(cbind, rf_ids_list, scenario = scenarios_ids)
rf_ids <- bind_rows(rf_ids_list) %>% select(id, scenario, x) %>% mutate(model = "rf")


# SvmRadial -----------------------------------------------------------------
svmRadial_train_vs_test <- vector("list")
conf_matrix_svmRadial <- vector("list")
for(i in s){
  input_data <- scenarios_datasets_train[[i]] %>% select(-id)
  input_data$label <- as.factor(input_data$label)
  
  dataset_model <- train(y = input_data$label, 
                         x = data.matrix(input_data[-1]),
                         method = "svmRadial",
                         tuneLength = 5)
  newdata <- data.matrix(scenarios_datasets_test[[i]] %>% select(-id, -label))
  dataset_predict <-predict(dataset_model, newdata = newdata, reshape = T)
  dataset_predict <- ifelse(dataset_predict == 1, "_poor_", "_good_") %>% as.factor()
  
  svmRadial_train_vs_test[[i]] <- cbind(scenarios_datasets_test[[i]][, 1:2], dataset_predict) %>% 
    mutate(x = ifelse(label == 0 & dataset_predict == "_good_", "TP",
                      ifelse(label == 0 & dataset_predict == "_poor_", "FN",
                             ifelse(label == 1 & dataset_predict == "_poor_", "TN", "FP"))))
  
  conf_matrix_svmRadial[[i]] <- table(scenarios_datasets_test[[i]][, 2], dataset_predict)
}


svmRadial_results <- prepare_classification_results(conf_matrix_svmRadial, length = no_of_scenarios)
svmRadial_results <- svmRadial_results %>% cbind(s) %>% mutate(model = "svmRadial")

svmRadial_ids_list <- map(svmRadial_train_vs_test, ~filter(., x %in% search_id))
scenarios_ids <- s
svmRadial_ids_list <- Map(cbind, svmRadial_ids_list, scenario = scenarios_ids)
svmRadial_ids <- bind_rows(svmRadial_ids_list) %>% select(id, scenario, x) %>% mutate(model = "svmRadial")


# results --------------------------------------------------------------------
classification_results <- xgboost_results %>% rbind(C5.0_results) %>% rbind(rf_results) %>% rbind(svmRadial_results) %>% 
  rename(scenario = s)

results_file_name <- paste0("classification_results_train_on", portfolio_for_training, "test_on", portfolio_for_testing, ".csv")
write.csv(classification_results, file.path(CLASSIFICATION_OUTPUT_PATH, results_file_name),row.names = FALSE)

# ids <- xgboost_ids %>% rbind(C5.0_ids) %>% rbind(rf_ids) %>% rbind(svmRadial_ids)
# ids_file_name <- paste0(search_id[1], search_id[2], "_ids_train_on", portfolio_for_training, "test_on", portfolio_for_testing, ".csv")
# write.csv(ids, file.path(CLASSIFICATION_OUTPUT_PATH, ids_file_name), row.names = FALSE)
