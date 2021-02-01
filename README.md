# Hallowe'en Candy 2015-2017

##Project 

### Aims

A CodeClan homework project exploring ratings of Hallowe'en candy or treats collected from users of the site boingboing.net between 2015 and 2017.

* To clean the data to tidy standards
* To merge 2015, 2016 and 2017 results
* To conduct analysis on candy reviews from 2015-2017

### Structure

An R.proj within a GitHub repository https://github.com/laurenausoleil/dirty\_data_project\_lauren

1. data\_cleaning\_scripts
	* Cleans and merges 2015-2017 data
	* Removes information not needed for the analysis
	* Assigns NA to unclear variables (see Assumptions below)
2. documentation\_and\_analysis/
	* Answers analysis questions on cleaned data
	* A copy of the project brief

## Data

### Availability

The data is available from: [https://www.scq.ubc.ca/so-much-candy-data-seriously/](https://www.scq.ubc.ca/so-much-candy-data-seriously/)

### Parameters

Survey respondents have an average age of 38.
12% of respondents are female, 23% male, 0.5% are other genders and 63% did not povide a gender.
Respondents are from predominantly English speaking countries with a significant proportion (32%) identified as USA based.

The survey was published with a free text field for both country and age, so assumptions have been made for analysis conducted on these variables.

### Assumptions

For country, I have identified variations and misspellings of USA including 'Murica, United Statea, us and assumed 'endland' to be a misspelling of England. All recognisable countries have been retained in the cleaned data set, with any hard to identify countries being recoded as NA.

For age, I used R's built in as.numeric() function to translate text to a numeric value. It is possible that some ages entered in different formats were NA'd in this process. I have also filtered the results to include only realistic ages between 0 and 120

## Analysis

##### Q1: What is the total number of candy ratings given across the three years.
**772354** ratings of Hallowe'en treats across the three years.
Treats rated include non-candy snacks and gifts.

<details>
  <summary>Code</summary>

```{r}
# Count number of values as I have dropped non-treat questions and NA reaction
candy %>% 
  summarise(num_candy_ratings = n())
```  
 
</details>

##### Q2: What was the average age of people who are going out trick or treating and the average age of people not going trick or treating?
Those **going out** trick or treating have an average age of **35** years.       
Those **staying in** have an average age of **39** years.  

The average age for the dataset is 38, which is not exactly the age we expect of trick and treaters and candy eaters.

<details>
  <summary>Code</summary>

```{r}
candy %>% 
  group_by(treating) %>% 
  summarise(average_age = mean(age, na.rm = TRUE))

candy %>% 
  summarise(average_age = mean(age, na.rm = TRUE))
``` 
 
</details>

##### Q3: For each of joy, despair and meh, which candy bar received the most of these ratings?

Most often rated joy: **'any full size candy bar'**  
Most often rated despair: **'broken glow stick'**   
Most often rated meh: **'lollipops'**

Our respondents are not very discriminating; they rated 'any full size candy bar' as joy the most often, 7589 times.
A 'broken glow stick' receieved the most despair reactions, 7905 times.
'Lollipops' are the least evocative item, receiving 1570 meh ratings.

<details>
  <summary>Code</summary>

```{r}
candy %>%
  group_by(reaction, candy) %>%
  summarise(rating_count = n()) %>%
  group_by(reaction) %>%
  slice_max(rating_count)
``` 
 
</details>

##### Q4: How many people rated Starburst as despair?

**1990** people rated Starburst with a despair reaction.

<details>
  <summary>Code</summary>

```{r}
candy %>% 
  filter(candy == "Starburst" &
         reaction == "DESPAIR") %>% 
  summarise(num_rating_starburst_as_despair = n())
```
 
</details>

##### Q6: What was the most popular candy bar by the rating system for each gender in the dataset?
**Female**: 'Any full-sized candy bar'   
**Male**: 'Any full-sized candy bar'   
**Other**: 'Any full-sized candy bar'   
**NA**: 'Any full-sized candy bar'

<details>
  <summary>Code</summary>

```{r}
rated_candy <- candy %>% 
  mutate(
    numeric_rating = case_when(
      reaction == "JOY" ~ 1,
      reaction == "DESPAIR" ~ -1,
      reaction == "MEH" ~ 0
    )
  )
```

```{r}
rated_candy %>% 
  group_by(gender, candy) %>% 
  # Get a rating for each candy bar by each gender, name this "score"
  summarise(score = sum(numeric_rating), avg_rating = mean(numeric_rating)) %>% 
  # Group by gender to get a table containing all genders as rows
  group_by(gender) %>% 
  # Slice to return only the highest result
  slice_max(score)
```
 
</details>

##### Q7: What was the most popular candy bar in each year?
**2015**: 'Any full-sized candy bar'   
**2016**: 'Any full-sized candy bar'   
**2017**: 'Any full-sized candy bar'

<details>
  <summary>Code</summary>

```{r}
rated_candy %>% 
  # Mutate all countries except USA, Canada and UK to NA (best way I can find to group other countries and NA together)
  mutate(country = 
          ifelse(country == "USA" | country == "UK" | country == "Canada",
          country,
          NA
          )
  ) %>% 
  # find the score for each candy by country
  group_by(country, candy) %>% 
  summarise(score = sum(numeric_rating), avg_rating = mean(numeric_rating)) %>% 
  # Group by country to return a table showing rank by country
  group_by(country) %>% 
  slice_max(score)
```
 
</details>


##### Q8: What was the most popular candy bar by this rating for people in US, Canada, UK and all other countries?
**US**: 'Any full-sized candy bar'  
**Canada**: 'Any full-sized candy bar'  
**UK**: 'Cash, or other forms of legal tender'  
**All other countries**: 'Any full-sized candy bar'

People in the UK were the only group analysed who rated anything higher than 'Any full-size candy bar' as their highest.   
I performed some analysis to see whether UK respondents had a higher average age than other countries, but found that UK respondents had the lowest average age.   

Average age **USA**: 42    
Average age **UK**: 38   
Average age **Canada**: 39   

<details>
  <summary>Code</summary>

```{r}
rated_candy %>% 
  # Mutate all countries except USA, Canada and UK to NA (best way I can find to group other countries and NA together)
  mutate(country = 
          ifelse(country == "USA" | country == "UK" | country == "Canada",
          country,
          NA
          )
  ) %>% 
  # find the score for each candy by country
  group_by(country, candy) %>% 
  summarise(score = sum(numeric_rating), avg_rating = mean(numeric_rating)) %>% 
  # Group by country to return a table showing rank by country
  group_by(country) %>% 
  slice_max(score)
```

```{r}
rated_candy %>% 
  # Mutate all countries except USA, Canada and UK to NA (best way I can find to group other countries and NA together)
  mutate(country = 
          ifelse(country == "USA" | country == "UK" | country == "Canada",
          country,
          NA
          )
  ) %>% 
  # find the score for each candy by country
  group_by(country, candy) %>% 
  summarise(score = sum(numeric_rating), avg_rating = mean(numeric_rating)) %>% 
  # Group by country to return a table showing rank by country
  group_by(country) %>% 
  slice_max(score)
```
```{r}
candy %>% 
  select(country, age) %>% 
  # Mutate all countries except USA, Canada and UK to NA (best way I can find to group other countries and NA together)
  mutate(country = 
          ifelse(country == "USA" | country == "UK" | country == "Canada",
          country,
          NA
          )
  ) %>% 
  group_by(country) %>% 
  summarise(avg_age = mean(age, na.rm = TRUE))
```
 
</details>

