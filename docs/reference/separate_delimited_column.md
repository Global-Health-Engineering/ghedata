# Separate comma-delimited values in a column

This function takes a data frame and separates comma-delimited values in
a specified column into individual rows, preserving the id column for
joining back to the original data.

## Usage

``` r
separate_delimited_column(data, id_col, target_col, new_col_name = NULL)
```

## Arguments

- data:

  A data frame containing the data to process

- id_col:

  The name of the ID column (as string)

- target_col:

  The name of the column containing comma-delimited values (as string)

- new_col_name:

  Optional new name for the separated column (as string)

## Value

A data frame with separated values, one per row

## Examples

``` r
# Process IDEs used
ides_df <- separate_delimited_column(computational, "id", "ides_used", "ide")

# Process LLM tools used
llm_df <- separate_delimited_column(computational, "id", "llm_tools_used", "llm_tool")

# Process other languages
languages_df <- separate_delimited_column(computational, "id", "other_languages", "language")
```
