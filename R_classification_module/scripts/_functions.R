
# 1. Prepare five scenarios: dataset using reduction of dimension: rfe or pca ----------------------------------------
prepare_reducted_dataset <- function(dataset,
                                     scenarios,
                                     no_of_scenarios,
                                     dim_red_method = "rfe",
                                     no_of_features = 10,
                                     no_of_cv_in_rfe = 5){
  

  target <- factor(dataset$label)

  lst <- vector("list", no_of_scenarios)
  selection <- vector("list", no_of_scenarios+1)
  
  if (dim_red_method == "rfe") {
    control <- rfeControl(functions = rfFuncs, method = "cv", number = no_of_cv_in_rfe)

    for (i in 1:no_of_scenarios) {

        lst[[i]] <- rfe(scenarios[[i]][, 3:ncol(scenarios[[i]])],
                        target, sizes = no_of_features, metric = "Accuracy", rfeControl = control)
        
        selection[[i]] <- predictors(lst[[i]])[1:no_of_features]
    }
  } else if (dim_red_method == "pca"){
    for (i in 1:no_of_scenarios) {
      lst[[i]] <- scenarios[[i]][,1:2] %>% cbind(prcomp(scenarios[[i]][,3:length(scenarios[[i]])])$x %>% data.frame())

      selection[[i]] <- lst[[i]][,1:(no_of_features+2)]
      }
  }
  
  selection[[no_of_scenarios+1]] <- c(selection[[1]][1:(no_of_features/2)],selection[[2]][1:(no_of_features/2)])
  no_of_scenarios <<- length(selection)
  return(selection)
}



# 2. Prepare dataset of every scenario as input for models using selected futures  ------------------------------------------
prepare_input_datasets <- function(dim_red_method,
                                   future_selection,
                                   dataset,
                                   no_of_scenarios){
  
  if (dim_red_method == "rfe"){
  scenarios_list <- vector("list")
  
  for (i in names(future_selection)) {
  scenarios_list[[i]] <- dataset %>% 
    select(id, label, future_selection[[i]])
  }
  
  return(scenarios_list)
  } else if (dim_red_method == "pca"){
     scenarios_list <- dataset
  }
}



# 3. Prepare folds for every dataset for every scenario ----------------------------------------------------------------------
prepare_folds_for_scenarios <-
  function(datasets_list = scenarios_list,
           k_folds = 5) {
    
    folds <- vector("list")
    set.seed(123)
    for (i in names(datasets_list)) {
      folds[[i]] <- createFolds(datasets_list[[i]]$label, k = k_folds)
    }
    
    return(folds)
  }
    


# 4. Prepare confusion matrix for scenario using one of models --------------------------------------------------------------
prepare_confusion_matrices <- function(scenarios_list = scenarios_list,
                                           folds = scenarios_folds,
                                           scenario_nr,
                                           method) {
  
    input_data <- scenarios_list[[scenario_nr]]
    folds <- folds[[scenario_nr]]
    
    if(method == "xgboost"){
      conf <- lapply(folds, function(x) {
        traing = input_data[-x, ]
        test = input_data[x, ]
        traing_folds = input_data[-x, -1]
        test_folds = input_data[x, -1]
      
      dataset_model <- xgboost(data = data.matrix(traing_folds[-1]),
                                 label = traing_folds$label,
                                 max.depth = 15,
                                 eta = 0.1,
                                 nthread = 3,
                                 nrounds = 25,
                                 objective = "binary:logistic"
                                )
        
        dataset_predict <-predict(dataset_model, newdata = data.matrix(test_folds[-1]), reshape = T)
        dataset_predict <- ifelse(dataset_predict >= 0.5, "_poor_", "_good_") %>% as.factor()
        label_vs_prediction <- cbind(test[,1:2], dataset_predict) %>% 
          mutate(x = ifelse(label == 0 & dataset_predict == "_good_", "TP",
                            ifelse(label == 0 & dataset_predict == "_poor_", "FN",
                                   ifelse(label == 1 & dataset_predict == "_poor_", "TN", "FP"))))
        
        conf_table <- table(test_folds[, 1], dataset_predict)
        return(list(label_vs_prediction, conf_table))
      })
    }
    
    else if(method == "svmRadial"){
      conf <- lapply(folds, function(x){
        input_data$label <- as.factor(input_data$label)
        traing = input_data[-x, ]
        test = input_data[x, ]
        traing_folds = input_data[-x, -1]
        test_folds = input_data[x, -1]
        
        dataset_model <- train(label ~ ., data = traing_folds,
                               method = "svmRadial",
                               tuneLength = 5)
        dataset_predict <-predict(dataset_model, newdata = data.matrix(test_folds[-1]), reshape = T)
        label_vs_prediction <- cbind(test[,1:2], dataset_predict) %>% 
          mutate(x = ifelse(label == 0 & dataset_predict == 0, "TP",
                            ifelse(label == 0 & dataset_predict == 1, "FN",
                                   ifelse(label == 1 & dataset_predict == 1, "TN", "FP"))))
        conf_table <- table(test_folds[, 1], dataset_predict)
        list_conf_predict <- list(label_vs_prediction, conf_table)
        return(list_conf_predict)
      })
    }
    
    else {
      
      conf <- lapply(folds, function(x){
        input_data$label <- as.factor(input_data$label)
        traing = input_data[-x, ]
        test = input_data[x, ]
        traing_folds = input_data[-x, -1]
        test_folds = input_data[x, -1]
        
        dataset_model <- train(label ~ ., data = traing_folds,
                               method = method)
        dataset_predict <-predict(dataset_model, newdata = data.matrix(test_folds[-1]), reshape = T)
        label_vs_prediction <- cbind(test[,1:2], dataset_predict) %>% 
          mutate(x = ifelse(label == 0 & dataset_predict == 0, "TP",
                            ifelse(label == 0 & dataset_predict == 1, "FN",
                                   ifelse(label == 1 & dataset_predict == 1, "TN", "FP"))))
        conf_table <- table(test_folds[, 1], dataset_predict)
        list_conf_predict <- list(label_vs_prediction, conf_table)
        return(list_conf_predict)
      })
    }
      

  return(conf)
    
  }



# 5. Prepare classification result for every fold in dataset ---------------------------------------------------------------
prepare_classification_results <- function(list,
                                           for_folds = FALSE,
                                           length = 5){
  TP <- c()
  TN <- c()
  FP <- c()
  FN <- c()
  
  for (i in 1:length){
    TP[i] <- list[[i]][1]
    FP[i] <- list[[i]][2]
    FN[i] <- list[[i]][3]
    TN[i] <- list[[i]][4]
  }
  
  folds_metrics <- data.frame(TP,FN,FP,TN) %>% 
    mutate(accuracy = (TP+TN)/(TP+FN+FP+TN),
           sensitivity_recall = TP/(TP+FN),
           specificity = TN/(FP+TN),
           precision = TP/(TP+FP),
           prevalence = (TP+FN)/(TP+FN+FP+TN),
           detection_prevalence = (TP+FP)/(TP+FN+FP+TN),
           detection_rate = TP/(TP+FN+FP+TN),
           F1 = 2*precision*sensitivity_recall/(precision+sensitivity_recall),
           balanced_accuracy = (sensitivity_recall + specificity)/2)
 
  
  if(for_folds == TRUE){ 
  sum <- folds_metrics %>% 
    select(TP,FN,FP,TN) %>% 
    summarise_all(list(~sum(.)))
  
  mean <- folds_metrics %>% 
    select(accuracy:balanced_accuracy) %>% 
    summarise_all(list(~mean(.)))
  
  
  model_evaluation <- sum %>% cbind(mean)
  } else {model_evaluation <- folds_metrics}
  
  return(model_evaluation)
}


