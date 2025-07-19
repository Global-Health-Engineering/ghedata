#' Separate comma-delimited values in a column
#'
#' This function takes a data frame and separates comma-delimited values in a specified column
#' into individual rows, preserving the id column for joining back to the original data.
#'
#' @param data A data frame containing the data to process
#' @param id_col The name of the ID column (as string)
#' @param target_col The name of the column containing comma-delimited values (as string)
#' @param new_col_name Optional new name for the separated column (as string)
#'
#' @return A data frame with separated values, one per row
#'
#' @examples
#' # Process IDEs used
#' ides_df <- separate_delimited_column(computational, "id", "ides_used", "ide")
#' 
#' # Process LLM tools used
#' llm_df <- separate_delimited_column(computational, "id", "llm_tools_used", "llm_tool")
#' 
#' # Process other languages
#' languages_df <- separate_delimited_column(computational, "id", "other_languages", "language")
separate_delimited_column <- function(data, id_col, target_col, new_col_name = NULL) {
  # Select only the ID and target columns
  result <- data |>
    select(all_of(c(id_col, target_col)))
  
  # Filter out NA values
  result <- result |>
    filter(!is.na(.data[[target_col]]))
  
  # Separate rows by comma delimiter
  result <- result |>
    tidyr::separate_rows(all_of(target_col), sep = ", ")
  
  # Trim whitespace
  result <- result |>
    mutate(across(all_of(target_col), str_trim))
  
  # Rename column if new name provided
  if (!is.null(new_col_name)) {
    result <- result |>
      rename(!!new_col_name := all_of(target_col))
  }
  
  return(result)
}