test_that("computational matches the dictionary", {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  expect_identical(names(computational), dictionary$variable_name[dictionary$file_name == "computational.rda"])
})

test_that("computational holds counts and no row per respondent", {
  expect_false("id" %in% names(computational))
  expect_false(anyDuplicated(computational[c("question", "answer")]) > 0)
  expect_true(all(computational$n >= 1))
  expect_true(all(computational$n <= computational$respondents))
  expect_identical(length(unique(computational$respondents)), 1L)
})

test_that("questions with one answer add up to the number of respondents", {
  several <- c("other_languages", "ides_used", "llm_tools_used")
  single <- computational[!computational$question %in% several, ]
  totals <- tapply(single$n, single$question, sum)
  expect_true(all(totals == computational$respondents[1]))
})

test_that("picks are not split inside brackets", {
  expect_false(any(grepl("^[^(]*\\)", computational$answer)))
  expect_false(any(grepl("\\([^)]*$", computational$answer)))
})
