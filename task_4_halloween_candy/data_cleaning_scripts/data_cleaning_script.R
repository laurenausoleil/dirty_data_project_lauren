# --------------
# Loading in data
# --------------

library(tidyverse)
library(readxl)
library(janitor)
library(here)

candy_2015 <- read_excel("task_4_halloween_candy/raw_data/boing-boing-candy-2015.xlsx")
candy_2016 <- read_excel("task_4_halloween_candy/raw_data/boing-boing-candy-2016.xlsx")
candy_2017 <- read_excel("task_4_halloween_candy/raw_data/boing-boing-candy-2017.xlsx")

# --------------
# Pivot tables wider to get one row per observation
# --------------
# 2015
candy_2015 <- candy_2015 %>% 
  # Select columns to exclude non-candy questions
  pivot_longer(cols = 4:124, names_to = "candy", values_to = "reaction") %>% 
  # drop NAs in reaction - these will not be useful for analysis
  drop_na(reaction) %>% 
  # check all reactions as expected - helps to filter out non-candy questions
  filter(reaction == "JOY" | reaction == "DESPAIR" | reaction == "MEH") %>% 
  # hard code remove questions that slipped the net!
  filter(candy != "Please list any items not included above that give you JOY.") %>% 
  filter(candy != "Please list any items not included above that give you DESPAIR.") %>%
  # Filter out unecessary questions
  select(`How old are you?`, 
         `Are you going actually going trick or treating yourself?`, 
         candy, 
         reaction)

# 2016
candy_2016 <- candy_2016 %>% 
  pivot_longer(cols = 7:106, names_to = "candy", values_to = "reaction") %>% 
  drop_na(reaction) %>% 
  select(`How old are you?`, 
         `Are you going actually going trick or treating yourself?`, 
         "Your gender:", 
         `Which country do you live in?`,
         candy, 
         reaction)

# 2017
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
# Clean up variable names and add year column to enable join
# --------------
# 2015
candy_2015 <- candy_2015 %>% 
  rename(
    "age" = "How old are you?",
    "treating" = "Are you going actually going trick or treating yourself?",
  ) %>% 
  mutate(year = 2015)

# 2016
candy_2016 <- candy_2016 %>% 
  rename(
    "age" = "How old are you?",
    "treating" = "Are you going actually going trick or treating yourself?",
    "gender" = "Your gender:",
    "country" = "Which country do you live in?"
  ) %>% 
  mutate(year = 2016)

# 2017
candy_2017 <- candy_2017 %>% 
  rename(
    "age" = "Q3: AGE",
    "treating" = "Q1: GOING OUT?",
    "gender" = "Q2: GENDER",
    "country" = "Q4: COUNTRY"
  ) %>% 
  mutate(year = 2017)

# --------------
# Clean up candy values to enable join
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
  bind_rows(candy_2015) %>% 
  # convert age to numeric to enable analysis
  mutate(age = as.numeric(age))

# --------------
# Clean country column values
# --------------
candy <- candy %>% 
# Edit to USA
  mutate(
    # United States and misspellings of united states
    country = if_else(
    str_detect(country, "[Uu][a-zA-Z]+ [Ss][a-zA-Z]+"), "USA", country),
    # USA, us, usa, US, etc.
    country = if_else(
      str_detect(country, "^[Uu][Ss][a-zA-Z:punct:]*"), "USA", country),
    # america, murica, Amerca
    country = if_else(
      str_detect(country, "[Mm].+ca"), "USA", country),
    # U.S.A, u.s.
    country = if_else(
      str_detect(country, "[Uu]\\.[Ss]"), "USA", country),
    # u s a
    country = if_else(
      str_detect(country, "[Uu] [Ss]"), "USA", country),
    # murrika
    # canada
    country = if_else(
      str_detect(country, "[Cc][Aa][Nn][Aa][Dd][Aa]"), "Canada", country),
    country = if_else(
      str_detect(country, "Canada`"), "Canada", country),
    # United Kingdom and misspellings
    country = if_else(
      str_detect(country, "[Uu][a-zA-Z]+ [Kk][a-zA-Z]+"), "UK", country),
    # UK, uk, etc.
    country = if_else(
      str_detect(country, "^[Uu][Kk][a-zA-Z:punct:]*"), "UK", country),
    # U.K, u.k.
    country = if_else(
      str_detect(country, "[Uu]\\.[Kk]"), "UK", country),
    # England and endland
    country = if_else(
      str_detect(country, "[Ee]n[a-z]land"), "UK", country)
  ) 

# --------------
# NA any excess/uncleaned names
# --------------
# Identify clean countries
clean_country_list <- c(
  "USA", "Canada", "France", "UK", "UAE", "Mexico", "The Netherlands", "Costa Rica", "Greece", "Korea", "Australia", "Japan", "Iceland", "Denmark", "Switzerland", "South Korea", "Germany", "Singapore", "Taiwan", "China", "Spain", "Ireland", "South africa", "belgium", "croatia", "Portugal", "Panama", "hungary", "Austria", "New Zealand", "Brasil", "Philippines", "sweden", "Finland", 'kenya'
)

# NA countries outwith clean list
candy <- candy %>% 
  mutate(country = ifelse(
    (country %in% clean_country_list), country, NA)
  )

# NA rather not say gender (this is the same as not providing an answer)
candy <- candy %>% 
  mutate(gender = na_if(gender, "I'd rather not say")) %>%
# NA unlikely ages
  mutate(age = 
           ifelse(age < 0 | age > 120, NA, age)
  )

# --------------
# Write cleaned csv
# --------------
candy %>% 
  write_csv(here("clean_data/clean_candy_2015_to_2017.csv"))
