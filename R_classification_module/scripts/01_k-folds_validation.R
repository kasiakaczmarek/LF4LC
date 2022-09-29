rm(list = ls())
options(scipen = 999)

# config -------------------------------------------------------------------------------------------
library(tidyverse)
library(caret)
library(kernlab)
library(xgboost)
library(readr)

name_of_run <- "20220928"

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")

classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)
dir.create(CLASSIFICATION_OUTPUT_PATH, showWarnings = FALSE)

source(file.path(classification_dir, "scripts", "_functions.R"))

# instrument <- "324"
# instrument <- "323"
instrument <- "complete_dataset"

# create scenarios ---------------------------
data_wide <- readRDS(file.path(DATA_WIDE_PATH, paste0("data_wide", instrument, "normalized01.RDS")))

scenario1 <- data_wide %>% select(id, label, contains("summary_segments"), contains("border_segments"))
scenario2 <- data_wide %>% select(id, label, contains("protoforms_short"), contains("protoforms_extended"))

scenarios_lst <- list(scenario1, scenario2)
no_of_scenarios <- length(scenarios_lst)
no_of_features <-  10
k_folds <- 5
dim_red_method <- "RFE"
# dim_red_method <- "PCA"

# use rfe --------------------------------------------------------------------------------------
rfe_selection_list <- prepare_reducted_dataset(dataset = data_wide,
                                               scenarios = scenarios_lst,
                                               no_of_scenarios = no_of_scenarios,
                                               dim_red_method = "rfe",
                                               no_of_features = no_of_features,
                                               no_of_cv_in_rfe = 5)

names(rfe_selection_list) <- paste0("S", seq_along(rfe_selection_list))

rfe_selection <- map(rfe_selection_list, data.frame)

for( i in seq_along(rfe_selection)){
  
  rfe_selection[[i]]$scenario_id <- rep(names(rfe_selection)[i], nrow(rfe_selection[[i]]))
  
}

rfe_selection <- bind_rows(rfe_selection)
colnames(rfe_selection)[1] <- "variable"

name_of_file <- paste0("rfe_selection_on_", instrument, ".csv")
write.csv(rfe_selection,
          file.path(CLASSIFICATION_OUTPUT_PATH, name_of_file),
          row.names = FALSE)

no_of_scenarios <- length(rfe_selection_list)
rm(scenarios_lst)
scenarios_list <- prepare_input_datasets(dim_red_method = "rfe",
                                         future_selection = rfe_selection_list,
                                         dataset = data_wide,
                                         no_of_scenarios = no_of_scenarios)


# create folds ----------------------------------------------------------------------
scenarios_folds <- prepare_folds_for_scenarios(datasets_list = scenarios_list,
                                               k_folds = k_folds)


### MODELLING -----------------------------------------------------------------------
time.start <- Sys.time()
# xgboost ----------------------------------------------------------------------------
xgboost_list <- vector("list")
for(i in names(scenarios_list)){
  xgboost_list[[i]] <- prepare_confusion_matrices(scenarios_list = scenarios_list,
                                                  folds = scenarios_folds,
                                                  scenario_nr = i, method = "xgboost") 
}


xgboost_prediction_list <- xgboost_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    xgboost_prediction_list[[j]][[i]][[2]] <- NULL
  }
}

for(i in names(scenarios_list)){
  xgboost_prediction_list[[i]] <- do.call(rbind, xgboost_prediction_list[[i]])
  xgboost_prediction_list[[i]] <- do.call(rbind, xgboost_prediction_list[[i]])
}



xgboost_conf_list <- xgboost_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    xgboost_conf_list[[j]][[i]][[1]] <- NULL
  }
}

for(i in names(scenarios_list)){
  xgboost_conf_list[[i]] <- do.call(rbind, xgboost_conf_list[[i]])
}

xgboost_summary <- map(xgboost_conf_list, prepare_classification_results, for_folds = TRUE)

scenario <- c(names(xgboost_summary))
xgboost <- bind_rows(xgboost_summary) %>% cbind(scenario) %>% mutate(model = "xgboost")


# C5.0 -------------------------------------------------------------------------------
C5.0_list <- vector("list")
for(i in names(scenarios_list)){
  C5.0_list[[i]] <- prepare_confusion_matrices(scenarios_list = scenarios_list,
                                                  folds = scenarios_folds,
                                                  scenario_nr = i, method = "C5.0") 
}


C5.0_prediction_list <- C5.0_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    C5.0_prediction_list[[j]][[i]][[2]] <- NULL
  }
}

for(i in names(scenarios_list)){
  C5.0_prediction_list[[i]] <- do.call(rbind, C5.0_prediction_list[[i]])
  C5.0_prediction_list[[i]] <- do.call(rbind, C5.0_prediction_list[[i]])
}



C5.0_conf_list <- C5.0_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    C5.0_conf_list[[j]][[i]][[1]] <- NULL
  }
}

for(i in names(scenarios_list)){
  C5.0_conf_list[[i]] <- do.call(rbind, C5.0_conf_list[[i]])
}

C5.0_summary <- map(C5.0_conf_list, prepare_classification_results, for_folds = TRUE)

scenario <- c(names(C5.0_summary))
C5.0 <- bind_rows(C5.0_summary) %>% cbind(scenario) %>% mutate(model = "C5.0")


# rf --------------------------------------------------------------------------------
rf_list <- vector("list")
for(i in names(scenarios_list)){
  rf_list[[i]] <- prepare_confusion_matrices(scenarios_list = scenarios_list,
                                                  folds = scenarios_folds,
                                                  scenario_nr = i, method = "rf") 
}


rf_prediction_list <- rf_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    rf_prediction_list[[j]][[i]][[2]] <- NULL
  }
}

for(i in names(scenarios_list)){
  rf_prediction_list[[i]] <- do.call(rbind, rf_prediction_list[[i]])
  rf_prediction_list[[i]] <- do.call(rbind, rf_prediction_list[[i]])
}



rf_conf_list <- rf_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    rf_conf_list[[j]][[i]][[1]] <- NULL
  }
}

for(i in names(scenarios_list)){
  rf_conf_list[[i]] <- do.call(rbind, rf_conf_list[[i]])
}

rf_summary <- map(rf_conf_list, prepare_classification_results, for_folds = TRUE)

scenario <- c(names(rf_summary))
rf <- bind_rows(rf_summary) %>% cbind(scenario) %>% mutate(model = "rf")



# svmRadial --------------------------------------------------------------------------------
svmRadial_list <- vector("list")
for(i in names(scenarios_list)){
  svmRadial_list[[i]] <- prepare_confusion_matrices(scenarios_list = scenarios_list,
                                                  folds = scenarios_folds,
                                                  scenario_nr = i, method = "svmRadial") 
}


svmRadial_prediction_list <- svmRadial_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    svmRadial_prediction_list[[j]][[i]][[2]] <- NULL
  }
}

for(i in names(scenarios_list)){
  svmRadial_prediction_list[[i]] <- do.call(rbind, svmRadial_prediction_list[[i]])
  svmRadial_prediction_list[[i]] <- do.call(rbind, svmRadial_prediction_list[[i]])
}



svmRadial_conf_list <- svmRadial_list
for(i in 1:k_folds){
  for(j in names(scenarios_list)){
    svmRadial_conf_list[[j]][[i]][[1]] <- NULL
  }
}

for(i in names(scenarios_list)){
  svmRadial_conf_list[[i]] <- do.call(rbind, svmRadial_conf_list[[i]])
}

svmRadial_summary <- map(svmRadial_conf_list, prepare_classification_results, for_folds = TRUE)

scenario <- c(names(svmRadial_summary))
svmRadial <- bind_rows(svmRadial_summary) %>% cbind(scenario) %>% mutate(model = "svmRadial")



time.end <- Sys.time()
time.end - time.start


# classification results ------------------------------------------------------------------------
classification_results <- rbind(xgboost, C5.0, rf, svmRadial)
result_file_name <- paste0("classification_results_on_", instrument, "_using", dim_red_method ,".csv")
write.csv(classification_results, 
          file.path(CLASSIFICATION_OUTPUT_PATH, result_file_name), row.names = FALSE)

predictions_lst <- list(xgboost = xgboost_prediction_list, 
                        C5.0 = C5.0_prediction_list, 
                        RF = rf_prediction_list, 
                        SVM = svmRadial_prediction_list)
predictions_file_name <- paste0("detailed_predictions_", instrument, ".RDS")
saveRDS(predictions_lst,
        file.path(CLASSIFICATION_OUTPUT_PATH, predictions_file_name))
