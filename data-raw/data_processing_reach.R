# Description ------------------------------------------------------------------
# R script to build the reach table of ghedata from a public interface:
# zenodo_records (records on Zenodo with views and downloads).
#
# Run from the package root: Rscript data-raw/data_processing_reach.R
# Needs network access and no token. The script is not sourced from
# data_processing.R because it needs network access.
#
# The ETH Research Collection is not part of this script: its usage counts
# could not be read through its public interface in November 2026.
#
# Scope:
# - Zenodo: records with a creator whose ORCID is on the private list of the
#   group, and records of the openwashdata community. The list is a csv with
#   one column, orcid. It stays outside the repository; its place is
#   ~/.config/ghedata/zenodo_orcids.csv or the path in GHE_ZENODO_ORCIDS.
#   Records listed in data-raw/zenodo_records_excluded.csv are left out.
#   Zenodo returns the latest version of a record; views and downloads are the
#   totals over all versions.
#
# Personal data rules of this script:
# - No name and no ORCID of a creator or author is written to the table. The
#   table holds the title, the type, the dates, the identifier and the counts
#   of a record, all of which are public on Zenodo.

# Load packages ----------------------------------------------------------------
library(usethis)
library(here)
library(readr)
library(openxlsx)
library(dplyr)
library(purrr)
library(httr2)

# Settings ---------------------------------------------------------------------

snapshot_date <- as.Date(format(Sys.time(), tz = "UTC"))
zenodo_community <- "14a82a1c-740d-4ad0-a0fe-ca3808a1bd0e" # openwashdata

orcid_file <- path.expand(Sys.getenv("GHE_ZENODO_ORCIDS", "~/.config/ghedata/zenodo_orcids.csv"))
stopifnot("Set GHE_ZENODO_ORCIDS to the private list of ORCIDs" = file.exists(orcid_file))
orcids <- read_csv(orcid_file, col_types = "c")$orcid

# Records that a listed person co-authored outside the work of the group. The
# concept id is the identifier that all versions of a record share.
zenodo_excluded <- read_csv(here::here("data-raw", "zenodo_records_excluded.csv"), col_types = "ccc")$concept_id

# Functions --------------------------------------------------------------------

get_json <- function(url, ..., wait = 0.6) {
  Sys.sleep(wait)
  request(url) |>
    req_url_query(...) |>
    req_user_agent("ghedata data-raw script") |>
    req_perform() |>
    resp_body_json()
}

export_extdata <- function(data, name) {
  readr::write_csv(data, here::here("inst", "extdata", paste0(name, ".csv")))
  openxlsx::write.xlsx(data, here::here("inst", "extdata", paste0(name, ".xlsx")))
}

first_or_na <- function(x) if (is.null(x) || length(x) == 0) NA_character_ else as.character(x[[1]])

# All records on Zenodo that match a query, page by page.
zenodo_query <- function(q) {
  hits <- list()
  page <- 1
  repeat {
    res <- get_json("https://zenodo.org/api/records", q = q, size = 25, page = page)
    hits <- c(hits, res$hits$hits)
    if (length(res$hits$hits) < 25 || length(hits) >= res$hits$total) break
    page <- page + 1
  }
  hits
}

# Zenodo -----------------------------------------------------------------------

zenodo_community_hits <- zenodo_query(paste0("parent.communities.ids:", zenodo_community))
zenodo_community_ids <- map_chr(zenodo_community_hits, \(rec) as.character(rec$id))
zenodo_hits <- c(
  map(orcids, \(x) zenodo_query(paste0('metadata.creators.person_or_org.identifiers.identifier:"', x, '"'))) |>
    list_flatten(),
  zenodo_community_hits
)

zenodo_records <- zenodo_hits |>
  map(\(rec) {
    tibble(
      record_id = as.character(rec$id),
      concept_id = as.character(rec$conceptrecid %||% rec$id),
      doi = first_or_na(rec$doi),
      title = first_or_na(rec$metadata$title),
      publication_date = as.Date(substr(first_or_na(rec$metadata$publication_date), 1, 10), optional = TRUE),
      resource_type = first_or_na(rec$metadata$resource_type$type),
      openwashdata_community = as.character(rec$id) %in% zenodo_community_ids,
      views = as.integer(rec$stats$views %||% 0),
      unique_views = as.integer(rec$stats$unique_views %||% 0),
      downloads = as.integer(rec$stats$downloads %||% 0),
      unique_downloads = as.integer(rec$stats$unique_downloads %||% 0)
    )
  }) |>
  list_rbind() |>
  distinct(concept_id, .keep_all = TRUE) |>
  filter(!concept_id %in% zenodo_excluded) |>
  filter(publication_date >= as.Date("2021-01-01")) |>
  select(-concept_id) |>
  arrange(publication_date, record_id) |>
  mutate(snapshot_date = snapshot_date)

usethis::use_data(zenodo_records, overwrite = TRUE)
export_extdata(zenodo_records, "zenodo_records")
cat(
  "zenodo_records:", nrow(zenodo_records), "records,",
  sum(zenodo_records$downloads), "downloads,", sum(zenodo_records$views), "views\n"
)
