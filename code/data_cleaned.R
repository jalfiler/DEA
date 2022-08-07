# "Data Exploration Project - code"
# Author: Jomaica Alfiler
# Date: August 6, 2022


# Load relevant libraries
library(tidyverse)
library(tidylog)
library(vtable)
library(jtools)
library(car)
library(purrr)
library(lubridate)

# Raw data
data_path <- "data/"


# read in GOOGLE TREND files into df
files <- list.files(path = 'data', pattern = 'trends_up_to_')
print(files)

prepend <- function(fname) {
  paste('data/', fname, sep = '')
}

trends <- files %>%
  map(prepend) %>%
  map(read_csv) %>%
  reduce(rbind)

# remove incomplete rows
sch <- trends[complete.cases(trends), ]



# read in COLLEGE SCOREBOARD files into df
id_name_link <- read.csv(file = "data/id_name_link.csv")
scorecard <- read.csv(file = "data/Most+Recent+Cohorts+(Scorecard+Elements).csv")
dictionary_scorecard <- read.csv(file = "data/CollegeScorecardDataDictionary-09-08-2015.csv")

# Check if unitid is key
# check for duplicates
check_dupes <- function(data, vars) {
  data %>%
    select(vars) %>%
    duplicated() %>%
    max()
}

check_dupes(id_name_link, 'unitid')
check_dupes(id_name_link, 'schname')

# generate list of duplicates in id_name_link
id_dupes <- id_name_link[duplicated(id_name_link$schname ),]

# remove duplicates in id_name_link
id_name_link <- anti_join(id_name_link, id_dupes, by = 'schname')
check_dupes(id_name_link, 'schname')
check_dupes(id_name_link, 'unitid')

# Using scorecard data, create a new df with selected and renamed rows,
# then filters for schools where the primary awarded degree is a 4-year.
scoredata <- scorecard %>%
  filter(PREDDEG==3) %>%
  select(UNITID, INSTNM, md_earn_wne_p10.REPORTED.EARNINGS, PREDDEG) %>%
  rename(unitid = UNITID, yr10_earnings = md_earn_wne_p10.REPORTED.EARNINGS)

# Remove duplicates, convert earnings column to numeric, and remove NAs.
scoredata$yr10_earnings <- as.numeric(scoredata$yr10_earnings)
scoredata <- scoredata[complete.cases(scoredata), ]
check_dupes(scoredata, 'INSTNM')
scoredupes <- scoredata[duplicated(scoredata$INSTNM),]
scoredata <- anti_join(scoredata, scoredupes, by = 'INSTNM')
check_dupes(scoredata, 'INSTNM')

# join id data frame to trend data frame, keeping only schools with trend data.
id_to_trends <- merge(sch, id_name_link, by = "schname", all.x = TRUE, all.y = FALSE) %>%
  select(unitid, schname, keyword, monthorweek, index)

# establish keyword indexes for each school to facilitate comparisons for later
id_to_trends <- id_to_trends %>% group_by(unitid, keyword) %>%
  mutate(index = (index - mean(index)) / sd(index)) 

# break down the date variable by taking the end date of each weekly data collection,
id_to_trends <- id_to_trends %>% separate(monthorweek, c(NA, "date"), " - " ) %>%
  mutate(date = as.Date(date))
id_to_trends$date <- format(as_date(id_to_trends$date), "%Y-%m-01")
id_to_trends$date <- as_date(id_to_trends$date)

# create a monthly index score for the school
id_to_trends <- id_to_trends %>% group_by(schname, date) %>% 
  mutate(mo_index = mean(index))

# create college scorecard existence dummy variable for pre and post September 2015 for
# index analysis
id_to_trends$post_report <- if_else(id_to_trends$date >= '2015-09-01', 1, 0)
id_to_trends <- id_to_trends %>% mutate(post_report = factor(post_report))

# removes unused variables in id_to_trends and remove duplicate months
# resulting df has a standardized index for each month for each school
id_to_trends <- id_to_trends %>% select(unitid, schname, date, index, mo_index, post_report)
id_to_trends <- unique(id_to_trends)

# merge scorecard data to the trend data based on unitid
# Keeping only the scorecard data we have trend data for and removing NAs
analysis_df <- merge(id_to_trends, scoredata, by = "unitid", all.x = TRUE, all.y = FALSE) %>%
  select(unitid, INSTNM, date, index, mo_index, post_report, yr10_earnings)
analysis_df <- analysis_df[complete.cases(analysis_df), ]

# create dummy variable:  
# 0 = low earning schools 
# 1 = high earning schools
# Earning status is determined using descriptive earnings information for all schools.

# Low earnings are determined by schools that earn less than the median reported earnings.
desc_stats <- summary(scoredata$yr10_earnings)

analysis_df$earning_status <- ifelse(analysis_df$yr10_earnings >= 40700, 1, 0)
analysis_df <- analysis_df %>% mutate(earning_status = factor(earning_status))

