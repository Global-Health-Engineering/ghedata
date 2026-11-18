# github_repository_types: Number of GitHub repositories by type

One row per organisation, visibility, repository type and year of
creation, with the number of repositories. All repositories of all
organisations in
[github_organisations](https://global-health-engineering.github.io/ghedata/reference/github_organisations.md)
are counted, private repositories and student work included. The table
holds no repository name.

## Usage

``` r
github_repository_types
```

## Format

A tibble with 5 variables

- organisation:

  Login of the GitHub organisation.

- visibility:

  Visibility of the repositories on the snapshot date. Levels: public,
  private.

- repository_type:

  Type of the repositories. Levels: learner repository (one repository
  per learner in a course or workshop), organisation profile, data
  package (R package with a data folder), student project (name or
  description points to a thesis or semester project), manuscript,
  proposal or report, teaching and training (course and workshop
  material), website and communication, template, group management,
  software (other R and Python packages), hardware, research project
  (everything else).

- created_year:

  Year the repositories were created.

- repos:

  Number of repositories.

## Source

GitHub REST API, read with `data-raw/data_processing_github.R`.

## Details

The type comes from rules on the repository name, the files at the top
level of the repository, its topics, its main language and the purpose
of its organisation. The first rule that matches decides, in the order
of the levels below. The rules are rough: a thesis project that is named
after its topic counts as a research project or as hardware. Single
public repositories are corrected by hand in
`data-raw/github_repository_types.csv`.
