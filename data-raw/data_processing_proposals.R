# Description ------------------------------------------------------------------
# Reads the table of submitted proposals of Global Health Engineering from
# Google Sheets and writes the dataset `proposals`: one row per proposal, with
# the columns that name a person, a project, a partner or a folder removed.
#
# The address of the Google Sheet is not written into this script. Set it in
# ~/.Renviron (or in the session) before running:
#
#   GHE_PROPOSALS_SHEET=<address of the Google Sheet>
#   GHE_PROPOSALS_TAB=<name of the tab, optional, the first tab is the default>
#
# For a run without a connection, GHE_PROPOSALS_FILE can point to an xlsx
# download of the same sheet. It is used only when GHE_PROPOSALS_SHEET is empty.
#
# Run from the package root: Rscript data-raw/data_processing_proposals.R

# Load packages ----------------------------------------------------------------
library(googlesheets4)
library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(jsonlite)
library(here)

# Settings ---------------------------------------------------------------------

sheet_url <- Sys.getenv("GHE_PROPOSALS_SHEET")
sheet_tab <- Sys.getenv("GHE_PROPOSALS_TAB")
local_file <- Sys.getenv("GHE_PROPOSALS_FILE")

# The Google account that may read the sheet is named in GHE_GOOGLE_EMAIL. When
# the variable is not set, gs4_auth() asks which account to use.

# Amounts in other currencies are converted to CHF with the reference rate of
# the European Central Bank on 1 July of the year of submission. When 1 July is
# not a banking day, the source returns the last banking day before it.
rates_file <- here::here("data-raw", "proposals_exchange_rates.csv")
rates_api <- "https://api.frankfurter.dev/v1/"

# Rows of the sheet that are not proposals of the group, for example a project
# from before the group started. They are named by the short project name and
# the date of submission.
excluded_file <- here::here("data-raw", "proposals_excluded.csv")

# Functions --------------------------------------------------------------------

# Dates arrive as text: a serial number from an xlsx download, or a formatted
# date from Google Sheets. A year and month without a day ("2026-05") becomes
# the first day of the month. Anything else (for example "?") becomes NA.
parse_sheet_date <- function(x) {
  x <- str_trim(as.character(x))
  serial <- suppressWarnings(as.numeric(x))
  from_serial <- as.Date(serial, origin = "1899-12-30")
  from_text <- as.Date(suppressWarnings(
    parse_date_time(x, orders = c("ymd", "ymd HMS", "dmy", "mdy", "ym"), quiet = TRUE)
  ))
  if_else(!is.na(serial), from_serial, from_text)
}

# Currencies are three letter codes. Two symbols that appear in the sheet are
# turned into their code; "$" is left as it is, because it could be USD or CAD.
clean_currency <- function(x) {
  x <- str_to_upper(str_trim(as.character(x)))
  recode(x, "£" = "GBP", "€" = "EUR")
}

# Amounts arrive as text, some with thousands separators (738'481).
parse_amount <- function(x) {
  x <- str_remove_all(as.character(x), "['’\\s,]")
  suppressWarnings(as.numeric(x))
}

clean_text <- function(x) {
  x <- str_squish(as.character(x))
  na_if(na_if(na_if(x, ""), "NA"), "N/A")
}

# One spelling per funder. Left side: the cleaned text of the sheet in lower
# case with hyphens as spaces. Add a line when a new spelling appears.
funder_names <- c(
  "snf" = "SNSF",
  "ambizione snf" = "SNSF Ambizione",
  "bridge snf" = "SNSF Bridge",
  "snf sinergia" = "SNSF Sinergia",
  "snf spirit" = "SNSF SPIRIT",
  "snf trans atlantic platform" = "SNSF Trans-Atlantic Platform",
  "snf nrf" = "SNSF and NRF South Africa",
  "doc mobility" = "ETH Doc.Mobility",
  "sa nrf" = "NRF South Africa",
  "leading house africa" = "Leading House Africa",
  "leading house asia" = "Leading House Asia",
  "leading house la" = "Leading House Latin America",
  "leading house latin america" = "Leading House Latin America",
  "kimberly clark" = "Kimberly-Clark",
  "jacobs foundation" = "Jacobs Foundation",
  "spencer foundation" = "Spencer Foundation",
  "engineering x" = "Engineering X",
  "branco weiss" = "Branco Weiss Fellowship",
  "latsis" = "Latsis Foundation",
  "world food systems" = "World Food System Center",
  "world food system centre" = "World Food System Center",
  "eth foundation/ daester schild stiftung" = "ETH Foundation, Däster-Schild Stiftung",
  "eth4d hac" = "ETH4D",
  "eth4d sdg pitch event" = "ETH4D",
  "icrc eth4d" = "ETH4D",
  "eu" = "European Union",
  "horizon 2020" = "European Union"
)

clean_funder <- function(x) {
  x <- clean_text(x)
  # a web address in place of a name: the New Frontiers in Research Fund
  x <- if_else(str_detect(x, "nfrf-fnfr"), "New Frontiers in Research Fund", x)
  key <- str_squish(str_replace_all(str_to_lower(x), "-", " "))
  out <- unname(funder_names[key])
  if_else(is.na(out), x, out)
}

# Rates as units of the currency for 1 CHF, kept in a file so a run can be
# repeated. Only pairs of year and currency that are missing are fetched.
get_rates <- function(needed) {
  rates <- if (file.exists(rates_file)) {
    read_csv(rates_file, col_types = "icDd")
  } else {
    tibble(
      year = integer(), currency = character(),
      rate_date = as.Date(character()), units_per_chf = double()
    )
  }
  missing <- anti_join(needed, rates, by = c("year", "currency"))
  for (i in seq_len(nrow(missing))) {
    res <- fromJSON(paste0(
      rates_api, missing$year[i], "-07-01?base=CHF&symbols=", missing$currency[i]
    ))
    rates <- bind_rows(rates, tibble(
      year = missing$year[i],
      currency = missing$currency[i],
      rate_date = as.Date(res$date),
      units_per_chf = res$rates[[missing$currency[i]]]
    ))
  }
  rates <- arrange(rates, year, currency)
  write_csv(rates, rates_file)
  rates
}

# Read data --------------------------------------------------------------------

# Every column is read as text, because several columns mix numbers, dates and
# notes. Types are set below.
if (nzchar(sheet_url)) {
  gs4_auth(email = Sys.getenv("GHE_GOOGLE_EMAIL", unset = NA))
  data_in <- read_sheet(
    ss = sheet_url,
    sheet = if (nzchar(sheet_tab)) sheet_tab else NULL,
    col_types = "c"
  )
} else if (nzchar(local_file)) {
  data_in <- readxl::read_excel(local_file, col_types = "text")
} else {
  stop("Set GHE_PROPOSALS_SHEET (or GHE_PROPOSALS_FILE) before running.")
}

# Tidy data --------------------------------------------------------------------

raw <- data_in |>
  janitor::clean_names() |>
  mutate(across(everything(), clean_text)) |>
  filter(!is.na(proj_id)) |>
  mutate(
    sheet_row = row_number(),
    status = str_to_lower(status),
    submitted_date = parse_sheet_date(submitted_date),
    answer_date = parse_sheet_date(answer_date),
    budget = parse_amount(proposed_budget),
    currency = clean_currency(currency),
    funder = clean_funder(submitted_to)
  )

stopifnot(
  all(raw$status %in% c("accepted", "rejected", "submitted", "withdrawn")),
  !anyNA(raw$submitted_date)
)

# Exchange rates
needed <- raw |>
  filter(!is.na(budget), !is.na(currency), currency != "CHF") |>
  distinct(year = as.integer(year(submitted_date)), currency)

rates <- get_rates(needed)

excluded <- read_csv(excluded_file, col_types = cols(.default = "c")) |>
  transmute(proj_name_short, submitted_date = as.Date(submitted_date))
stopifnot(nrow(semi_join(excluded, raw, by = c("proj_name_short", "submitted_date"))) == nrow(excluded))

# Identifiers without names. A project is the short project name of the sheet:
# proposals with the same short name are requests for the same project. Each
# request is a proposal of its own and counts in every sum. The
# number follows the order of submission, so a new row at the end of the sheet
# does not change the identifiers of earlier rows as long as its date is later.
# Excluded rows are taken out after the numbering, so an exclusion does not
# change the identifiers of the other rows either.
proposals_all <- raw |>
  arrange(submitted_date, sheet_row) |>
  mutate(
    proposal_id = sprintf("P%03d", row_number()),
    project_id = sprintf("PRJ%03d", match(proj_name_short, unique(proj_name_short))),
    submitted_year = as.integer(year(submitted_date))
  ) |>
  left_join(rates, by = c("submitted_year" = "year", "currency")) |>
  mutate(
    rate_date = if_else(currency == "CHF", NA_Date_, rate_date),
    budget_chf = case_when(
      currency == "CHF" ~ budget,
      !is.na(units_per_chf) ~ round(budget / units_per_chf),
      .default = NA_real_
    ),
    # An answer before the submission is an error in the sheet.
    days_to_answer = as.integer(answer_date - submitted_date),
    days_to_answer = if_else(days_to_answer < 0, NA_integer_, days_to_answer)
  ) |>
  anti_join(excluded, by = c("proj_name_short", "submitted_date"))

# The published columns. Not published: the proposal and project names, the
# leads and co-leads, the partner organisations, the folder links, the link to
# the call and the comments.
proposals <- proposals_all |>
  transmute(
    proposal_id,
    project_id,
    status,
    submitted_date,
    submitted_year,
    answer_date,
    days_to_answer,
    funder,
    snsf = str_detect(coalesce(funder, ""), "^SNSF"),
    budget,
    currency,
    rate_date,
    budget_chf,
    # The data steward is an author of the package and agreed to this flag.
    lead_data_steward = proj_lead_ghe == "lschoebitz",
    co_lead_external = !is.na(proj_co_lead_ext),
    partner_organisation = !is.na(partner_organisation)
  )

# Checks -----------------------------------------------------------------------

# No proposal name and no name of a person may appear in the published table.
# Short project names are left out of this check, because a few of them are the
# name of the funder (which is published).
removed <- c(
  raw$proj_id, raw$proj_lead_ghe, raw$proj_co_lead_ghe, raw$proj_co_lead_ext
)
removed <- unique(removed[!is.na(removed) & nchar(removed) > 3])
published_text <- unlist(lapply(select(proposals, where(is.character)), unique))
stopifnot(
  !any(published_text %in% removed),
  !anyDuplicated(proposals$proposal_id),
  nrow(proposals) == nrow(raw) - nrow(excluded)
)

# Gaps in the sheet, printed for the person who keeps it. The rows are named by
# their position in the sheet (the header is row 1), not by project.
gaps <- proposals_all |>
  mutate(
    gap = case_when(
      is.na(budget) ~ "no budget",
      is.na(currency) ~ "budget without a currency",
      is.na(funder) ~ "no funder",
      !is.na(answer_date) & answer_date < submitted_date ~ "answer before submission",
      .default = NA_character_
    )
  ) |>
  filter(!is.na(gap)) |>
  transmute(sheet_row = sheet_row + 1L, proposal_id, gap) |>
  arrange(sheet_row)

message("Rows with gaps in the sheet:")
print(as.data.frame(gaps), row.names = FALSE)

message("Summary:")
proposals |>
  summarise(
    proposals = n(),
    accepted = sum(status == "accepted"),
    requested_chf = sum(budget_chf, na.rm = TRUE),
    accepted_chf = sum(budget_chf[status == "accepted"], na.rm = TRUE),
    without_amount_in_chf = sum(is.na(budget_chf))
  ) |>
  as.data.frame() |>
  print(row.names = FALSE)

# Export Data ------------------------------------------------------------------

usethis::use_data(proposals, overwrite = TRUE)

readr::write_csv(proposals, here::here("inst", "extdata", "proposals.csv"))
openxlsx::write.xlsx(proposals, here::here("inst", "extdata", "proposals.xlsx"))
