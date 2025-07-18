# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ghedata is an R data package developed by Global Health Engineering at ETH Zurich for sharing data resources that document the group's work. It provides datasets suitable for research, teaching, and learning purposes.

## Development Commands

### Essential Commands
```r
# Load development dependencies
library(devtools)
library(usethis)
library(pkgdown)

# Document the package (regenerate man/ files from roxygen comments)
devtools::document()

# Run R CMD check
devtools::check()

# Install the package locally for testing
devtools::install()

# Build the pkgdown website
pkgdown::build_site()

# Run data processing script to update datasets
source("data-raw/data_processing.R")
```

### Testing and Development
```r
# Load the package in development mode
devtools::load_all()

# Test specific dataset
library(ghedata)
data(people)
View(people)

# Check if documentation is properly built
?people
```

## Architecture & Key Components

### Data Processing Pipeline
1. **Raw Data Source**: Google Sheets (accessed via googlesheets4)
2. **Processing Script**: `data-raw/data_processing.R`
   - Pulls data from configured Google Sheets
   - Performs data cleaning and anonymization
   - Saves processed data to `data/` as .rda files
   - Exports to `inst/extdata/` as CSV/XLSX

### Package Structure
- **R/**: Dataset documentation files (e.g., `people.R`)
  - Each dataset has a corresponding R file with roxygen2 documentation
  - Documents include title, description, format, source, and examples
  
- **data-raw/**: Contains processing scripts and intermediate data
  - Main processing happens in `data_processing.R`
  - Dictionary files define data schemas
  
- **inst/extdata/**: Exported data files for download
  - Provides CSV and XLSX versions of all datasets
  - Accessible via `system.file()` calls

### Documentation System
- Uses roxygen2 for function/data documentation
- pkgdown generates the package website from:
  - README.md (homepage)
  - Function documentation (reference)
  - Vignettes (articles)
  - NEWS.md (changelog)
- Website configuration in `_pkgdown.yml`

## Key Technical Decisions

1. **Data Anonymization**: Names are replaced with unique hash IDs to protect privacy
2. **Multiple Export Formats**: Data available as R objects, CSV, and Excel files
3. **Google Sheets Integration**: Raw data pulled directly from shared sheets
4. **Versioning**: Package version tracks data updates (currently 0.0.5)

## Adding New Datasets

1. Add raw data source to `data-raw/data_processing.R`
2. Create documentation file in `R/` (e.g., `R/newdata.R`)
3. Run processing script to generate data files
4. Update package documentation with `devtools::document()`
5. Export to CSV/XLSX in processing script
6. Update README with new dataset information
7. Rebuild pkgdown site

## Code Style
- 2 spaces for indentation (no tabs)
- Auto-append newlines to files
- Strip trailing whitespace
- Follow tidyverse style guide for R code

## R Code Rules

- Do not display results by using print() or message() functions

## Markdown Rules

- When writing markdown text, always add an empty row between a heading and the first paragraph or the first bullet of a list
