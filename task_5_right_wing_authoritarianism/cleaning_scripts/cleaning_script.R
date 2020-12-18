library(tidyverse)
library(janitor)
library(here)

rwa <- read_csv(here("raw_data/rwa.csv"))%>% 
  select(-screenw, -screenh, -Q1, -Q2, -E1:E22, -introelapse, -testelapse, -surveyelapse, -TIPI1:TIPI10, -VCL1:VCL16, -urban)
