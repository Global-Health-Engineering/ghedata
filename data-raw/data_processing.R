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
library(tidyr)

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

## People - metadata table for all staff and students at GHE

# Configure authentication to use the correct email
gs4_auth(email = "lschoebitz@ethz.ch")

# data_in <- readr::read_csv("data-raw/dataset.csv")
# codebook <- readxl::read_excel("data-raw/codebook.xlsx") |>
#  clean_names()

data_in <- read_sheet(
  "https://docs.google.com/spreadsheets/d/1LuXu3u-bmvYMjmc7L2YTUd5obTbBnR1qCrIJIwhUvFE/edit?gid=0#gid=0"
) |>
  janitor::clean_names() |>
  mutate(start_date = lubridate::ymd(start_date), year = year(start_date)) |>
  mutate(across(where(is.character), ~ na_if(., "NA")))

## Computational Competencies - group survey from June 2025
## This survey was shared with all team members in preparation of the
## openwashdata conference. Two survey respondents are not part of the team
## and were removed before removing personal details

sheet_pre_course <- "https://docs.google.com/spreadsheets/d/19AbV2P0yybzMbrFiq8_3nPiE-Hj_OUZJLHiWqkCydEk/edit?gid=398618297#gid=398618297"

pre_course_survey <- googlesheets4::read_sheet(ss = sheet_pre_course)

# Process survey data and handle multi-answer columns
computational <- pre_course_survey |>
  mutate(id = seq(1:n())) |>
  relocate(id) |>
  filter(!id %in% c(3, 8, 17)) |>
  select(
    id,
    # gh_username = `Please provide your GitHub username. Please get an account if you do not have one: https://github.com/`,
    experience_programming_general = `Which of these best describes your experience with programming in general?`,
    experience_programming_r = `Which of these best describes your experience with programming in R?`,
    experience_programming_python = `Which of these best describes your experience with programming in Python?`,
    other_languages = `Which other programming languages / software do you have experience in?`,
    programming_confidence = `Which of these best describes how easily you could write a program in any language to find the largest number in a list?`,
    experience_git = `Which of these best describes your experience with using Git?`,
    experience_github = `Which of these best describes your experience with using GitHub?`,
    data_storage_format = `In which format do you store the majority of your data?`,
    document_writing_approach = `Which of these best describes how you write narrative documents that include text and analysis?`,
    experience_ides = `Which of these best describes your experience with using Integrated Development Environments (IDEs)?`,
    ides_used = `Which of the following Integrated Development Environments (IDEs) have you used? (Select all that apply)`,
    cli_usage = `Which of these best describes your current usage of the default command-line interface (CLI) on your operating system?\nOn Mac: The default CLI app is Terminal, and the default shell is Zsh (you may also use Bash or other shells)\nOn Windows: The default CLI app is Windows Terminal, which can run Command Prompt, PowerShell, and Bash (via Windows Subsystem for Linux)\nHow would you describe your experience?`,
    llm_usage = `Which best describes your current usage of Language Learning Models (LLMs), for example ChatGPT, for completing tasks (ideation, writing, coding)?`,
    llm_tools_used = `Which of the following Large Language Model (LLM) tools or platforms have you used for research, ideation, writing, coding, or related tasks? (Select all that apply)`,
  )


# Tidy data --------------------------------------------------------------------
## Clean the raw data into a tidy format here

set.seed(seed = 0721)

people <- data_in |>
  select(title, degree, type, b_m_student, start_date, year, thesis_title) |>
  mutate(title = map_chr(title, replace_last_dash))

# Export Data ------------------------------------------------------------------
# Export people data
usethis::use_data(people, overwrite = TRUE)

fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(
  people,
  here::here("inst", "extdata", paste0("people", ".csv"))
)
openxlsx::write.xlsx(
  people,
  here::here("inst", "extdata", paste0("people", ".xlsx"))
)

# Export computational competencies data
usethis::use_data(computational, overwrite = TRUE)

# Export as CSV
readr::write_csv(
  computational,
  here::here("inst", "extdata", "computational.csv")
)

# Export as XLSX
openxlsx::write.xlsx(
  computational,
  here::here("inst", "extdata", "computational.xlsx")
)
