rm(list = ls())

# config ------------------------------------------------------
library(dplyr)
library(ggplot2)
library(stringr)

name_of_run <- "20220928"

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")
classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)

# variant <- "_for_full_results"
variant <- "_for_validation_on323"
# variant <- "_for_validation_on324"


if(variant == "_for_full_results"){
        file <- list.files(DATA_WIDE_PATH, pattern = ".*complete_datasetnormal.*\\.RDS$", full.names=TRUE)
} else if(variant == "_for_validation_on323"){
        file <- list.files(DATA_WIDE_PATH, pattern = ".*323normal.*\\.RDS$", full.names=TRUE)
} else {
        file <- list.files(DATA_WIDE_PATH, pattern = ".*324normal.*\\.RDS$", full.names=TRUE)
}

OUTPUT_PATH <- file.path("side_analysis&LS_plots", name_of_run, variant)
dir.create(OUTPUT_PATH)

data <- readRDS(file) 
data <- data %>% mutate(label = ifelse(label == 0, "good", "poor"))


if(variant == "_for_full_results"){
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = ".*rfe_selection_on_complete.*\\.csv$", full.names=TRUE)
} else if(variant == "_for_validation_on323"){
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = "rfe_selection_on_323.csv", full.names=TRUE)
} else {
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = "rfe_selection_on_324.csv", full.names=TRUE)
}

rfe <- read.csv(file) 
rfe$name_in_data <- rfe$variable
rfe$variable <- gsub('summary_intensity','intensity', rfe$variable)
rfe$variable <- gsub('protoforms_extended_','', rfe$variable)
rfe$variable <- gsub('protoforms_short','', rfe$variable)
rfe$variable <- gsub('_',' ', rfe$variable)

s1 <- rfe %>% filter(scenario_id == "S1") %>% pull(variable)
s2 <- rfe %>% filter(scenario_id == "S2") %>% pull(variable)

s1_name <- rfe %>% filter(scenario_id == "S1") %>% pull(name_in_data)
s2_name <- rfe %>% filter(scenario_id == "S2") %>% pull(name_in_data)


plot_list = list()
for (i in 1:10) {
        p <- ggplot(data, aes(
                x = label,
                y = !!sym(s1_name[i]),
                color = label
        )) +
                geom_boxplot() +
                labs(
                        title = s1[i],
                        x = "label",
                        y = "degree o f true"
                ) +
                theme(legend.position = "none")
        plot_list[[i]] <- p
}
for (i in 1:10) {
        file_name <- file.path(OUTPUT_PATH, paste0("S1_boxplot_", s1_name[i], ".png"))
        png(file = file_name)
        print(plot_list[[i]])
        dev.off()
}



plot_list = list()
for (i in 1:10) {
        p <- ggplot(data, aes(
                x = label,
                y = !!sym(s1_name[i]),
                color = label
        )) +
                geom_boxplot() +
                labs(
                        title = s2[i],
                        x = "label",
                        y = "degree o f true"
                ) +
                theme(legend.position = "none")
        plot_list[[i]] <- p
}
for (i in 1:10) {
        file_name <- file.path(OUTPUT_PATH, paste0("S2_boxplot_", s2_name[i], ".png"))
        png(file = file_name)
        print(plot_list[[i]])
        dev.off()
}