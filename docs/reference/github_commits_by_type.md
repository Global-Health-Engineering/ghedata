# github_commits_by_type: Commits per month by repository type

Monthly number of commits on the default branches, split by the type of
the repository. One row per organisation, visibility, repository type
and month in which the repositories of that type had at least one commit
by a person, a bot or an automated push. The table holds counts only. It
has no row per repository and no information about who made a commit.
Private repositories are counted and never named.

## Usage

``` r
github_commits_by_type
```

## Format

A tibble with 9 variables

- organisation:

  Login of the GitHub organisation.

- visibility:

  Visibility of the repositories on the snapshot date. Levels: public,
  private.

- repository_type:

  Type of the repositories, see
  [github_repository_types](https://global-health-engineering.github.io/ghedata/reference/github_repository_types.md)
  for the levels and the rules.

- month:

  First day of the month (UTC) in which the commits were authored.

- commits:

  Number of commits made by people on the default branches, without
  merge commits, commits by bots and automated commits. Forks are not
  counted.

- commits_bot:

  Number of commits authored by bot accounts and by GitHub Actions. Not
  part of commits.

- commits_automated:

  Number of commits pushed by a device or a script under the account of
  a person. Not part of commits. See
  [github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md).

- commits_assisted:

  Number of commits counted in commits whose message carries a trailer
  of a coding agent. A lower bound, since the trailer is optional.

- repos_active:

  Number of repositories of that type with at least one commit by a
  person in that month.

## Source

GitHub REST API, read with `data-raw/data_processing_github.R`.

## Details

The columns `commits`, `commits_bot`, `commits_automated` and
`commits_assisted` add up to the columns of the same name in
[github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md)
for every organisation, visibility and month. Merge commits and forks
are left out. The types are the ones of
[github_repository_types](https://global-health-engineering.github.io/ghedata/reference/github_repository_types.md),
which describes the rules. The type is the type on the snapshot date in
[github_organisations](https://global-health-engineering.github.io/ghedata/reference/github_organisations.md).
