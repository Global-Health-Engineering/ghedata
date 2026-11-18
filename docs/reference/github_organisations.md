# github_organisations: GitHub organisations of Global Health Engineering

The GitHub organisations the group works in, with the number of public
and private repositories on the snapshot date. Commits are counted in
[github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md)
for the organisations with `commits_counted == TRUE`. Teaching
organisations, which hold one repository per student, appear with their
repository counts only.

## Usage

``` r
github_organisations
```

## Format

A tibble with 9 variables

- organisation:

  Login of the GitHub organisation. An organisation account, not a
  person.

- purpose:

  What the organisation is used for. Levels: research, data publishing,
  development, events, training, teaching.

- commits_counted:

  TRUE when the commits of the organisation are counted in
  github_commits. FALSE for teaching organisations with one repository
  per student, which appear with repository counts only.

- created_date:

  Date the organisation was created on GitHub.

- repos_public:

  Number of public repositories on the snapshot date.

- repos_private:

  Number of private repositories on the snapshot date. A count only,
  private repositories are never named.

- repos_archived:

  Number of archived repositories on the snapshot date. NA for
  organisations whose commits are not counted.

- repos_listed:

  Number of public repositories of the organisation that are rows of
  github_repositories.

- snapshot_date:

  Date (UTC) on which the data was read from the GitHub API.

## Source

GitHub REST API, read with `data-raw/data_processing_github.R`. The list
of organisations is kept by hand in `data-raw/github_organisations.csv`.
