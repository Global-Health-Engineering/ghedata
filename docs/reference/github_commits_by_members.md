# github_commits_by_members: Commits by group members per month

The number of commits that group members made per month, and how many of
them carry an agent trailer. Counted as in
[github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md)
(no bots, no automated pushes, no merge commits), with two differences:
commits by people outside the group are left out, and so are commits in
the training organisations (workshop exercises). Who is a group member
comes from a lookup that is not part of the package. The lookup is
complete for the last 24 months; in the months before, everyone counts
as a group member except the people the lookup names as outside the
group.

## Usage

``` r
github_commits_by_members
```

## Format

A tibble with 4 variables

- month:

  First day of the month.

- commits:

  Commits by group members in the month, without commits in the training
  organisations.

- commits_assisted:

  Number of these commits that carry an agent trailer.

- lookup_complete:

  TRUE for the months in which every person was checked against the
  lookup of group members.

## Source

GitHub REST API, read with `data-raw/data_processing_github_people.R`.
