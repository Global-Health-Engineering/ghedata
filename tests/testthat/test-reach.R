dictionary_columns <- function(file_name) {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  dictionary[dictionary$file_name == file_name, c("variable_name", "variable_type")]
}

test_that("the reach table matches the dictionary", {
  tables <- list(zenodo_records.rda = zenodo_records)
  for (file_name in names(tables)) {
    dictionary <- dictionary_columns(file_name)
    expect_identical(names(tables[[file_name]]), dictionary$variable_name)
    expect_identical(
      vapply(tables[[file_name]], function(x) class(x)[1], character(1), USE.NAMES = FALSE),
      dictionary$variable_type
    )
  }
})

test_that("the reach table has no column for a person", {
  all_names <- names(zenodo_records)
  expect_false(any(grepl("orcid|author|creator|email|user|name$", all_names)))
})

test_that("each record is listed once with counts that are not negative", {
  expect_false(anyDuplicated(zenodo_records$record_id) > 0)
  expect_length(unique(zenodo_records$snapshot_date), 1)
  for (column in c("views", "unique_views", "downloads", "unique_downloads")) {
    expect_false(anyNA(zenodo_records[[column]]))
    expect_true(all(zenodo_records[[column]] >= 0))
  }
  expect_true(all(zenodo_records$unique_views <= zenodo_records$views))
  expect_true(all(zenodo_records$unique_downloads <= zenodo_records$downloads))
})

test_that("the Zenodo records start in 2021", {
  expect_true(min(zenodo_records$publication_date) >= as.Date("2021-01-01"))
})
