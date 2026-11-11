#' github_repositories: Public GitHub repositories of Global Health Engineering
#'
#' One row per public repository in the organisations whose repositories are
#' listed. Private repositories are not in this table. Public repositories
#' whose name contains the user name of a person are left out as well, and so
#' are repositories of student work and all repositories of organisations that
#' name exercises after the people who work on them. The column `repos_listed` of [github_organisations] says
#' how many repositories of an organisation are in this table.
#'
#' The table has a total number of commits per repository and no monthly
#' series, because most repositories have one contributor.
#'
#' @format A tibble with 10 variables
#' \describe{
#'   \item{organisation}{ Login of the GitHub organisation that owns the repository.}
#'   \item{repository}{ Name of the public repository.}
#'   \item{created_date}{ Date the repository was created.}
#'   \item{pushed_date}{ Date of the last push to the repository before the snapshot date.}
#'   \item{is_archived}{ TRUE when the repository is archived.}
#'   \item{is_fork}{ TRUE when the repository is a fork of another repository.}
#'   \item{license}{ SPDX identifier of the licence that GitHub detects. NA when there is none or GitHub cannot name it.}
#'   \item{primary_language}{ Main language of the repository as detected by GitHub. NA when there is none.}
#'   \item{repository_type}{ Type derived from the repository name. Levels: template, manuscript, proposal, website, other.}
#'   \item{commits_total}{ Number of commits on the default branch up to the last complete month before the snapshot date, without merge commits and commits by bots. NA for forks.}
#' }
#' @source GitHub REST API, read with `data-raw/data_processing_github.R`.
"github_repositories"
