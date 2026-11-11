#' github_commits: Commits per month in the GitHub organisations of Global Health Engineering
#'
#' Monthly number of commits on the default branches of all repositories of an
#' organisation, separately for public and private repositories. The table holds
#' counts only. It has no row per repository and no information about who made
#' a commit. Private repositories are counted and never named.
#'
#' Every commit on a default branch falls into one of three columns: `commits`
#' (the number to use), `commits_bot` (authored by a bot account) or
#' `commits_merge` (merge commits). Forks are not counted. The month is the
#' month of the author date in UTC. Every organisation has a row for every
#' month from August 2021, or from the month it was created, up to the last
#' complete month before the snapshot date in [github_organisations].
#' Visibility is the visibility on the snapshot date.
#'
#' Use [github_commit_change()] to compare the last 12 complete months with the
#' 12 months before.
#'
#' @format A tibble with 8 variables
#' \describe{
#'   \item{organisation}{ Login of the GitHub organisation.}
#'   \item{visibility}{ Visibility of the repositories on the snapshot date. Levels: public, private.}
#'   \item{month}{ First day of the month (UTC) in which the commits were authored.}
#'   \item{commits}{ Number of commits on the default branches, without merge commits and commits by bots. Forks are not counted.}
#'   \item{commits_bot}{ Number of commits authored by bot accounts. Not part of commits.}
#'   \item{commits_merge}{ Number of merge commits (more than one parent) not authored by bots. Not part of commits.}
#'   \item{commits_assisted}{ Number of commits counted in commits whose message carries a trailer of a coding agent (Co-Authored-By for Claude or Copilot, Assisted-by, or the Claude Code line). A lower bound, since the trailer is optional.}
#'   \item{repos_active}{ Number of repositories with at least one commit counted in commits in that month.}
#' }
#' @source GitHub REST API, read with `data-raw/data_processing_github.R`.
"github_commits"
