rm(list = ls())

# config ---------------------------------------------------------------------------------------
library(tidyverse)

name_of_run <- "20220928"

instrument <- "PXD000323"
# instrument <- "PXD000324"

PYTHON_RESULTS_PATH <- file.path("python_LS_module", "output")
DATA_PREPARED_OUTPUT_PATH <- file.path("R_classification_module", "data_prepared")


# read data from PYTHON_RESULTS ------------------------------------------------------------

acf <- read.csv(file.path(PYTHON_RESULTS_PATH, instrument, name_of_run, "_acf.csv"), sep = ";")
names(which(colSums(is.na(protoforms)) > 0))

# throw out duplicate observations
if(nrow(acf) != nrow(unique(acf))){
  acf <- acf %>% group_by(name) %>% 
    mutate(n = row_number()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    select(-n)
} else{print("no duplicates")}

acf$name %>% unique() %>% length()



summary_segments <- read.csv(file.path(PYTHON_RESULTS_PATH, instrument, name_of_run, "_summary_segments.csv"), sep = ";")
names(which(colSums(is.na(summary_segments)) > 0))

if(nrow(summary_segments) != nrow(unique(summary_segments))){
  summary_segments <- summary_segments %>% group_by(id, statistic) %>% 
    mutate(n = row_number()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    select(-n)
} else{print("no duplicates")}

summary_segments$id %>% unique() %>% length()


protoforms <- read.csv(file.path(PYTHON_RESULTS_PATH, instrument, name_of_run, "_protoforms.csv"), sep = ";")
names(which(colSums(is.na(protoforms)) > 0))

if(nrow(protoforms) != nrow(unique(protoforms))){
  protoforms <- protoforms %>% group_by(id, protoform) %>% 
    mutate(n = row_number()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    select(-n)
} else{print("no duplicates")}

protoforms$id %>% unique() %>% length()


border_segments <- read.csv(file.path(PYTHON_RESULTS_PATH, instrument, name_of_run, "_border_segments.csv"), sep = ";")
names(which(colSums(is.na(protoforms)) > 0))

if(nrow(border_segments) != nrow(unique(border_segments))){
  border_segments <- border_segments %>% group_by(id, type) %>% 
    mutate(n = row_number()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    select(-n)
} else{print("no duplicates")}

border_segments$id %>% unique() %>% length()



### data processing --------------------------------------------------------------------------------

# 1. _acf.csv correlation coefficient

acf <- acf %>% select(id = name, label,
                      acf_lag1 = lag1, acf_lag2 = lag2, acf_lag3 = lag3)



# 2. _summary_segments.csv 6x6

sum_seg_values_cols <- colnames(summary_segments %>% select(-id, -statistic, -label))
summary_segments$statistic <- gsub('25%', 'q25', summary_segments$statistic)
summary_segments$statistic <- gsub('50%', 'q50', summary_segments$statistic)
summary_segments$statistic <- gsub('75%', 'q75', summary_segments$statistic)

summary_segments <- summary_segments %>% pivot_wider(id_cols = id,
                                                      names_from = statistic,
                                                      values_from = all_of(sum_seg_values_cols),
                                                      names_glue = "summary_segments_{.value}_{statistic}")


# 3. _protoforms.csv linquistic features

protoforms$protoform <- gsub(',', '', protoforms$protoform)
protoforms$protoform <- gsub(' ', '_', protoforms$protoform)

# protoforms %>% group_by(id) %>% summarise(count = n()) %>% View() #ok

protoforms <- protoforms %>% 
  mutate(protoform = ifelse(Type == 1, paste0("short_", protoform), paste0("extended_", protoform)))

protoforms <- protoforms %>% pivot_wider(id_cols = id,
                                          names_from = protoform,
                                          values_from = DoT,
                                          names_glue = "protoforms_{protoform}") 



# 4. _border_segments.csv summaries for first and last segment
# border_segments %>% group_by(id) %>% summarise(count = n()) %>% View()

border_segments$time <- gsub('\\[', '', border_segments$time)
border_segments$time <- gsub('\\]', '', border_segments$time)
border_segments$time <- as.numeric(border_segments$time)

bor_seg_values_cols <- colnames(border_segments %>% select(-id, -type, -label))
border_segments <- border_segments %>% pivot_wider(id_cols = id,
                                                    names_from = type,
                                                    values_from = all_of(bor_seg_values_cols),
                                                    names_glue = "border_segments_{type}_{.value}")


# 5. combine data_wide
data_wide_complete <- acf %>% 
  left_join(summary_segments, by = c("id")) %>% 
  left_join(protoforms, by = c("id")) %>% 
  left_join(border_segments, by = c("id"))

data_wide_complete <- data_wide_complete[complete.cases(data_wide_complete), ]

if(instrument == "PXD000323"){
  data_wide_complete323 <- data_wide_complete %>% mutate(instrument = 323) %>% 
    select(instrument, id, label, everything())
  
  saveRDS(data_wide_complete323, file = file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete323.RDS"))
} else {
  data_wide_complete324 <- data_wide_complete %>% mutate(instrument = 324) %>% 
    select(instrument, id, label, everything())
  
  saveRDS(data_wide_complete324, file = file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete324.RDS"))
}

# TODO change the instrument and run above code once again

colnames(data_wide_complete323) %in% colnames(data_wide_complete324)
colnames(data_wide_complete324) %in% colnames(data_wide_complete323)


data_wide_complete <- data_wide_complete323 %>% rbind(data_wide_complete324)
saveRDS(data_wide_complete, file = file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete.RDS"))



# data normalization -----------------
rm(list = ls())
DATA_PREPARED_OUTPUT_PATH <- file.path("R_classification_module", "data_prepared")

# instrument <- "324"
# instrument <- "323"
instrument <- "complete_dataset"

# load data_wide
if(instrument == "complete_dataset"){
  data_wide <- readRDS(file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete.RDS"))
} else if(instrument == "324"){
  data_wide <- readRDS(file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete324.RDS"))
} else data_wide <- readRDS(file.path(DATA_PREPARED_OUTPUT_PATH, "data_wide_complete323.RDS"))

# 0 = good, 1 = poor
data_wide <- data.frame(data_wide) %>% 
  mutate(label = as.numeric(as.factor(data_wide$label)) - 1) %>% 
  select(-contains("std")) %>% select(-contains("acf")) %>% select(-instrument)

# df <- data_wide %>% select(id, label)

data_wide <- data_wide %>%
  mutate_at(vars(starts_with("acf"), starts_with("summary"), starts_with("protoforms"), starts_with("border")), 
            funs((. - min(., na.rm = T))/(max(., na.rm = T) - min(., na.rm = T)))) #Applying the function to vars that starts with "x"

x <- data_wide[3:174] %>% summarise_all(list(sum)) %>% t() %>%
  as.data.frame() %>% mutate(name = rownames(.)) %>% filter(is.nan(V1)) %>% pull(name)
data_wide <- data_wide %>% select(-x)

saveRDS(data_wide, file.path(DATA_PREPARED_OUTPUT_PATH, paste0("data_wide", instrument, "normalized01.RDS")))
