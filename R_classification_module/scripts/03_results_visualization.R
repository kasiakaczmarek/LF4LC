rm(list = ls())

# config ------------------------------------------------------
library(dplyr)
library(ggplot2)
library(reshape2)

name_of_run <- "20220928"

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")

classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)
dir.create(CLASSIFICATION_OUTPUT_PATH, showWarnings = FALSE)

plots_dir <- "plots"
PLOTS_PATH <- file.path(classification_dir, plots_dir, name_of_run)
dir.create(PLOTS_PATH, showWarnings = FALSE)

no_of_scenarios <- 3
scenarios <- c("S1", "S2", "S3")

# variant <- "_for_full_results"
variant <- "_for_validation_on323"
# variant <- "_for_validation_on324"


if(variant == "_for_full_results"){
  file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = ".*classification_results_on_complete.*\\.csv$", full.names=TRUE)
} else if(variant == "_for_validation_on323"){
  file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = ".*classification_results_train_on324.*\\.csv$", full.names=TRUE)
} else {
  file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = ".*classification_results_train_on323.*\\.csv$", full.names=TRUE)
}

data <- read.csv(file) #%>% select(-c(no_of_features, k_folds))

data <- data %>% 
  mutate(order = case_when(
    scenario == "S1" ~ 1,
    scenario == "S2" ~ 2,
    scenario == "S3" ~ 3
  ))

d <- data %>% 
  melt(id.vars = c("scenario", "model", "order"))


#  RECTANGULAR CHARTS ##############################################################################

## for one model for one scenario ###
# a <- data.frame(
#   
#   actuals = c(rep("good", t[t[, 3]=="TP", ]$value + t[t[, 3]=="FN", ]$value),
#               rep("poor", t[t[, 3]=="TN", ]$value + t[t[, 3]=="FP", ]$value)),
#   
#   predicted = c(rep("good", t[t[, 3]=="TP", ]$value),
#                 rep("poor", t[t[, 3]=="FN", ]$value),
#                 rep("poor", t[t[, 3]=="TN", ]$value),
#                 rep("good", t[t[, 3]=="FP", ]$value))
#   
# )


## for selected scenarios for all of models ###
scenario_for_chart <- c("S1", "S2", "S3")
model_for_chart <- d$model %>% unique()
t <- d %>% filter(scenario %in% scenario_for_chart, 
                  model %in% model_for_chart,
                  variable %in% c("TP", "FN", "FP", "TN"))

df <- t[rep(seq(nrow(t)), t$value),]
df <- df %>% mutate(
  actuals = ifelse(variable %in% c("TP", "FN"), "GOOD", "POOR"),
  predicted = ifelse(variable %in% c("TP", "FP"), "GOOD", "POOR")
)


tables <- vector("list")
for (i in model_for_chart){
  for(j in scenario_for_chart){
    
    temp <- df %>% filter(model == i, scenario == j)
    tables[[paste(i,j,sep="_")]] <- table(temp$actuals, temp$predicted)
    
  }
}

fig <- "RECT_plot_for_S1_S2_S3_"
png(file = paste0(PLOTS_DIR, fig, variant, ".png"),
    width = 2000, height = 1000)
par(mfrow = c(3,4))

for(j in scenario_for_chart){
  for (i in model_for_chart){

  name <- paste(i, j, sep = "_")   
  assign(name, tables[[paste(i,j,sep="_")]], envir = .GlobalEnv)
  assign(name, plot(tables[[paste(i,j,sep="_")]], col = c("black", "red"), main = name, xlab = "PREDICTED", ylab = "ACTUALS"), envir = .GlobalEnv)
  }  
}
dev.off()

library(treemap)
treemap(x,
        index="variable",
        vSize="value",
        type="index"
)

df <- d %>% filter(scenario == "S1", model == "xgboost", variable %in% c("TP", "FN", "FP", "TN")) %>% 
  mutate(real_class = ifelse(variable %in% c("TP", "FN"), "good", "poor"),
         predicted_class = ifelse(variable %in% c("TP", "FP"), "good", "poor"))
ggplot(data =  df, mapping = aes(x = real_class, y = predicted_class)) +
  geom_tile(aes(fill = value), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f", value)), vjust = 1) +
  scale_fill_gradient(low = "blue", high = "red") +
  theme_bw() + theme(legend.position = "none")

# fig <- paste("RECT", scenario_for_chart, model_fot_chart, sep = "_")
# png(file = paste0(PLOTS_DIR, fig, variant, ".png"),
#     width = 909, height = 469)
# 
# plot(tt, col = c("blue", "red"), 
#      main = paste0("actuals vs predicted for scenario ", scenario_for_chart, " using model ", model_fot_chart),
#      xlab = "predicted",
#      ylab = "actuals")
# dev.off()



# BOXPLOTS ###########################################################################################
# TPFNFPTN ####
fig <- "TPFNFPTN"
png(file = file.path(PLOTS_PATH, paste0(fig, variant, ".png")),
    width = 1000, height = 700)

d %>% filter(variable %in% c("TP", "TN", "FN", "FP")) %>% 
  ggplot(aes(x = reorder(scenario, order), y = value, fill = scenario)) + 
  geom_boxplot(alpha = 0.8) +
  facet_wrap(facets = ~variable, scale = "free") +
  scale_fill_brewer(palette="Accent") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank())
dev.off()


# FNFP ####
fig <- "FNFP"
png(file = file.path(PLOTS_PATH, paste0(fig, variant, ".png")),
    width = 1000, height = 350)

d %>% filter(variable %in% c("FN", "FP")) %>% 
  ggplot(aes(x = reorder(scenario, order), y = value, fill = scenario)) + 
  geom_boxplot(alpha = 0.8) +
  facet_wrap(facets = ~variable, scale = "free") +
  scale_fill_brewer(palette="Accent") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank())
dev.off()



# accuracy, sensitivity, specitivity, precision ####
fig <- "acc_sen_spe_pre"
png(file = file.path(PLOTS_PATH, paste0(fig, variant, ".png")),
    width = 1000, height = 700)

d %>% filter(variable %in% c("accuracy", "sensitivity_recall", "specificity", "precision")) %>% 
  ggplot(aes(x = reorder(scenario, order), y = value, fill = scenario)) + 
  geom_boxplot(alpha = 0.8) +
    facet_wrap(facets = ~variable, scale = "free") +
  scale_fill_brewer(palette="Accent") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank())
dev.off()


# detection prevalence, detection rate, F1, balanced accuracy ####
fig <- "det_F1_bal_acc"
png(file = file.path(PLOTS_PATH, paste0(fig, variant, ".png")),
    width = 1000, height = 700) 

d %>% filter(variable %in% c("detection_prevalence", "detection_rate", "F1", "balanced_accuracy")) %>% 
  ggplot(aes(x = reorder(scenario, order), y = value, fill = scenario)) + 
  geom_boxplot(alpha = 0.8) +
  facet_wrap(facets = ~variable, scale = "free") +
  scale_fill_brewer(palette="Accent") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank())
dev.off()



fig <- "all_metrics"
png(file = file.path(PLOTS_PATH, paste0(fig, variant, ".png")),
    width = 1500, height = 900) 

d %>% filter(!(variable %in% c("TP", "FN", "FP", "TN"))) %>% 
  ggplot(aes(x = reorder(scenario, order), y = value, fill = scenario)) + 
  geom_boxplot(alpha = 0.8) +
  facet_wrap(facets = ~variable, scale = "free") +
  scale_fill_brewer(palette="Accent") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title = element_blank())
dev.off()
