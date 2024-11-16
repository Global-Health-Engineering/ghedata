# Description ------------------------------------------------------------------
# R script to process uploaded raw data into a tidy, analysis-ready data frame
# Load packages ----------------------------------------------------------------
## Run the following code in console if you don't have the packages
## install.packages(c("usethis", "fs", "here", "readr", "readxl", "openxlsx"))
library(usethis)
library(fs)
library(here)
library(readr)
library(readxl)
library(openxlsx)
library(googlesheets4)
library(dplyr)
library(lubridate)
library(stringr)
library(purrr)

# functions ---------------------------------------------------------------



# Functions generated with perplexity.ai:
# https://www.perplexity.ai/search/write-r-code-to-use-stringr-to-RgzUzkXuQgqZ4IAPHJvlpg

# Function to generate a unique ID
generate_unique_id <- function(length = 6) {
  paste0(sample(length, replace = TRUE), collapse = "")
}

# Function to replace the last word after dash with a unique ID
replace_last_dash <- function(string) {
  str_replace(string, "-([^-]+)$", paste0("-", generate_unique_id()))
}

# Read data --------------------------------------------------------------------
# data_in <- readr::read_csv("data-raw/dataset.csv")
# codebook <- readxl::read_excel("data-raw/codebook.xlsx") |>
#  clean_names()

data_in <- read_sheet("https://docs.google.com/spreadsheets/d/1LuXu3u-bmvYMjmc7L2YTUd5obTbBnR1qCrIJIwhUvFE/edit?gid=0#gid=0") |>
  janitor::clean_names() |>
  mutate(start_date = lubridate::ymd(start_date),
         year = year(start_date)) |>
  mutate(across(where(is.character),
                ~na_if(., "NA")))

# Tidy data --------------------------------------------------------------------
## Clean the raw data into a tidy format here

set.seed(seed = 0721)

ghedata <- data_in |>
  select(project_id, degree, type, b_m_student, start_date, year, thesis_title) |>
  mutate(project_id = map_chr(project_id, replace_last_dash))

# Export Data ------------------------------------------------------------------
usethis::use_data(ghedata, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(ghedata,
                 here::here("inst", "extdata", paste0("ghedata", ".csv")))
openxlsx::write.xlsx(ghedata,
                     here::here("inst", "extdata", paste0("ghedata", ".xlsx")))
