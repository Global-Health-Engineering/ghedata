# github_repositories: Public GitHub repositories of Global Health Engineering

One row per public repository in the organisations whose repositories
are listed. Private repositories are not in this table. Public
repositories whose name contains the user name of a person are left out
as well, and so are repositories that carry a degree in their name
(student work) and all repositories of organisations that name exercises
after the people who work on them. The column `repos_listed` of
[github_organisations](https://global-health-engineering.github.io/ghedata/reference/github_organisations.md)
says how many repositories of an organisation are in this table.

## Usage

``` r
github_repositories
```

## Format

A tibble with 10 variables

- organisation:

  Login of the GitHub organisation that owns the repository.

- repository:

  Name of the public repository.

- created_date:

  Date the repository was created.

- pushed_date:

  Date of the last push to the repository before the snapshot date.

- is_archived:

  TRUE when the repository is archived.

- is_fork:

  TRUE when the repository is a fork of another repository.

- license:

  SPDX identifier of the licence that GitHub detects. NA when there is
  none or GitHub cannot name it.

- primary_language:

  Main language of the repository as detected by GitHub. NA when there
  is none.

- repository_type:

  Type of the repository, see
  [github_repository_types](https://global-health-engineering.github.io/ghedata/reference/github_repository_types.md)
  for the rules. Levels in this table: data package, student project,
  hardware, manuscript, organisation profile, proposal or report,
  research project, software, teaching and training, template, website
  and communication, group management.

- commits_total:

  Number of commits on the default branch up to the last complete month
  before the snapshot date, made by people, without merge commits,
  commits by bots and automated commits. NA for forks.

## Source

GitHub REST API, read with `data-raw/data_processing_github.R`.

## Details

The table has a total number of commits per repository and no monthly
series, because most repositories have one contributor.
