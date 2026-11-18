proposals_dictionary <- function() {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  dictionary[dictionary$file_name == "proposals.rda", c("variable_name", "variable_type")]
}

column_types <- function(table) {
  types <- vapply(table, function(x) class(x)[1], character(1), USE.NAMES = FALSE)
  types[types == "numeric"] <- "double"
  tolower(types)
}

test_that("the proposals table matches the dictionary", {
  dictionary <- proposals_dictionary()
  expect_identical(names(proposals), dictionary$variable_name)
  expect_identical(column_types(proposals), dictionary$variable_type)
})

test_that("the proposals table has no column for a person or a title", {
  expect_false(any(grepl("applicant|author|email|name$|title", names(proposals))))
})

test_that("each proposal is listed once with a known status", {
  expect_false(anyNA(proposals$proposal_id))
  expect_false(anyDuplicated(proposals$proposal_id) > 0)
  expect_false(anyNA(proposals$status))
  expect_true(all(proposals$status %in% c("accepted", "rejected", "submitted", "withdrawn")))
})

test_that("the dates of a proposal agree with each other", {
  expect_false(anyNA(proposals$submitted_date))
  expect_identical(
    proposals$submitted_year,
    as.integer(format(proposals$submitted_date, "%Y"))
  )
  # An answer dated before the submission is an entry error in the source, so
  # the days are left empty for it.
  days <- as.integer(proposals$answer_date - proposals$submitted_date)
  counted <- !is.na(proposals$days_to_answer)
  expect_identical(proposals$days_to_answer[counted], days[counted])
  expect_true(all(proposals$days_to_answer[counted] >= 0))
  expect_true(all(is.na(days[!counted]) | days[!counted] < 0))
})

test_that("amounts in CHF follow the budget and the currency", {
  # A budget without a currency cannot be converted and stays out of the CHF
  # column.
  convertible <- !is.na(proposals$budget) & !is.na(proposals$currency)
  expect_identical(!is.na(proposals$budget_chf), convertible)
  expect_true(all(proposals$budget_chf[convertible] > 0))
  in_chf <- convertible & proposals$currency == "CHF"
  expect_equal(proposals$budget_chf[in_chf], proposals$budget[in_chf])
  expect_true(all(is.na(proposals$rate_date[in_chf])))
  converted <- convertible & proposals$currency != "CHF"
  expect_false(anyNA(proposals$rate_date[converted]))
})

test_that("the yes or no columns have no gaps", {
  for (column in c("snsf", "lead_data_steward", "co_lead_external", "partner_organisation")) {
    expect_false(anyNA(proposals[[column]]))
  }
})
