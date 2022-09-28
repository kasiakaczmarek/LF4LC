library(dplyr)
library(readxl)

instrument <- "PXD000323"
instrument <- "PXD000324"

data_discription <- read_excel("chromatography_data/data_discription.xlsx")
files <- list.files(path = paste0("chromatography_data/", instrument), pattern = "QC_")
files <- substr(files, 1, nchar(files)-28)

temp <- data_discription %>% filter(`PRIDE Accession` == instrument, Curated_Quality != "Not curated") %>% 
  select(Dataset) %>% pull()

# chromatograms excluded
chromatograms_excluded <- files[which(!(files %in% temp))]
chromatograms_excluded <- temp[which(!(temp %in% files))]
write(chromatograms_excluded, paste0("chromatography_data/", instrument, "/chromatograms_excluded.txt"))

# good vs. poor chromatograms
chromatograms <- data_discription %>% 
  filter(`PRIDE Accession` == instrument) %>% 
  filter(!(Dataset %in% chromatograms_excluded))

chromatograms_poor <- chromatograms %>% 
  filter(Curated_Quality == "poor") %>% 
  pull(Dataset)
write(chromatograms_poor, paste0("chromatography_data/", instrument, "/chromatograms_poor.txt"))

chromatograms_good <- chromatograms %>% 
  filter(Curated_Quality %in% c("good", "ok")) %>% 
  pull(Dataset)
write(chromatograms_good, paste0("chromatography_data/", instrument, "/chromatograms_good.txt"))
