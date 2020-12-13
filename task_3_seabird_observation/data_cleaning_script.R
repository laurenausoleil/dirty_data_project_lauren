library(tidyverse)
library(readxl)

excel_sheets("raw_data/seabirds.xls")

ship_data <- read_excel("raw_data/seabirds.xls", sheet = "Ship data by record ID")
bird_data <- read_excel("raw_data/seabirds.xls", sheet = "Bird data by record ID")
# Expecting logical in I21756 / R21756C9: got 'M'

ship_codes <- read_excel("raw_data/seabirds.xls", sheet = "Ship data codes")
bird_codes <- read_excel("raw_data/seabirds.xls", sheet = "Bird data codes")
