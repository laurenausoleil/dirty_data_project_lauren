# --------------
# Loading in data
# --------------

library(tidyverse)
library(readxl)
library(janitor)
library(here)

ship_data <- read_excel("raw_data/seabirds.xls", sheet = "Ship data by record ID")
bird_data <- read_excel("raw_data/seabirds.xls", sheet = "Bird data by record ID")
# If reading in, please ignore error message as it is not relevant to the analysis questions

# --------------
# Removing excess variables
# --------------
# Reduce to only the variables needed for the analysis questions.

bird_data <- bird_data %>% 
  select(
    "RECORD ID",
    "Species common name (taxon [AGE / SEX / PLUMAGE PHASE])",
    "Species  scientific name (taxon [AGE /SEX /  PLUMAGE PHASE])",
    "Species abbreviation",
    "COUNT"
  )

ship_data <- ship_data %>% 
  select(
    LAT,
    `RECORD ID`
  )

# --------------
# Joining tables
# --------------
# Joining the 2 variable version of ship_data to bird_data. A left join keeps all the records from bird data allowing us to answer count questions more fully. We add the column latitude to answer the question: "Which bird had the highest total count above a latitude of -30?" set in the task.

bird_data <- bird_data %>% 
  left_join(ship_data, by = "RECORD ID", keep = FALSE)


# --------------
# Cleaning variable names for best practice and readability
# --------------

bird_data <- bird_data %>% 
  clean_names() %>% 
  rename(
    "id" = "record_id",
    "common_name" = "species_common_name_taxon_age_sex_plumage_phase",
    "scientific_name" = "species_scientific_name_taxon_age_sex_plumage_phase",
    "latitude" = "lat"
  )

# --------------
# Removing subdivisions from species names
# --------------

subdivision_pattern <- c("AD", "SUBAD", "IMM", "JUV", " F ", " M ", "DRK", "INT", "LGHT", "WHITE")

bird_data <- bird_data %>%
# Remove all subdivision information from name fields plus unidentified and sensu lato (Latin for broadly speaking) which are not relevant to our analysis.
  mutate(common_name = str_remove_all(common_name, "AD"),
         common_name = str_remove_all(common_name, "SUBAD"),
         common_name = str_remove_all(common_name, "IMM"),
         common_name = str_remove_all(common_name, "JUV"),
         common_name = str_remove_all(common_name, " F "),
         common_name = str_remove_all(common_name, " M "),
         common_name = str_remove_all(common_name, "DRK"),
         common_name = str_remove_all(common_name, "INT"),
         common_name = str_remove_all(common_name, "LIGHT"),
         common_name = str_remove_all(common_name, "WHITE"),
         common_name = str_remove_all(common_name, "\\([Uu]nidentified\\)"),
         common_name = str_remove_all(common_name, "[Ss]ensu lato"),
         scientific_name = str_remove_all(common_name, "AD"),
         scientific_name = str_remove_all(common_name, "SUBAD"),
         scientific_name = str_remove_all(common_name, "IMM"),
         scientific_name = str_remove_all(common_name, "JUV"),
         scientific_name = str_remove_all(common_name, " F "),
         scientific_name = str_remove_all(common_name, " M "),
         scientific_name = str_remove_all(common_name, "DRK"),
         scientific_name = str_remove_all(common_name, "INT"),
         scientific_name = str_remove_all(common_name, "LIGHT"),
         scientific_name = str_remove_all(common_name, "WHITE"),
         scientific_name = str_remove_all(common_name, "\\([Uu]nidentified\\)"),
         scientific_name = str_remove_all(common_name, "[Ss]ensu lato")
         ) %>% 
  # Remove everything after the slash in scientific name
  mutate(scientific_name = str_remove_all(scientific_name, "\\/.*"))


# --------------
# Writing cleaned csv
# --------------

bird_data %>% 
  write_csv(here("clean_data/seabird_data_clean"))
