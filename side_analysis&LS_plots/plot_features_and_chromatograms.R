rm(list = ls())

library(dplyr)
library(ggplot2)

# source("Chromatography_LS_preparation/config.R")

name_of_run <- "20220928"

DATA_WIDE_PATH <- file.path("R_classification_module", "data_prepared")
classification_dir <- "R_classification_module"
output_dir <- "output"
CLASSIFICATION_OUTPUT_PATH <- file.path(classification_dir, output_dir, name_of_run)


file <- list.files(DATA_WIDE_PATH, pattern = ".*complete_datasetnormal.*\\.RDS$", full.names=TRUE)

OUTPUT_PATH <- file.path("side_analysis&LS_plots", name_of_run, variant)
dir.create(OUTPUT_PATH)

data <- readRDS(file) 
data <- data %>% mutate(label = ifelse(label == 0, "good", "poor"))


if(variant == "_for_full_results"){
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = ".*rfe_selection_on_complete.*\\.csv$", full.names=TRUE)
} else if(variant == "_for_validation_on323"){
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = "rfe_selection_on_324.csv", full.names=TRUE)
} else {
        file <- list.files(CLASSIFICATION_OUTPUT_PATH, pattern = "rfe_selection_on_323.csv", full.names=TRUE)
}

selected_LS <- read.csv(file) 
selected_LS$variable <- as.factor(selected_LS$variable)

# improve linguistics
# Create replacements data frame
Replaces <-
        data.frame(
                from = c(
                        "summary_segments_summary_",
                        "summary_segments_",
                        "protoforms_extended_",
                        "_most_",
                        "treds",
                        "protoforms_short_"
                ),
                to = c("segments_", "segments_", "", "_most_", "trends", "")
        )

# Replace patterns and return full data frame
selected_LS2 <-
        DataCombine::FindReplace(
                data = selected_LS,
                Var = "variable",
                replaceData = Replaces,
                from = "from",
                to = "to",
                exact = FALSE
        )

selected_LS2
feature_set <- selected_LS2

data_names <- data.frame(t(t(colnames(data))))
data_names2 <- DataCombine::FindReplace(data = data_names, Var = "t.t.colnames.data...", replaceData = Replaces,
                            from = "from", to = "to", exact = FALSE)

colnames(data) <- data_names2$t.t.colnames.data...

# names of explanatory variables         
variables <- colnames(data[3:length(data)])
        

# plot density plots -------------------------------------------------------------------------
histograms_lst <- list()
for(i in seq(1:length(variables))){
        # i<-1
        name <- variables[i]
        df <- cbind(data[variables[i]], data["label"])
        
        h <- ggplot(df, aes(get(variables[i]), fill = label)) + geom_density(alpha = 0.2) +
                xlab(name)
        histograms_lst[[i]] <- h
}

pdf(file.path("side_analysis&LS_plots/20220928", "relative_histograms.pdf"), width = 16, height = 8)
for(i in seq(1:length(variables))){
        print(histograms_lst[[i]])
}
dev.off()




# plot bar plots ------------------------------------------------------------------------------

chromatograms <- read.csv("side_analysis&LS_plots/chromatograms_for_barplots.csv")

chromatograms$id %in% data$id

dir.create(file.path(OUTPUT_PATH, "LS_features_dot"))
for(i in chromatograms$id){

        # i = chromatograms$id[1]
        df_plot <- data %>%
                filter(id == i) 
        
        df_plot_ls <- df_plot %>%
                select(feature_set$variable) %>%
                select(contains("Most"))


        pdf(file.path(OUTPUT_PATH, "LS_features_dot", paste0("barplot_", df_plot$label, "_", i, ".pdf")), 
            width = 12, height=10)
        par(mar = c(5, 25, 4, 4) + 0.1)
        barplot(t(df_plot_ls)[,1], 
                names.arg = colnames(df_plot_ls),
                xlab="degree of truth",
                horiz = TRUE,
                main = paste0(df_plot$label, "_", i),
                las = 1) 
        dev.off()

}
