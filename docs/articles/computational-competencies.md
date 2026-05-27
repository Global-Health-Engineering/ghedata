# Computational competencies

``` r

library(ghedata)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(stringr)
library(here)
#> here() starts at /Users/lschoebitz/Documents/gitrepos/gh-org-global-health-engineering/ghedata

# Source helper functions
source(here::here("R", "computational_competencies_helpers.R"))
```

``` r

# Process multi-answer columns into long format using the helper function
computational_competencies_ides <- separate_delimited_column(computational, "id", "ides_used", "ide")
computational_competencies_llm_tools <- separate_delimited_column(computational, "id", "llm_tools_used", "llm_tool")
computational_competencies_languages <- separate_delimited_column(computational, "id", "other_languages", "language")
```
