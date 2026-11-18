# Description ------------------------------------------------------------------
# Builds two tables of commits by group members, without any name:
# - github_commits_by_person: the number of commits per group member over the
#   last twelve full months of github_commits.
# - github_commits_by_members: the number of commits by all group members per
#   month, for every month of github_commits.
# Commits in the training organisations (workshop exercises) are not counted
# as commits; in github_commits_by_person they only set the column workshop.
#
# Who is one person and who is a group member comes from a private lookup file
# that is not part of this repository. Set its path in ~/.Renviron:
#
#   GHE_PEOPLE_LOOKUP=<path to a csv with the columns key, person, member, trainer>
#
# key is the login (or the email address or name of a commit without a login),
# in lower case; person is the key all identities of one person share; member
# is TRUE for people who were part of the group in the twelve months; trainer
# is TRUE for the person who ran the workshops. The file has to hold every
# key of the last 24 months (the two twelve-month periods that are compared);
# a key of these months that is not in the file is not counted, and the script
# reports how many keys that were. In the months before, a key that is not in
# the file counts as a group member, because nobody has gone through the
# people of those years one by one.
#
# Run from the package root, after data_processing_github.R:
#   Rscript data-raw/data_processing_github_people.R
# Needs the GitHub CLI (gh), signed in as for data_processing_github.R.
#
# Personal data rules of this script:
# - The login (or, without a login, the email address) of the author of a
#   commit is held in memory only to add up the commits of one person. It is
#   replaced by a rank before anything is written. No login, name or email is
#   written to a file, cache or log.
# - Names of private repositories are held in memory to call the API and are
#   never written to a file.
# - The lookup file holds logins and stays outside the repository.
# - The table holds one row per person with counts only. In a small group a
#   rank can still point to a person for someone who knows the group.

# Load packages ----------------------------------------------------------------
library(usethis)
library(here)
library(readr)
library(openxlsx)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(lubridate)

# Settings ---------------------------------------------------------------------

load(here::here("data", "github_commits.rda"))

last_month <- max(github_commits$month)
first_month <- last_month %m-% months(11)

scope <- read_csv(
  here::here("data-raw", "github_organisations.csv"),
  col_types = "ccll"
) |>
  filter(commits_counted)

training <- scope$organisation[scope$purpose == "training"]

lookup_file <- path.expand(Sys.getenv("GHE_PEOPLE_LOOKUP"))
stopifnot("Set GHE_PEOPLE_LOOKUP to the private lookup file" = file.exists(lookup_file))
lookup <- read_csv(lookup_file, col_types = "cclc", col_select = c(key, person, member, trainer)) |>
  mutate(trainer = as.logical(trainer))

automated_pattern <- read_csv(
  here::here("data-raw", "github_automated_commits.csv"),
  col_types = "cc"
) |>
  pull(pattern) |>
  paste(collapse = "|")

# Functions --------------------------------------------------------------------

# Error output is discarded so that no repository name can end up in a log.
gh_lines <- function(endpoint, jq) {
  args <- c("api", shQuote(endpoint), "--paginate", "--jq", shQuote(jq))
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = FALSE))
  status <- attr(out, "status")
  list(lines = as.character(out), ok = is.null(status) || status == 0)
}

jq_repos <- '.[] | select(.fork | not) | .name'

# One line per commit: the key of the person, the month of the author date and
# the same four flags as in data_processing_github.R.
jq_commits <- r"(.[] | [
  ((.author.login // .commit.author.email // .commit.author.name // "unknown") | ascii_downcase),
  .commit.author.date[0:7],
  (if ((.author.type // "") == "Bot")
      or ((.commit.author.name // "") | test("\\[bot\\]$|^GitHub Actions?$|^github-actions$|Changelog Action$"))
      or ((.commit.author.email // "") | test("\\[bot\\]@|^actions?@github\\.com$|github-actions"))
   then 1 else 0 end),
  (.parents | length),
  (if (.commit.message | test("(^|\\n)\\s*(co-authored-by: *(claude|copilot)|assisted-by:)|generated with \\[claude code\\]"; "i"))
   then 1 else 0 end),
  (if (.commit.message | split("\n")[0] | test("AUTOMATED_PATTERN"))
   then 1 else 0 end)
] | @tsv)" |>
  str_replace(fixed("AUTOMATED_PATTERN"), automated_pattern)

get_commits <- function(organisation, repository) {
  res <- gh_lines(
    paste0(
      "repos/", organisation, "/", repository, "/commits?per_page=100"
    ),
    jq_commits
  )
  # An empty repository answers with an error; it has no commits to count.
  if (!res$ok || length(res$lines) == 0) {
    return(NULL)
  }
  read_tsv(
    I(paste0(res$lines, collapse = "\n")),
    col_names = c("person", "month", "bot", "parents", "assisted", "automated"),
    col_types = "cciiii"
  )
}

# Read data --------------------------------------------------------------------

repos <- map(
  scope$organisation,
  \(o) tibble(
    organisation = o,
    repository = gh_lines(paste0("orgs/", o, "/repos?type=all&per_page=100"), jq_repos)$lines
  )
) |>
  list_rbind()

commits <- map2(
  repos$organisation, repos$repository,
  \(o, r) {
    x <- get_commits(o, r)
    if (is.null(x)) NULL else mutate(x, workshop = o %in% training)
  },
  .progress = TRUE
) |>
  list_rbind() |>
  mutate(month = as.Date(paste0(month, "-01"))) |>
  filter(month <= last_month, bot == 0, automated == 0, parents <= 1) |>
  rename(key = person) |>
  left_join(lookup, by = "key")

# The months in which every key has to be in the lookup.
checked_from <- first_month %m-% months(12)

# Tidy data --------------------------------------------------------------------

keys_unknown <- n_distinct(commits$key[is.na(commits$member) & commits$month >= checked_from])

## github_commits_by_members: one row per month
github_commits_by_members <- commits |>
  filter(!workshop, coalesce(member, month < checked_from)) |>
  summarise(commits = n(), commits_assisted = sum(assisted), .by = month) |>
  complete(
    month = seq(min(github_commits$month), last_month, by = "month"),
    fill = list(commits = 0L, commits_assisted = 0L)
  ) |>
  arrange(month) |>
  mutate(lookup_complete = month >= checked_from)

## github_commits_by_person: one row per group member, last twelve months
github_commits_by_person <- commits |>
  filter(month >= first_month, coalesce(member, FALSE)) |>
  group_by(person) |>
  summarise(
    commits = sum(!workshop),
    commits_assisted = sum(assisted[!workshop]),
    workshop = case_when(
      any(trainer) ~ "trainer",
      any(workshop) ~ "participant",
      .default = "none"
    ),
    .groups = "drop"
  ) |>
  arrange(desc(commits), workshop) |>
  transmute(
    person_rank = row_number(),
    commits,
    commits_assisted,
    share_assisted = if_else(commits > 0, round(commits_assisted / commits, 2), NA_real_),
    workshop,
    first_month = first_month,
    last_month = last_month
  )

rm(commits, repos, lookup)

stopifnot(!any(c("person", "login", "key") %in% names(github_commits_by_person)))
stopifnot(!any(c("person", "login", "key") %in% names(github_commits_by_members)))

message(
  nrow(github_commits_by_person), " group members, ",
  sum(github_commits_by_person$commits > 0), " with commits outside the workshops, ",
  sum(github_commits_by_person$commits), " commits (github_commits has ",
  sum(github_commits$commits[github_commits$month >= first_month]),
  " with workshops and people outside the group); ",
  keys_unknown, " identities of the last 24 months not in the lookup"
)

# Export Data ------------------------------------------------------------------

usethis::use_data(github_commits_by_person, overwrite = TRUE)
usethis::use_data(github_commits_by_members, overwrite = TRUE)

readr::write_csv(
  github_commits_by_members,
  here::here("inst", "extdata", "github_commits_by_members.csv")
)
openxlsx::write.xlsx(
  github_commits_by_members,
  here::here("inst", "extdata", "github_commits_by_members.xlsx")
)

readr::write_csv(
  github_commits_by_person,
  here::here("inst", "extdata", "github_commits_by_person.csv")
)
openxlsx::write.xlsx(
  github_commits_by_person,
  here::here("inst", "extdata", "github_commits_by_person.xlsx")
)
