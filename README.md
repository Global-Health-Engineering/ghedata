
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghedata

<!-- badges: start -->

[![License: CC BY
4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

<!-- badges: end -->

The goal of ghedata is to share data resources that document the work of
the Global Health Engineering group at ETH Zurich. The data can be used
for research, teaching, and learning purposes. The data is available as
an R data package, in CSV and XLSX formats.

## Installation

You can install the development version of ghedata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("global-health-engineering/ghedata")
```

``` r
## Run the following code in console if you don't have the packages
## install.packages(c("dplyr", "knitr", "readr", "stringr", "gt", "kableExtra"))
library(dplyr)
library(knitr)
library(readr)
library(stringr)
library(gt)
library(kableExtra)
library(ggthemes)
library(ggplot2)
```

Alternatively, you can download the individual datasets as a CSV or XLSX
file from the table below.

1.  Click Download CSV. A window opens that displays the CSV in your
    browser.
2.  Right-click anywhere inside the window and select “Save Page As…”.
3.  Save the file in a folder of your choice.

| dataset | CSV | XLSX |
|:---|:---|:---|
| people | [Download CSV](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/people.csv) | [Download XLSX](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/people.xlsx) |
| computational | [Download CSV](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/computational.csv) | [Download XLSX](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/computational.xlsx) |
| github_organisations | [Download CSV](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_organisations.csv) | [Download XLSX](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_organisations.xlsx) |
| github_repositories | [Download CSV](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_repositories.csv) | [Download XLSX](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_repositories.xlsx) |
| github_commits | [Download CSV](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_commits.csv) | [Download XLSX](https://github.com/global-health-engineering/ghedata/raw/main/inst/extdata/github_commits.xlsx) |

## Data

The package provides access to one data resource.

``` r
library(ghedata)
```

### people

The dataset `people` contains data about people that have worked for the
group. This includes staff, as well as undergraduate student projects.

It has 186 observations and 7 variables.

``` r
people |> 
  head(3) |> 
  gt::gt() |>
  gt::as_raw_html()
```

<div id="stnhtbmnka" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
  &#10;  <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false" style="-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'; display: table; border-collapse: collapse; line-height: normal; margin-left: auto; margin-right: auto; color: #333333; font-size: 16px; font-weight: normal; font-style: normal; background-color: #FFFFFF; width: auto; border-top-style: solid; border-top-width: 2px; border-top-color: #A8A8A8; border-right-style: none; border-right-width: 2px; border-right-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #A8A8A8; border-left-style: none; border-left-width: 2px; border-left-color: #D3D3D3;" bgcolor="#FFFFFF">
  <thead style="border-style: none;">
    <tr class="gt_col_headings" style="border-style: none; border-top-style: solid; border-top-width: 2px; border-top-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3;">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="title" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">title</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="degree" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">degree</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="type" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">type</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="b_m_student" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">b_m_student</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="start_date" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" bgcolor="#FFFFFF" valign="bottom" align="right">start_date</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="year" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" bgcolor="#FFFFFF" valign="bottom" align="right">year</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="thesis_title" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: normal; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">thesis_title</th>
    </tr>
  </thead>
  <tbody class="gt_table_body" style="border-style: none; border-top-style: solid; border-top-width: 2px; border-top-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #D3D3D3;">
    <tr style="border-style: none;"><td headers="title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">2021-bsc-thesis-141444</td>
<td headers="degree" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">bsc</td>
<td headers="type" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">thesis</td>
<td headers="b_m_student" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">yes</td>
<td headers="start_date" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2021-02-01</td>
<td headers="year" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2021</td>
<td headers="thesis_title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">Self-cleaning Preliminary Screening Mechanisms to Improve Health and Wastewater Treatment Efficiency in Low-income Countries</td></tr>
    <tr style="border-style: none;"><td headers="title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">2021-msc-thesis-565554</td>
<td headers="degree" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">msc</td>
<td headers="type" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">thesis</td>
<td headers="b_m_student" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">yes</td>
<td headers="start_date" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2021-09-19</td>
<td headers="year" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2021</td>
<td headers="thesis_title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">Barriers to successful data management in the Global South: Case Study of Malawi</td></tr>
    <tr style="border-style: none;"><td headers="title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">2022-phd-thesis-466263</td>
<td headers="degree" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">phd</td>
<td headers="type" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">thesis</td>
<td headers="b_m_student" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">no</td>
<td headers="start_date" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2022-01-25</td>
<td headers="year" class="gt_row gt_right" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: right; font-variant-numeric: tabular-nums;" valign="middle" align="right">2022</td>
<td headers="thesis_title" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-width: 1px; border-top-color: #D3D3D3; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left;" valign="middle" align="left">Extent and markers of open waste burning</td></tr>
  </tbody>
  &#10;</table>
</div>

For an overview of the variable names, see the following table.

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:200px; ">

<table class="table table-striped" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_name
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_type
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

description
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

project_id
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Unique identifier for each person using a combination of other metadata.
Folder name on Google Drive.
</td>

</tr>

<tr>

<td style="text-align:left;">

degree
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Categorical variable with four levels: bsc, msc, phd, staff.
</td>

</tr>

<tr>

<td style="text-align:left;">

type
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Categorical variable with six levels: hiwi, intern, post-doc,
scientific-assitant, sem-proj, thesis.
</td>

</tr>

<tr>

<td style="text-align:left;">

b_m_student
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Binary variable to identify if person is BSc or MSc students. Levels:
yes, no.
</td>

</tr>

<tr>

<td style="text-align:left;">

start_date
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

Start date of the person.
</td>

</tr>

<tr>

<td style="text-align:left;">

year
</td>

<td style="text-align:left;">

numeric
</td>

<td style="text-align:left;">

Year of the start date.
</td>

</tr>

<tr>

<td style="text-align:left;">

thesis_title
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Title of the thesis.
</td>

</tr>

</tbody>

</table>

</div>

### GitHub tables

Three tables describe the work of the group on GitHub. They hold counts
only and no information about who made a commit.

- `github_organisations` has 12 rows, one per organisation, with the
  number of public and private repositories.
- `github_repositories` has 212 rows, one per public repository.
- `github_commits` has 486 rows, one per organisation, visibility and
  month, with the number of commits on the default branches. Private
  repositories are counted and never named.

The data was read from GitHub on 2026-11-11.

`github_commit_change()` compares the commits of the last 12 complete
months with the 12 months before.

``` r
github_commit_change() |> 
  knitr::kable(digits = 1)
```

| organisation | visibility | current_start | current_end | previous_start | previous_end | commits_current | commits_previous | factor |
|:---|:---|:---|:---|:---|:---|---:|---:|---:|
| all | all | 2025-11-01 | 2026-10-01 | 2024-11-01 | 2025-10-01 | 4887 | 2183 | 2.2 |

For an overview of the variable names, see the following table.

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:200px; ">

<table class="table table-striped" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

file_name
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_name
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_type
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

description
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

organisation
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Login of the GitHub organisation. An organisation account, not a person.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

purpose
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

What the organisation is used for. Levels: research, data publishing,
development, events, training, teaching.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

commits_counted
</td>

<td style="text-align:left;">

logical
</td>

<td style="text-align:left;">

TRUE when the commits of the organisation are counted in github_commits.
FALSE for teaching organisations with one repository per student, which
appear with repository counts only.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

created_date
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

Date the organisation was created on GitHub.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

repos_public
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of public repositories on the snapshot date.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

repos_private
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of private repositories on the snapshot date. A count only,
private repositories are never named.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

repos_archived
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of archived repositories on the snapshot date. NA for
organisations whose commits are not counted.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

repos_listed
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of public repositories of the organisation that are rows of
github_repositories.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_organisations.rda
</td>

<td style="text-align:left;">

snapshot_date
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

Date (UTC) on which the data was read from the GitHub API.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

organisation
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Login of the GitHub organisation that owns the repository.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

repository
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Name of the public repository.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

created_date
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

Date the repository was created.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

pushed_date
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

Date of the last push to the repository before the snapshot date.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

is_archived
</td>

<td style="text-align:left;">

logical
</td>

<td style="text-align:left;">

TRUE when the repository is archived.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

is_fork
</td>

<td style="text-align:left;">

logical
</td>

<td style="text-align:left;">

TRUE when the repository is a fork of another repository.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

license
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

SPDX identifier of the licence that GitHub detects. NA when there is
none or GitHub cannot name it.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

primary_language
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Main language of the repository as detected by GitHub. NA when there is
none.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

repository_type
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Type derived from the repository name. Levels: template, manuscript,
proposal, website, other.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_repositories.rda
</td>

<td style="text-align:left;">

commits_total
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of commits on the default branch up to the last complete month
before the snapshot date, without merge commits and commits by bots. NA
for forks.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

organisation
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Login of the GitHub organisation.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

visibility
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Visibility of the repositories on the snapshot date. Levels: public,
private.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

month
</td>

<td style="text-align:left;">

Date
</td>

<td style="text-align:left;">

First day of the month (UTC) in which the commits were authored.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

commits
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of commits on the default branches, without merge commits and
commits by bots. Forks are not counted.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

commits_bot
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of commits authored by bot accounts. Not part of commits.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

commits_merge
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of merge commits (more than one parent) not authored by bots. Not
part of commits.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

commits_assisted
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of commits counted in commits whose message carries a trailer of
a coding agent (Co-Authored-By for Claude or Copilot, Assisted-by, or
the Claude Code line). A lower bound, since the trailer is optional.
</td>

</tr>

<tr>

<td style="text-align:left;">

github_commits.rda
</td>

<td style="text-align:left;">

repos_active
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of repositories with at least one commit counted in commits in
that month.
</td>

</tr>

</tbody>

</table>

</div>

## Example

``` r
library(ghedata)

undergrad_students <- people |> 
  filter(b_m_student == "yes") |>
  filter(!is.na(thesis_title)) 
```

So far, GHE has supervised 154 projects of which 42 were done by BSc and
112 by MSc students.

``` r
undergrad_students |> 
  count(degree, year) |> 
  ggplot(aes(x = year, y = n, label = n, fill = degree, color = degree)) +
  geom_col(position = "dodge") +
  geom_text(position=position_dodge(width=0.9), 
            vjust=-0.5,
            show.legend = FALSE) +
  labs(x = "",
       y = "Number of students") +
  scale_fill_colorblind() +
  scale_color_colorblind() +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.text.y = element_blank())
```

<img src="man/figures/README-unnamed-chunk-8-1.png" alt="" width="100%" style="display: block; margin: auto;" />

## License

Data are available as
[CC-BY](https://github.com/global-health-engineering/%7B%7B%7Bpackagename%7D%7D%7D/blob/main/LICENSE.md).

## Citation

Please cite this package using:

``` r
citation("ghedata")
#> To cite package 'ghedata' in publications use:
#> 
#>   Schöbitz L (2024). _ghedata: What the Package Does (One Line, Title
#>   Case)_. R package version 0.0.0.9000,
#>   <https://github.com/global-health-engineering/ghedata>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {ghedata: What the Package Does (One Line, Title Case)},
#>     author = {Lars Schöbitz},
#>     year = {2024},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/global-health-engineering/ghedata},
#>   }
```
