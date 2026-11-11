# Description ------------------------------------------------------------------
# R script to build the three GitHub tables of ghedata from the GitHub REST API:
# github_organisations, github_repositories, github_repository_types and
# github_commits.
#
# Run from the package root: Rscript data-raw/data_processing_github.R
# Needs the GitHub CLI (gh), signed in with an account that is a member of the
# organisations listed in data-raw/github_organisations.csv. The script is not
# sourced from data_processing.R because it needs a token and network access.
#
# Personal data rules of this script:
# - No login, name, email, commit message or commit hash of a person is written
#   to any file, cache or log. The jq filters below reduce every commit to four
#   fields (month, bot flag, number of parents, agent trailer flag) before the
#   data reaches R.
# - Names of private repositories are held in memory to call the API and are
#   never written to a file.
# - Public repositories whose name contains the login of an organisation member
#   or of a contributor are left out of github_repositories, and so are
#   repositories of student work, which are named after the student.
# - The description of a repository can name a person. It is reduced to one
#   flag (student work or not) inside the jq filter and never reaches R.
# - github_repository_types counts all repositories by type, private ones and
#   student work included, and holds no repository name.

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

snapshot_date <- as.Date(format(Sys.time(), tz = "UTC"))
last_month <- floor_date(snapshot_date, "month") %m-% months(1)
first_month <- as.Date("2021-08-01")

scope <- read_csv(
  here::here("data-raw", "github_organisations.csv"),
  col_types = "ccll"
)

# Functions --------------------------------------------------------------------

# Call the GitHub API through the GitHub CLI and return the lines that the jq
# filter prints. Error output is discarded so that no repository name can end
# up in a log.
gh_lines <- function(endpoint, jq, paginate = TRUE) {
  args <- c("api", shQuote(endpoint), if (paginate) "--paginate", "--jq", shQuote(jq))
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = FALSE))
  status <- attr(out, "status")
  list(lines = as.character(out), ok = is.null(status) || status == 0)
}

# TRUE when the repository has no commits (the API answers with status 409).
gh_is_empty <- function(organisation, repository) {
  args <- c(
    "api", "-i",
    shQuote(paste0("repos/", organisation, "/", repository, "/commits?per_page=1"))
  )
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = TRUE))
  any(str_detect(out, "HTTP/[0-9.]+ 409"))
}

jq_org <- '[.created_at[0:10], .public_repos, (.total_private_repos // "")] | @tsv'

# The last two fields are flags: the name or the description points to student
# work, and the topics point to hardware.
jq_repos <- '.[] | [.name, .private, .fork, .archived, .created_at[0:10], (.pushed_at // "")[0:10], (.license.spdx_id // ""), (.language // ""), .size, (if ((.name + " " + (.description // "")) | test("bsc|msc|sem-proj|semester[- ]project|thesis"; "i")) then 1 else 0 end), (if ((.topics // []) | join(" ") | test("hardware|prototype"; "i")) then 1 else 0 end)] | @tsv'

# Three flags from the file names at the top level of a repository: an R
# package (DESCRIPTION), a data folder (data or data-raw), a Python package.
jq_root <- '[.[].name] | [(index("DESCRIPTION") != null), ((index("data") != null) or (index("data-raw") != null)), ((index("pyproject.toml") != null) or (index("setup.py") != null))] | map(if . then 1 else 0 end) | @tsv'

# One line per commit: month of the author date, bot flag, number of parents,
# agent trailer flag. Nothing else leaves the API response.
jq_commits <- r"(.[] | [
  .commit.author.date[0:7],
  (if ((.author.type // "") == "Bot")
      or ((.commit.author.name // "") | test("\\[bot\\]$"))
      or ((.commit.author.email // "") | test("\\[bot\\]@|^actions@github\\.com$|github-actions"))
   then 1 else 0 end),
  (.parents | length),
  (if (.commit.message | test("(^|\\n)\\s*(co-authored-by: *(claude|copilot)|assisted-by:)|generated with \\[claude code\\]"; "i"))
   then 1 else 0 end)
] | @tsv)"

get_org <- function(organisation) {
  res <- gh_lines(paste0("orgs/", organisation), jq_org, paginate = FALSE)
  if (!res$ok || length(res$lines) != 1) {
    stop("Organisation request failed for ", organisation)
  }
  read_tsv(
    I(res$lines),
    col_names = c("created_date", "repos_public", "repos_private"),
    col_types = "Dii"
  ) |>
    mutate(organisation = organisation, .before = 1)
}

get_repos <- function(organisation) {
  res <- gh_lines(
    paste0("orgs/", organisation, "/repos?type=all&per_page=100"),
    jq_repos
  )
  if (!res$ok) {
    stop("Repository list failed for ", organisation)
  }
  read_tsv(
    I(paste0(res$lines, collapse = "\n")),
    col_names = c(
      "repository", "is_private", "is_fork", "is_archived", "created_date",
      "pushed_date", "license", "primary_language", "size", "student",
      "hardware_topic"
    ),
    col_types = "clllDDcciii",
    na = "",
    quote = ""
  ) |>
    mutate(
      organisation = organisation,
      is_student = student == 1,
      has_hardware_topic = hardware_topic == 1,
      .before = 1
    ) |>
    select(-student, -hardware_topic)
}

# Flags from the top level of a repository. An empty repository has no
# contents and gets FALSE three times.
get_root <- function(organisation, repository) {
  res <- gh_lines(
    paste0("repos/", organisation, "/", repository, "/contents"),
    jq_root,
    paginate = FALSE
  )
  flags <- c(0L, 0L, 0L)
  if (res$ok && length(res$lines) == 1) {
    flags <- as.integer(str_split_1(res$lines, "\t"))
  }
  tibble(
    has_description = flags[1] == 1,
    has_data = flags[2] == 1,
    has_python_package = flags[3] == 1
  )
}

# Type of a repository, from its name, the flags of get_repos() and
# get_root(), and the purpose of its organisation. The first rule that
# matches decides. The rules are rough on purpose: they can be read in one
# go, and data-raw/github_repository_types.csv corrects single public
# repositories by hand.
classify_repository <- function(data) {
  name <- str_to_lower(data$repository)
  mutate(
    data,
    repository_type = case_when(
      purpose == "teaching" ~ "learner repository",
      name == ".github" ~ "organisation profile",
      purpose == "training" & has_member_login ~ "learner repository",
      has_description & has_data ~ "data package",
      is_student ~ "student project",
      str_detect(name, "^man-|manuscript") ~ "manuscript",
      str_detect(name, "^prop-|proposal|^report-") ~ "proposal or report",
      purpose %in% c("training", "events") ~ "teaching and training",
      str_detect(
        name,
        "workshop|training|slides|course|learner|cheatsheet|^talk-|poster|brown-bag|book$"
      ) ~ "teaching and training",
      str_detect(
        name,
        "website|blog|github\\.io|r-universe|newsletter|dashboard|brand"
      ) ~ "website and communication",
      str_detect(name, "template") ~ "template",
      str_detect(
        name,
        "strategy|annual-review|yearly|meeting-notes|safety|-dms$|^dmp-"
      ) ~ "group management",
      has_description | has_python_package ~ "software",
      has_hardware_topic | primary_language %in% c("C", "C++") ~ "hardware",
      TRUE ~ "research project"
    )
  )
}

get_commits <- function(organisation, repository) {
  res <- gh_lines(
    paste0("repos/", organisation, "/", repository, "/commits?per_page=100"),
    jq_commits
  )
  empty <- tibble(
    month = as.Date(character()),
    is_bot = logical(),
    is_merge = logical(),
    is_assisted = logical()
  )
  if (!res$ok) {
    if (gh_is_empty(organisation, repository)) {
      return(empty)
    }
    stop("Commit request failed for a repository of ", organisation)
  }
  if (length(res$lines) == 0) {
    return(empty)
  }
  read_tsv(
    I(paste0(res$lines, collapse = "\n")),
    col_names = c("month", "bot", "parents", "assisted"),
    col_types = "ciii"
  ) |>
    transmute(
      month = as.Date(paste0(month, "-01")),
      is_bot = bot == 1,
      is_merge = parents > 1,
      is_assisted = assisted == 1
    )
}

# Logins are read into memory to filter repository names and are never stored.
get_logins <- function(endpoint) {
  res <- gh_lines(endpoint, ".[].login")
  if (!res$ok) {
    return(character())
  }
  str_to_lower(res$lines)
}

# TRUE when a repository name is a login, or carries one as a part between
# hyphens (for example "exercise-login").
name_has_login <- function(name, logins) {
  name <- str_to_lower(name)
  logins <- logins[nchar(logins) >= 4]
  any(
    name == logins |
      str_starts(name, fixed(paste0(logins, "-"))) |
      str_ends(name, fixed(paste0("-", logins))) |
      str_detect(name, fixed(paste0("-", logins, "-")))
  )
}

# Read data --------------------------------------------------------------------

orgs_raw <- map(scope$organisation, get_org) |> list_rbind()

core <- scope |> filter(commits_counted)

repos_raw <- map(core$organisation, get_repos) |> list_rbind()

# Stop when the repository list is shorter than the count the organisation
# reports, which happens when the account cannot see all repositories.
repo_check <- repos_raw |>
  count(organisation, name = "listed") |>
  left_join(orgs_raw, by = "organisation") |>
  filter(listed < repos_public + repos_private)

if (nrow(repo_check) > 0) {
  stop(
    "Fewer repositories listed than reported for: ",
    paste(repo_check$organisation, collapse = ", ")
  )
}

# Repositories of the teaching organisations, for the counts by type only.
teaching <- scope |> filter(!commits_counted)

repos_teaching <- map(teaching$organisation, get_repos) |> list_rbind()

# Logins of the organisation members, to recognise repositories named after a
# person. Held in memory only.
member_logins <- map(
  core$organisation,
  \(x) get_logins(paste0("orgs/", x, "/members?per_page=100"))
) |>
  unlist() |>
  unique()

# Type of every repository. The hand kept file overrules the rules for single
# public repositories.
type_overrides <- read_csv(
  here::here("data-raw", "github_repository_types.csv"),
  col_types = "ccc"
) |>
  rename(repository_type_by_hand = repository_type)

repos_typed <- bind_rows(
  repos_raw |>
    mutate(
      root = map2(organisation, repository, get_root, .progress = TRUE)
    ) |>
    unnest(root),
  repos_teaching |>
    mutate(
      has_description = FALSE,
      has_data = FALSE,
      has_python_package = FALSE
    )
) |>
  left_join(scope |> select(organisation, purpose), by = "organisation") |>
  mutate(
    has_member_login = map_lgl(repository, \(r) name_has_login(r, member_logins))
  ) |>
  classify_repository() |>
  left_join(type_overrides, by = c("organisation", "repository")) |>
  mutate(
    repository_type = if_else(
      !is_private & !is.na(repository_type_by_hand),
      repository_type_by_hand,
      repository_type
    )
  ) |>
  select(-repository_type_by_hand)

# Commits on the default branch of every repository that is not a fork. A fork
# carries the history of the repository it was forked from.
commits_raw <- repos_raw |>
  filter(!is_fork) |>
  mutate(
    commits = map2(organisation, repository, get_commits, .progress = TRUE)
  ) |>
  select(organisation, repository, is_private, commits) |>
  unnest(commits) |>
  mutate(
    visibility = if_else(is_private, "private", "public"),
    class = case_when(
      is_bot ~ "bot",
      is_merge ~ "merge",
      TRUE ~ "counted"
    )
  ) |>
  filter(month <= last_month)

# Tidy data --------------------------------------------------------------------

## github_commits: one row per organisation, visibility and month

month_grid <- orgs_raw |>
  filter(organisation %in% core$organisation) |>
  mutate(start = pmax(first_month, floor_date(created_date, "month"))) |>
  reframe(
    month = seq(start, last_month, by = "month"),
    .by = organisation
  ) |>
  expand_grid(visibility = c("public", "private"))

github_commits <- commits_raw |>
  summarise(
    commits = sum(class == "counted"),
    commits_bot = sum(class == "bot"),
    commits_merge = sum(class == "merge"),
    commits_assisted = sum(class == "counted" & is_assisted),
    repos_active = n_distinct(repository[class == "counted"]),
    .by = c(organisation, visibility, month)
  ) |>
  right_join(month_grid, by = c("organisation", "visibility", "month")) |>
  mutate(across(commits:repos_active, \(x) as.integer(replace_na(x, 0L)))) |>
  mutate(organisation = factor(organisation, levels = core$organisation)) |>
  arrange(organisation, visibility, month) |>
  mutate(organisation = as.character(organisation)) |>
  select(
    organisation, visibility, month, commits, commits_bot, commits_merge,
    commits_assisted, repos_active
  )

## github_repositories: one row per public repository

listed_orgs <- scope |> filter(repositories_listed) |> pull(organisation)

commits_total <- commits_raw |>
  filter(class == "counted") |>
  count(organisation, repository, name = "commits_total")

repos_public <- repos_typed |>
  filter(!is_private, organisation %in% listed_orgs) |>
  mutate(
    contributor_logins = map2(
      organisation, repository,
      \(o, r) get_logins(paste0("repos/", o, "/", r, "/contributors?per_page=100"))
    ),
    has_login = map2_lgl(
      repository, contributor_logins,
      \(r, l) name_has_login(r, unique(c(l, member_logins)))
    )
  )

github_repositories <- repos_public |>
  filter(!has_login) |>
  left_join(commits_total, by = c("organisation", "repository")) |>
  mutate(
    commits_total = case_when(
      is_fork ~ NA_integer_,
      is.na(commits_total) ~ 0L,
      TRUE ~ commits_total
    ),
    license = na_if(license, "NOASSERTION"),
    organisation = factor(organisation, levels = core$organisation)
  ) |>
  # Repositories of student work that carry the degree in their name are named
  # after the student and are left out, and so are repositories of learners.
  filter(
    !str_detect(
      str_to_lower(repository),
      "bsc|msc|sem-proj|semester[- ]project|thesis"
    ),
    repository_type != "learner repository"
  ) |>
  arrange(organisation, created_date, repository) |>
  mutate(organisation = as.character(organisation)) |>
  select(
    organisation, repository, created_date, pushed_date, is_archived, is_fork,
    license, primary_language, repository_type, commits_total
  )

## github_repository_types: number of repositories per organisation,
## visibility, type and year of creation. All repositories are counted, the
## private ones and student work included, and none is named.

github_repository_types <- repos_typed |>
  mutate(
    visibility = if_else(is_private, "private", "public"),
    created_year = as.integer(year(created_date)),
    organisation = factor(organisation, levels = scope$organisation)
  ) |>
  count(organisation, visibility, repository_type, created_year, name = "repos") |>
  arrange(organisation, visibility, repository_type, created_year) |>
  mutate(organisation = as.character(organisation))

## github_organisations: one row per organisation

repo_counts <- repos_raw |>
  summarise(
    repos_public = sum(!is_private),
    repos_private = sum(is_private),
    repos_archived = sum(is_archived),
    .by = organisation
  )

github_organisations <- scope |>
  select(organisation, purpose, commits_counted) |>
  left_join(
    orgs_raw |> select(organisation, created_date, repos_public, repos_private),
    by = "organisation"
  ) |>
  rows_update(
    repo_counts |> select(organisation, repos_public, repos_private),
    by = "organisation"
  ) |>
  left_join(
    repo_counts |> select(organisation, repos_archived),
    by = "organisation"
  ) |>
  left_join(
    github_repositories |> count(organisation, name = "repos_listed"),
    by = "organisation"
  ) |>
  mutate(
    repos_listed = as.integer(replace_na(repos_listed, 0L)),
    snapshot_date = snapshot_date
  )

# Export Data ------------------------------------------------------------------

usethis::use_data(github_organisations, overwrite = TRUE)
usethis::use_data(github_repositories, overwrite = TRUE)
usethis::use_data(github_repository_types, overwrite = TRUE)
usethis::use_data(github_commits, overwrite = TRUE)

export_extdata <- function(data, name) {
  readr::write_csv(data, here::here("inst", "extdata", paste0(name, ".csv")))
  openxlsx::write.xlsx(data, here::here("inst", "extdata", paste0(name, ".xlsx")))
}

export_extdata(github_organisations, "github_organisations")
export_extdata(github_repositories, "github_repositories")
export_extdata(github_repository_types, "github_repository_types")
export_extdata(github_commits, "github_commits")
