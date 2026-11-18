#' github_commits_by_person: Commits per person over twelve months
#'
#' The number of commits each group member made in the last twelve full months
#' of [github_commits], and how many of them carry an agent trailer. Only
#' people who were part of the group in these months are counted, with all
#' their identities merged. Commits in the training organisations (workshop
#' exercises) are not counted; the column workshop says who took part in a
#' workshop. A person with 0 commits took part in a workshop and has no commit
#' outside it. A person is
#' a rank; no login, name or email address is part of the data. In a small
#' group a rank can still point to a person for someone who knows the group.
#'
#' @format A tibble with 7 variables
#' \describe{
#'   \item{person_rank}{ Rank of the person by number of commits, 1 for the most commits. Stands in for the person; no login or name is kept.}
#'   \item{commits}{ Commits by the person in the twelve months from first_month to last_month, counted as in github_commits (no bots, no automated pushes, no merge commits) and without commits in the training organisations.}
#'   \item{commits_assisted}{ Number of these commits that carry an agent trailer.}
#'   \item{share_assisted}{ commits_assisted divided by commits. Empty for a person with 0 commits.}
#'   \item{workshop}{ Part in the workshops of the group in the twelve months: participant (has commits in a training organisation), trainer (ran the workshops) or none.}
#'   \item{first_month}{ First month of the twelve months counted.}
#'   \item{last_month}{ Last month of the twelve months counted.}
#' }
#' @source GitHub REST API, read with
#'   `data-raw/data_processing_github_people.R`.
"github_commits_by_person"
