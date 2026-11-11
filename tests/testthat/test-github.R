dictionary_columns <- function(file_name) {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  dictionary[dictionary$file_name == file_name, c("variable_name", "variable_type")]
}

column_types <- function(data) {
  vapply(data, function(x) class(x)[1], character(1), USE.NAMES = FALSE)
}

test_that("the GitHub tables have the documented columns", {
  expect_named(
    github_organisations,
    c(
      "organisation", "purpose", "commits_counted", "created_date",
      "repos_public", "repos_private", "repos_archived", "repos_listed",
      "snapshot_date"
    )
  )
  expect_named(
    github_repositories,
    c(
      "organisation", "repository", "created_date", "pushed_date",
      "is_archived", "is_fork", "license", "primary_language",
      "repository_type", "commits_total"
    )
  )
  expect_named(
    github_repository_types,
    c("organisation", "visibility", "repository_type", "created_year", "repos")
  )
  expect_named(
    github_commits,
    c(
      "organisation", "visibility", "month", "commits", "commits_bot",
      "commits_merge", "commits_assisted", "repos_active"
    )
  )
})

test_that("names and types match the dictionary", {
  tables <- list(
    github_organisations.rda = github_organisations,
    github_repositories.rda = github_repositories,
    github_repository_types.rda = github_repository_types,
    github_commits.rda = github_commits
  )
  for (file_name in names(tables)) {
    dictionary <- dictionary_columns(file_name)
    expect_identical(names(tables[[file_name]]), dictionary$variable_name)
    expect_identical(column_types(tables[[file_name]]), dictionary$variable_type)
  }
})

test_that("no table has a column for a person", {
  all_names <- c(
    names(github_organisations), names(github_repositories),
    names(github_repository_types), names(github_commits)
  )
  expect_false(any(grepl("login|author|email|user|name$|message|sha|hash", all_names)))
})

test_that("the organisations table has one row per organisation", {
  expect_false(anyDuplicated(github_organisations$organisation) > 0)
  expect_length(unique(github_organisations$snapshot_date), 1)
  expect_true(all(github_organisations$repos_public >= 0))
  expect_true(all(github_organisations$repos_private >= 0))
  expect_true(all(github_organisations$repos_listed <= github_organisations$repos_public))
  expect_true(all(github_organisations$repos_listed[!github_organisations$commits_counted] == 0))
})

test_that("the repositories table only lists organisations in scope", {
  counted <- github_organisations$organisation[github_organisations$commits_counted]
  expect_true(all(github_repositories$organisation %in% counted))
  expect_false(
    anyDuplicated(github_repositories[c("organisation", "repository")]) > 0
  )
  listed <- table(github_repositories$organisation)
  expected <- github_organisations$repos_listed[
    match(names(listed), github_organisations$organisation)
  ]
  expect_equal(as.integer(listed), expected)
  expect_true(all(is.na(github_repositories$commits_total) == github_repositories$is_fork))
  expect_true(all(github_repositories$commits_total >= 0, na.rm = TRUE))
})

test_that("commit counts are complete monthly series without negative values", {
  counted <- github_organisations$organisation[github_organisations$commits_counted]
  expect_setequal(unique(github_commits$organisation), counted)
  expect_setequal(unique(github_commits$visibility), c("public", "private"))
  expect_true(all(format(github_commits$month, "%d") == "01"))
  expect_false(
    anyDuplicated(github_commits[c("organisation", "visibility", "month")]) > 0
  )

  count_columns <- c(
    "commits", "commits_bot", "commits_merge", "commits_assisted", "repos_active"
  )
  for (column in count_columns) {
    expect_false(anyNA(github_commits[[column]]))
    expect_true(all(github_commits[[column]] >= 0))
  }
  expect_true(all(github_commits$commits_assisted <= github_commits$commits))
  expect_true(all(github_commits$repos_active <= github_commits$commits))

  snapshot <- github_organisations$snapshot_date[1]
  expect_true(max(github_commits$month) < as.Date(format(snapshot, "%Y-%m-01")))
  expect_true(min(github_commits$month) >= as.Date("2021-08-01"))

  series <- split(
    github_commits$month,
    paste(github_commits$organisation, github_commits$visibility)
  )
  for (months in series) {
    expect_equal(
      sort(months),
      seq(min(months), max(github_commits$month), by = "month")
    )
  }
})

test_that("github_commit_change compares two windows of 12 months", {
  months <- seq(as.Date("2024-01-01"), by = "month", length.out = 24)
  toy <- data.frame(
    organisation = rep(c("a", "b"), each = 48),
    visibility = rep(rep(c("public", "private"), each = 24), times = 2),
    month = rep(months, times = 4),
    commits = c(
      rep(1L, 12), rep(2L, 12),
      rep(1L, 12), rep(10L, 12),
      rep(0L, 12), rep(5L, 12),
      rep(3L, 24)
    )
  )

  all_change <- github_commit_change(data = toy)
  expect_equal(nrow(all_change), 1)
  expect_equal(all_change$commits_previous, 12L + 12L + 0L + 36L)
  expect_equal(all_change$commits_current, 24L + 120L + 60L + 36L)
  expect_equal(all_change$factor, 240 / 60)
  expect_equal(all_change$current_start, as.Date("2025-01-01"))
  expect_equal(all_change$current_end, as.Date("2025-12-01"))
  expect_equal(all_change$previous_start, as.Date("2024-01-01"))
  expect_equal(all_change$previous_end, as.Date("2024-12-01"))

  private_a <- github_commit_change("a", "private", data = toy)
  expect_equal(private_a$commits_current, 120L)
  expect_equal(private_a$commits_previous, 12L)
  expect_equal(private_a$factor, 10)
  expect_equal(private_a$organisation, "a")
  expect_equal(private_a$visibility, "private")

  expect_true(is.na(github_commit_change("b", "public", data = toy)$factor))

  expect_error(github_commit_change("c", data = toy), "not in the data")
  expect_error(github_commit_change(end_month = "2025-12-15", data = toy), "first day")
  expect_error(github_commit_change(end_month = "2025-06-01", data = toy), "cover both windows")
})

test_that("github_commit_change adds up over the scopes of the package data", {
  end_month <- max(github_commits$month)
  total <- github_commit_change(end_month = end_month)
  public <- github_commit_change(visibility = "public", end_month = end_month)
  private <- github_commit_change(visibility = "private", end_month = end_month)
  expect_equal(total$commits_current, public$commits_current + private$commits_current)
  expect_equal(total$commits_previous, public$commits_previous + private$commits_previous)

  per_organisation <- vapply(
    unique(github_commits$organisation),
    function(x) github_commit_change(x, end_month = end_month)$commits_current,
    integer(1)
  )
  expect_equal(sum(per_organisation), total$commits_current)
})

test_that("the repository types add up to the repositories of the organisations", {
  types <- stats::aggregate(
    repos ~ organisation + visibility,
    data = github_repository_types,
    FUN = sum
  )
  for (i in seq_len(nrow(github_organisations))) {
    org <- github_organisations$organisation[i]
    counted <- function(v) {
      sum(types$repos[types$organisation == org & types$visibility == v])
    }
    expect_equal(counted("public"), github_organisations$repos_public[i])
    expect_equal(counted("private"), github_organisations$repos_private[i])
  }
})

test_that("the repository types have known levels and positive counts", {
  levels <- c(
    "learner repository", "organisation profile", "student project",
    "manuscript", "proposal or report", "data package",
    "teaching and training", "website and communication", "template",
    "group management", "software", "hardware", "research project"
  )
  expect_true(all(github_repository_types$repository_type %in% levels))
  expect_true(all(github_repository_types$repos > 0))
  expect_false(anyDuplicated(
    github_repository_types[c("organisation", "visibility", "repository_type", "created_year")]
  ) > 0)
})

test_that("no repository named after a degree and no learner repository is listed", {
  expect_false(any(grepl(
    "bsc|msc|sem-proj|semester[- ]project|thesis",
    tolower(github_repositories$repository)
  )))
  expect_false(any(github_repositories$repository_type == "learner repository"))
})
