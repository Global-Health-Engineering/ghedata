dictionary_names <- function(file) {
  path <- testthat::test_path("..", "..", "data-raw", "dictionary.csv")
  testthat::skip_if_not(file.exists(path), "dictionary.csv is not part of the built package")
  dictionary <- utils::read.csv(path, strip.white = TRUE)
  dictionary$variable_name[dictionary$file_name == file]
}

test_that("people and outputs match the dictionary", {
  expect_identical(names(people), dictionary_names("people.rda"))
  expect_identical(names(outputs), dictionary_names("outputs.rda"))
})

test_that("people holds no title, no name and no identifier", {
  expect_false(any(grepl("title|name|email|login|user|^id$|_id$", names(people))))
  expect_true(all(vapply(people[c("degree", "type", "b_m_student")], function(x) max(nchar(x)), numeric(1)) <= 25))
})

test_that("people and outputs share no key", {
  expect_identical(intersect(names(people), names(outputs)), "year")
  expect_false(nrow(people) == nrow(outputs))
})

test_that("every engagement has a start date, a degree and a type", {
  expect_false(anyNA(people$start_date))
  expect_s3_class(people$start_date, "Date")
  expect_identical(as.numeric(format(people$start_date, "%Y")), as.numeric(people$year))
  expect_true(all(people$degree %in% c("bsc", "msc", "phd", "mob", "staff")))
  expect_false(anyNA(people$type))
  expect_false(is.unsorted(people$start_date))
})

test_that("outputs holds student work with a title and a year", {
  expect_false(anyNA(outputs$title))
  expect_false(any(outputs$title == ""))
  expect_false(anyNA(outputs$year))
  expect_true(all(grepl("^(bsc|msc|phd) ", outputs$output_type)))
  expect_false(any(grepl("@", outputs$title)))
})

test_that("links in outputs point to the ETH Research Collection", {
  links <- outputs$research_collection_link[!is.na(outputs$research_collection_link)]
  expect_true(length(links) > 0)
  expect_true(all(grepl("^https://(www\\.)?research-collection\\.ethz\\.ch/|^https://doi\\.org/10\\.3929/", links)))
})
