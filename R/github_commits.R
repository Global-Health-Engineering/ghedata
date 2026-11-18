#' github_commits: Commits per month in the GitHub organisations of Global Health Engineering
#'
#' Monthly number of commits on the default branches of all repositories of an
#' organisation, separately for public and private repositories. The table holds
#' counts only. It has no row per repository and no information about who made
#' a commit. Private repositories are counted and never named.
#'
#' Every commit on a default branch falls into one of four columns: `commits`
#' (made by a person, the number to use), `commits_bot` (authored by a bot
#' account or a GitHub Action), `commits_automated` (pushed by a device or a
#' script under the account of a person) or `commits_merge` (merge commits). Forks are not counted. The month is the
#' month of the author date in UTC. Every organisation has a row for every
#' month from August 2021, or from the month it was created, up to the last
#' complete month before the snapshot date in [github_organisations].
#' Visibility is the visibility on the snapshot date.
#'
#' Use [github_commit_change()] to compare the last 12 complete months with the
#' 12 months before.
#'
#' @format A tibble with 9 variables
#' \describe{
#'   \item{organisation}{ Login of the GitHub organisation.}
#'   \item{visibility}{ Visibility of the repositories on the snapshot date. Levels: public, private.}
#'   \item{month}{ First day of the month (UTC) in which the commits were authored.}
#'   \item{commits}{ Number of commits made by people on the default branches, without merge commits, commits by bots and automated commits. Forks are not counted.}
#'   \item{commits_bot}{ Number of commits authored by bot accounts and by GitHub Actions. Not part of commits.}
#'   \item{commits_automated}{ Number of commits pushed by a device or a script under the account of a person, such as sensor data on a schedule. Recognised by the first line of the message with the patterns in `data-raw/github_automated_commits.csv`. Not part of commits.}
#'   \item{commits_merge}{ Number of merge commits (more than one parent) that are neither by bots nor automated. Not part of commits.}
#'   \item{commits_assisted}{ Number of commits counted in commits whose message carries a trailer of a coding agent (Co-Authored-By for Claude or Copilot, Assisted-by, or the Claude Code line). A lower bound, since the trailer is optional.}
#'   \item{repos_active}{ Number of repositories with at least one commit counted in commits in that month.}
#' }
#' @source GitHub REST API, read with `data-raw/data_processing_github.R`.
"github_commits"
