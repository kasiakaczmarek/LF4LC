rm(list = ls())

# config ------------------------------------------------------
library(ggplot2)
library(stringr)
library(tidyverse)

name_of_run <- "20220928"

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")
classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)

variant <- "_for_full_results"
# variant <- "_for_validation_on323"
# variant <- "_for_validation_on324"


if(variant == "_for_full_results"){
        file <- list.files(DATA_WIDE_PATH, pattern = ".*complete_datasetnormal.*\\.RDS$", full.names=TRUE)
} else if(variant == "_for_validation_on323"){
        file <- list.files(DATA_WIDE_PATH, pattern = ".*323normal.*\\.RDS$", full.names=TRUE)
} else {
        file <- list.files(DATA_WIDE_PATH, pattern = ".*324normal.*\\.RDS$", full.names=TRUE)
}

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
data <- data %>% select(id, label, rfe$variable)

rfe$name_in_data <- rfe$variable
rfe$variable <- gsub('summary_segments_summary_','segments_', rfe$variable)
rfe$variable <- gsub('summary_segments_','segments_', rfe$variable)
rfe$variable <- gsub('protoforms_extended_','', rfe$variable)
rfe$variable <- gsub('protoforms_short_','', rfe$variable)
rfe$variable <- gsub('_',' ', rfe$variable)


Replaces <-
        data.frame(
                from = c(
                        "summary_segments_summary_",
                        "summary_segments_",
                        "protoforms_extended_",
                        "_most_",
                        "treds",
                        "protoforms_short_",
                        "_"
                ),
                to = c("segments_", "segments_", "", "_most_", "_trends_", "", " ")
        )

# Replace patterns and return full data frame
selected_LS2 <-
        DataCombine::FindReplace(
                data = rfe,
                Var = "variable",
                replaceData = Replaces,
                from = "from",
                to = "to",
                exact = FALSE
        )

data_names <- data.frame(t(t(colnames(data))))
data_names2 <- DataCombine::FindReplace(data = data_names, Var = "t.t.colnames.data...", replaceData = Replaces,
                                        from = "from", to = "to", exact = FALSE)

colnames(data) <- data_names2$t.t.colnames.data...


# S1
s1_data <- data %>% select(id, label, rfe$variable[rfe$scenario_id == "S1"])
s1_data_long <- pivot_longer(s1_data, !c(id, label), names_to = "parameter", values_to = "values")

pdf(paste0("plots/", name_of_run , "/boxplots_S1_val", 
           ifelse(variant == "_for_full_results", "_on_complete_dataset.pdf", "_on_323.pdf")),
    width = 13, height = 8)
ggplot(s1_data_long, aes(x = values, y = parameter, fill = label))+
        geom_boxplot()+
        labs(
                title = paste0("S1: validation on ", 
                               ifelse(variant == "_for_full_results", "complete dataset", "323 instrument")),
                x = "degree of true",
                y = "parameter selected in scenario")
dev.off()

# S2
s2_data <- data %>% select(id, label, rfe$variable[rfe$scenario_id == "S2"])
s2_data_long <- pivot_longer(s2_data, !c(id, label), names_to = "parameter", values_to = "values")

pdf(paste0("plots/", name_of_run , "/boxplots_S2_val", 
           ifelse(variant == "_for_full_results", "_on_complete_dataset.pdf", "_on_323.pdf")),
    width = 13, height = 8)
ggplot(s2_data_long, aes(x = values, y = parameter, fill = label))+
        geom_boxplot()+
        labs(
                title = paste0("S2: validation on ", 
                               ifelse(variant == "_for_full_results", "complete dataset", "323 instrument")),
                x = "degree of true",
                y = "parameter selected in scenario")
dev.off()


#S3
s3_data <- data %>% select(id, label, rfe$variable[rfe$scenario_id == "S3"])
s3_data_long <- pivot_longer(s3_data, !c(id, label), names_to = "parameter", values_to = "values")

pdf(paste0("plots/", name_of_run , "/boxplots_S3_val", 
           ifelse(variant == "_for_full_results", "_on_complete_dataset.pdf", "_on_323.pdf")),
    width = 13, height = 8)
ggplot(s3_data_long, aes(x = values, y = parameter, fill = label))+
        geom_boxplot()+
        labs(
                title = paste0("S3: validation on ", 
                               ifelse(variant == "_for_full_results", "complete dataset", "323 instrument")),
                x = "degree of true",
                y = "parameter selected in scenario")
dev.off()



#every boxplot separately
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

