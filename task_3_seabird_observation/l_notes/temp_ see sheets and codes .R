
library(tidyverse)
library(readxl)
library(janitor)
library(here)

excel_sheets("raw_data/seabirds.xls")

ship_data <- read_excel("raw_data/seabirds.xls", sheet = "Ship data by record ID")
bird_data <- read_excel("raw_data/seabirds.xls", sheet = "Bird data by record ID")
bird_codes <- read_excel("raw_data/seabirds.xls", sheet = "Bird data codes")


# common_name: Species (or species grouping if unable to differentiate) common name, subdivided by
# age: AD, SUBAD, IMM, JUV 
# sex: F, M
# plumage phase: DRK, INT, LGHT, WHITE
