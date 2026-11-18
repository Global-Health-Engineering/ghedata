#' github_commits_by_type: Commits per month by repository type
#'
#' Monthly number of commits on the default branches, split by the type of the
#' repository. One row per organisation, visibility, repository type and month
#' in which the repositories of that type had at least one commit by a person,
#' a bot or an automated push. The table
#' holds counts only. It has no row per repository and no information about who
#' made a commit. Private repositories are counted and never named.
#'
#' The columns `commits`, `commits_bot`, `commits_automated` and
#' `commits_assisted` add up to the columns of the same name in
#' [github_commits] for every organisation, visibility and month. Merge commits
#' and forks are left out. The types
#' are the ones of [github_repository_types], which describes the rules. The
#' type is the type on the snapshot date in [github_organisations].
#'
#' @format A tibble with 9 variables
#' \describe{
#'   \item{organisation}{ Login of the GitHub organisation.}
#'   \item{visibility}{ Visibility of the repositories on the snapshot date. Levels: public, private.}
#'   \item{repository_type}{ Type of the repositories, see [github_repository_types] for the levels and the rules.}
#'   \item{month}{ First day of the month (UTC) in which the commits were authored.}
#'   \item{commits}{ Number of commits made by people on the default branches, without merge commits, commits by bots and automated commits. Forks are not counted.}
#'   \item{commits_bot}{ Number of commits authored by bot accounts and by GitHub Actions. Not part of commits.}
#'   \item{commits_automated}{ Number of commits pushed by a device or a script under the account of a person. Not part of commits. See [github_commits].}
#'   \item{commits_assisted}{ Number of commits counted in commits whose message carries a trailer of a coding agent. A lower bound, since the trailer is optional.}
#'   \item{repos_active}{ Number of repositories of that type with at least one commit by a person in that month.}
#' }
#' @source GitHub REST API, read with `data-raw/data_processing_github.R`.
"github_commits_by_type"
