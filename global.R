# Import libraries ----------------------------------------------------------
library(data.table)
library(lubridate)
library(plotly)
library(ggthemes)
library(hrbrthemes)
library(ggrepel)
library(ggsci)
library(gganimate)
library(tidyverse)
library(zoo)
library(kableExtra)
library(car) # leveneTest
library(rstatix) # t_test
library(caret)
library(Metrics) # calculate MAE
library(doSNOW)
library(shiny)
library(shinyBS) # pop-over KPIs
library(shinydashboard)
library(shinyWidgets)
library(randomForest)

# import all files that start with 20 and have 4 characters (unsure if I will be practicing from year 2100 onward)
raw_data <- list.files(pattern = "^20..", recursive = TRUE)%>%
  lapply(read_csv)%>%
  bind_rows()

# R doesn't have an innate not in function
`%notin%` <- Negate(`%in%`)

raw_data <- raw_data%>%
  # remove unnecessary columns and rename some to make the syntax easier to use
  select(-User, -Email, -Billable, -`Amount ()`, -Description, -Task, -Tags)%>%
  rename(Date_Start = `Start date`,
         Date_End = `End date`,
         Genre = Client,
         Time_Start = `Start time`,
         Time_End = `End time`)%>%
  # restructure the columns/add new ones
  mutate(Date_Start = as_date(Date_Start, format = "%d/%m/%Y"),
         Date_End = as_date(Date_End, format = "%d/%m/%Y"),
         # understand if the data was estimated or tracked
         Source = ifelse(Date_Start < as.Date("2018/11/01"), "Estimated", "Tracked"),
         # extract piece related variables
         Project = as.factor(ifelse(is.na(Project), "General", Project)),
         Completed = as.factor(ifelse(str_detect(Project, "WIP - "), "No", "Yes")),
         Project = str_replace(Project, "WIP - ", ""),
         Genre = as.factor(ifelse(is.na(Genre), "Not applicable", Genre)),
         Composer = word(Project, 1, sep = "\\-"),
         Composer = as.factor(ifelse(Project %in% c("General", "Sightreading", "Technique"), "Not applicable", Composer)),
         Duration = as.numeric(sub(":.*", "", Duration)),
         # date features
         Week_Start = floor_date(as.Date(Date_Start, "%d/%m/%Y"), unit="week")+1,
         Month = as.factor(month(Date_Start)),
         Month_Name = as.factor(month(Date_Start, label = TRUE)),
         Month_Start = floor_date(Date_Start, "month"),
         Month_Year = as.factor(as.yearmon(Date_Start)),
         Month_format = str_replace(Month_Year, " 20", "\n '"), # to display the month and year on two rows on graphs 
         Month_format = reorder(Month_format, Date_Start), # reorder Month
         Week = as.factor(week(Date_Start)),
         Year = as.factor(year(Date_Start)))

# we will need the cumulative practice for each date for later so we can store it in a variable
Practice_by_Date <- raw_data%>%
  group_by(Date_Start)%>%
  summarise(Duration = sum(Duration)/60)%>%
  mutate(Cumulative_Duration = as.integer(cumsum(Duration)))%>%
  select(-Duration)

# assess if there was a break longer than 31 days while learning a piece
max_break <- raw_data%>%
  filter(Genre %notin% c("Other", "Not applicable"))%>%
  arrange(Project)%>%
  group_by(Project)%>%
  summarise(Max_Break = max(Date_End - lag(Date_End), na.rm = TRUE),
            Max_Break = ifelse(is.infinite(Max_Break), 0, Max_Break))

# pulls some features not stored within the app
table_existing_info <- read_csv("table_outline.csv")%>%
  mutate(Project = as.factor(Project),
         Standard = as.factor(Standard),
         ABRSM = as.factor(ABRSM))

# merge the previous tables with the modelling data (information for each project)
model_data <- raw_data%>%
  filter(Genre %notin% c("Other", "Not applicable"))%>%
  filter(Completed == "Yes")%>%
  droplevels()%>%
  group_by(Project, Genre)%>%
  summarise(Duration = sum(Duration)/60,
            Date_Start = min(Date_Start),
            Date_End = max(Date_End),
            Days_Practiced = Date_End - Date_Start)%>%
  left_join(table_existing_info, by = "Project")%>%
  mutate(ABRSM = as.factor(ABRSM),
         Level = as.factor(ifelse(ABRSM %in% c(1,2,3,4), "Beginner",
                                  ifelse(ABRSM %in% c(5,6), "Intermediate", 
                                         ifelse(ABRSM %in% c(7,8), "Advanced", "Not available")))),
         Standard = as.factor(Standard),
         ABRSM = fct_relevel(ABRSM, levels = c("1", "2", "3", "4", "5", "6", "7", "8")),
         Level = fct_relevel(Level, levels = c("Beginner", "Intermediate", "Advanced")),
         Length = Length/60)%>%
  inner_join(Practice_by_Date, by = "Date_Start")%>%
  inner_join(max_break, by = "Project")%>%
  mutate(Break = as.factor(ifelse(Max_Break > 31, "Yes", "No")))

# any projects without the needed info (ie. Difficulty, Length of piece) will be flagged into this file/variable
table_missing_info <- model_data%>%
  distinct(Project)%>%
  anti_join(table_existing_info, by = "Project")

# they will then be saved into our "alert" file for review
write_csv(table_missing_info, "table_missing_info.csv")

# connect to their API
# https://support.toggl.com/en/articles/2559637-do-you-have-an-api-available