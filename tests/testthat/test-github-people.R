people_dictionary <- function(file_name) {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  dictionary[dictionary$file_name == file_name, c("variable_name", "variable_type")]
}

column_types <- function(table) {
  types <- vapply(table, function(x) class(x)[1], character(1), USE.NAMES = FALSE)
  types[types == "numeric"] <- "double"
  tolower(types)
}

test_that("the tables of commits by people match the dictionary", {
  tables <- list(
    github_commits_by_person.rda = github_commits_by_person,
    github_commits_by_members.rda = github_commits_by_members
  )
  for (file_name in names(tables)) {
    dictionary <- people_dictionary(file_name)
    expect_identical(names(tables[[file_name]]), dictionary$variable_name)
    expect_identical(column_types(tables[[file_name]]), dictionary$variable_type)
  }
})

test_that("the tables of commits by people name nobody", {
  all_names <- c(names(github_commits_by_person), names(github_commits_by_members))
  expect_false(any(grepl("login|author|email|user|name$", all_names)))
})

test_that("people are ranked by their commits", {
  by_person <- github_commits_by_person
  expect_identical(by_person$person_rank, seq_len(nrow(by_person)))
  expect_false(is.unsorted(rev(by_person$commits)))
  expect_true(all(by_person$commits >= 0))
  expect_true(all(by_person$commits_assisted >= 0))
  expect_true(all(by_person$commits_assisted <= by_person$commits))
  with_commits <- by_person$commits > 0
  expect_equal(
    by_person$share_assisted[with_commits],
    (by_person$commits_assisted / by_person$commits)[with_commits],
    tolerance = 0.006
  )
  expect_true(all(by_person$workshop %in% c("trainer", "participant", "none")))
  expect_true(all(by_person$first_month <= by_person$last_month))
})

test_that("commits by members cover the months of the commits table once", {
  by_members <- github_commits_by_members
  expect_false(anyDuplicated(by_members$month) > 0)
  expect_setequal(by_members$month, github_commits$month)
  expect_false(anyNA(by_members$lookup_complete))
  expect_true(all(by_members$commits >= 0))
  expect_true(all(by_members$commits_assisted >= 0))
  expect_true(all(by_members$commits_assisted <= by_members$commits))
})

test_that("the months with a complete lookup are the last ones without a gap", {
  by_members <- github_commits_by_members[order(github_commits_by_members$month), ]
  complete <- which(by_members$lookup_complete)
  expect_true(length(complete) > 0)
  expect_identical(complete, seq(min(complete), nrow(by_members)))
  expect_true(all(
    github_commits_by_person$first_month >= by_members$month[min(complete)]
  ))
})
