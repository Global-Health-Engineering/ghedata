# Description ------------------------------------------------------------------
# Builds three tables from two Google Sheets that hold names and stay outside
# this repository:
# - people: one row per engagement in the group, without titles and without
#   an identifier.
# - outputs: theses and projects of students with their titles. No key links
#   it to people.
# - computational: counts per question and answer of the group survey of
#   June 2025. The answers per respondent are held in memory only.
#
# The Google account that may read the sheets is set in ~/.Renviron:
#   GHE_GOOGLE_EMAIL=<address>
#
# Run from the package root:
#   Rscript data-raw/data_processing.R

# Load packages ----------------------------------------------------------------
library(usethis)
library(fs)
library(here)
library(readr)
library(writexl)
library(googlesheets4)
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)

# Read data --------------------------------------------------------------------

## People - metadata table for all staff and students at GHE

# Configure authentication to use the correct email
gs4_auth(email = Sys.getenv("GHE_GOOGLE_EMAIL", unset = NA))

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

# One row per respondent. This table is held in memory only and is never
# written to a file: the package publishes counts per answer.
responses <- pre_course_survey |>
  mutate(id = seq(1:n())) |>
  relocate(id) |>
  filter(!id %in% c(3, 8, 17)) |>
  select(
    id,
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

## People: one row per engagement, without titles and without an identifier.
## Sorted by start date, so the order of the rows says nothing about the
## order of the source table. There is no key to the table outputs.
people <- data_in |>
  select(degree, type, b_m_student, start_date, year) |>
  arrange(start_date, degree, type)

## Outputs: theses and projects of students with their titles. Finished and
## running work, without work that was not finished and without staff rows.
## Sorted by year, type and title; no column and no row order links a row to
## the table people.
outputs <- data_in |>
  filter(
    degree %in% c("bsc", "msc", "phd"),
    !is.na(thesis_title),
    status != "not finished"
  ) |>
  transmute(
    title = str_squish(thesis_title),
    output_type = paste(degree, recode(type, "sem-proj" = "semester project", "case-study" = "case study")),
    year = as.integer(year),
    research_collection_link = if_else(
      str_detect(coalesce(as.character(eth_collection_link), ""), "^https?://"),
      as.character(eth_collection_link),
      NA_character_
    )
  ) |>
  arrange(year, output_type, title)

## Computational: counts per question and answer. Three questions allowed
## several picks; their answers are split at the commas between the picks
## (commas inside brackets belong to one pick) and counted per pick.
multiple_picks <- c("other_languages", "ides_used", "llm_tools_used")

computational <- responses |>
  select(-id) |>
  mutate(across(everything(), as.character)) |>
  pivot_longer(everything(), names_to = "question", values_to = "answer") |>
  filter(!is.na(answer)) |>
  mutate(
    answer = if_else(
      question %in% multiple_picks,
      str_split(answer, ",\\s*(?![^()]*\\))"),
      as.list(answer)
    )
  ) |>
  unnest(answer) |>
  mutate(answer = str_squish(answer)) |>
  count(question, answer, name = "n") |>
  mutate(
    question = factor(question, levels = setdiff(names(responses), "id")),
    respondents = nrow(responses)
  ) |>
  arrange(question, desc(n), answer) |>
  mutate(question = as.character(question))

# Export Data ------------------------------------------------------------------
export_table <- function(data, name) {
  readr::write_csv(data, here::here("inst", "extdata", paste0(name, ".csv")))
  writexl::write_xlsx(data, here::here("inst", "extdata", paste0(name, ".xlsx")))
}

fs::dir_create(here::here("inst", "extdata"))

usethis::use_data(people, overwrite = TRUE)
export_table(people, "people")

usethis::use_data(outputs, overwrite = TRUE)
export_table(outputs, "outputs")

usethis::use_data(computational, overwrite = TRUE)
export_table(computational, "computational")
