#' Compare commits of the last 12 complete months with the 12 months before
#'
#' Sums the `commits` column of [github_commits] over two windows of 12
#' calendar months each: the 12 months that end with `end_month`, and the 12
#' months before them. The scope can be narrowed to organisations and to public
#' or private repositories. Months before an organisation was created count as
#' zero commits.
#'
#' @param organisation Character vector of organisation logins as they appear
#'   in [github_commits]. `NULL` (the default) uses all organisations.
#' @param visibility `"public"`, `"private"` or `NULL` (the default) for both.
#' @param end_month Last month of the current window, as a Date or a string
#'   such as `"2026-10-01"`. `NULL` (the default) uses the last month in `data`.
#' @param data A data frame with the columns of [github_commits].
#'
#' @return A tibble with one row: the scope, the first and last month of both
#'   windows, `commits_current`, `commits_previous` and `factor` (current
#'   divided by previous, `NA` when the previous window has no commits).
#' @export
#' @importFrom dplyr tibble
#'
#' @examples
#' # All organisations, public and private repositories
#' github_commit_change()
#'
#' # Private repositories of one organisation
#' github_commit_change(
#'   organisation = "Global-Health-Engineering",
#'   visibility = "private"
#' )
#'
#' # A fixed window, so the result does not change when the data is refreshed
#' github_commit_change(end_month = "2026-10-01")
github_commit_change <- function(organisation = NULL,
                                 visibility = NULL,
                                 end_month = NULL,
                                 data = ghedata::github_commits) {
  if (is.null(end_month)) {
    end_month <- max(data$month)
  }
  end_month <- as.Date(end_month)
  if (format(end_month, "%d") != "01") {
    stop("`end_month` must be the first day of a month.", call. = FALSE)
  }

  months <- seq(end_month, by = "-1 month", length.out = 24)
  current <- months[1:12]
  previous <- months[13:24]

  # Checked on the whole table. An organisation that is younger than the two
  # windows has no rows for the months before it was created, which count as
  # zero commits.
  if (min(previous) < min(data$month) || end_month > max(data$month)) {
    stop("The data does not cover both windows.", call. = FALSE)
  }

  if (!is.null(organisation)) {
    unknown <- setdiff(organisation, unique(data$organisation))
    if (length(unknown) > 0) {
      stop(
        "Organisation not in the data: ",
        paste(unknown, collapse = ", "),
        call. = FALSE
      )
    }
    data <- data[data$organisation %in% organisation, ]
  }

  if (!is.null(visibility)) {
    visibility <- match.arg(visibility, c("public", "private"))
    data <- data[data$visibility == visibility, ]
  }

  commits_current <- sum(data$commits[data$month %in% current])
  commits_previous <- sum(data$commits[data$month %in% previous])

  tibble(
    organisation = if (is.null(organisation)) "all" else paste(organisation, collapse = ", "),
    visibility = if (is.null(visibility)) "all" else visibility,
    current_start = min(current),
    current_end = max(current),
    previous_start = min(previous),
    previous_end = max(previous),
    commits_current = as.integer(commits_current),
    commits_previous = as.integer(commits_previous),
    factor = if (commits_previous > 0) commits_current / commits_previous else NA_real_
  )
}
