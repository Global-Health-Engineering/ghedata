# Compare commits of the last 12 complete months with the 12 months before

Sums the `commits` column of
[github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md)
over two windows of 12 calendar months each: the 12 months that end with
`end_month`, and the 12 months before them. The scope can be narrowed to
organisations and to public or private repositories. Months before an
organisation was created count as zero commits.

## Usage

``` r
github_commit_change(
  organisation = NULL,
  visibility = NULL,
  end_month = NULL,
  data = ghedata::github_commits
)
```

## Arguments

- organisation:

  Character vector of organisation logins as they appear in
  [github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md).
  `NULL` (the default) uses all organisations.

- visibility:

  `"public"`, `"private"` or `NULL` (the default) for both.

- end_month:

  Last month of the current window, as a Date or a string such as
  `"2026-10-01"`. `NULL` (the default) uses the last month in `data`.

- data:

  A data frame with the columns of
  [github_commits](https://global-health-engineering.github.io/ghedata/reference/github_commits.md).

## Value

A tibble with one row: the scope, the first and last month of both
windows, `commits_current`, `commits_previous` and `factor` (current
divided by previous, `NA` when the previous window has no commits).

## Examples

``` r
# All organisations, public and private repositories
github_commit_change()
#> # A tibble: 1 × 9
#>   organisation visibility current_start current_end previous_start previous_end
#>   <chr>        <chr>      <date>        <date>      <date>         <date>      
#> 1 all          all        2025-11-01    2026-10-01  2024-11-01     2025-10-01  
#> # ℹ 3 more variables: commits_current <int>, commits_previous <int>,
#> #   factor <dbl>

# Private repositories of one organisation
github_commit_change(
  organisation = "Global-Health-Engineering",
  visibility = "private"
)
#> # A tibble: 1 × 9
#>   organisation  visibility current_start current_end previous_start previous_end
#>   <chr>         <chr>      <date>        <date>      <date>         <date>      
#> 1 Global-Healt… private    2025-11-01    2026-10-01  2024-11-01     2025-10-01  
#> # ℹ 3 more variables: commits_current <int>, commits_previous <int>,
#> #   factor <dbl>

# A fixed window, so the result does not change when the data is refreshed
github_commit_change(end_month = "2026-10-01")
#> # A tibble: 1 × 9
#>   organisation visibility current_start current_end previous_start previous_end
#>   <chr>        <chr>      <date>        <date>      <date>         <date>      
#> 1 all          all        2025-11-01    2026-10-01  2024-11-01     2025-10-01  
#> # ℹ 3 more variables: commits_current <int>, commits_previous <int>,
#> #   factor <dbl>
```
