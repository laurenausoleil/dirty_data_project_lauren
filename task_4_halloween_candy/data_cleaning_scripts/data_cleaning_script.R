# --------------
# Loading in data
# --------------

library(tidyverse)
library(readxl)
library(janitor)
library(here)

excel_sheets("raw_data/boing-boing-candy-2015.xlsx")

candy_2015 <- read_excel("raw_data/boing-boing-candy-2015.xlsx")
candy_2016 <- read_excel("raw_data/boing-boing-candy-2016.xlsx")
candy_2017 <- read_excel("raw_data/boing-boing-candy-2017.xlsx")

# --------------
# Pivot tables wider to get one row per observation
# --------------

candy_2015 <- candy_2015 %>% 
  pivot_longer(cols = 4:124, names_to = "candy", values_to = "reaction") %>% 
# drop NAs in reaction - these will not be useful for analysis
  drop_na(reaction) %>% 
# Filter out questions not about candy
  select(`How old are you?`, 
         `Are you going actually going trick or treating yourself?`, 
         candy, 
         reaction)

candy_2016 <- candy_2016 %>% 
  pivot_longer(cols = 7:106, names_to = "candy", values_to = "reaction") %>% 
  drop_na(reaction) %>% 
  select(`How old are you?`, 
          `Are you going actually going trick or treating yourself?`, 
          "Your gender:", 
          `Which country do you live in?`,
          candy, 
          reaction)

candy_2017 <- candy_2017 %>% 
  pivot_longer(cols = 7:109, names_to = "candy", values_to = "reaction", names_prefix = "Q6 \\| ") %>% 
  drop_na(reaction) %>% 
  select(`Q3: AGE`, 
         `Q1: GOING OUT?`,
         `Q2: GENDER`,
         `Q4: COUNTRY`, 
         candy,
         reaction)

# --------------
# Clean up variable names to enable join
# --------------

candy_2015 <- candy_2015 %>% 
  rename(
    "age" = "How old are you?",
    "treating" = "Are you going actually going trick or treating yourself?",
  )

candy_2016 <- candy_2016 %>% 
  rename(
    "age" = "",
    "treating" = "Are you going actually going trick or treating yourself?",
    "gender" = "Your gender:",
    "country" = "Which country do you live in?"
  )

candy_2017 <- candy_2017 %>% 
  rename(
    "age" = "Q3: AGE",
    "treating" = "Q1: GOING OUT?",
    "gender" = "Q2: GENDER",
    "country" = "Q4: COUNTRY"
  )

# --------------
# Clean up candy values
# --------------

# Remove square brackets from candy name in 2015 and 2016
candy_2015 <- candy_2015 %>% 
  mutate(
    candy = str_remove_all(candy, "\\["),
    candy = str_remove_all(candy, "\\]")
  )
candy_2016 <- candy_2016 %>% 
  mutate(
    candy = str_remove_all(candy, "\\["),
    candy = str_remove_all(candy, "\\]")
  )

# --------------
# Joining tables
# --------------

candy <- candy_2017 %>% 
  bind_rows(candy_2016) %>% 
  bind_rows(candy_2015)

# --------------
# Clean country column values
# --------------

candy %>% 
  distinct("country")

# --------------
# Write cleaned csv
# --------------

bird_data %>% 
  write_csv(here("clean_data/seabird_data_clean"))

