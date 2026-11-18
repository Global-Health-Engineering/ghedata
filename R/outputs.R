#' outputs: theses and projects of students in the Global Health Engineering group
#'
#' One row per thesis, semester project or case study of a student in the
#' group since 2021, finished or running, with its title. Work that was not
#' finished is left out. The table holds no name of a person. It is sorted by
#' year, type and title, and there is no key to the table [people].
#'
#' @format A tibble with 169 rows and 4 variables
#' \describe{
#'   \item{title}{ Title of the thesis or project.}
#'   \item{output_type}{ Kind of work: bsc thesis, msc thesis, msc semester project, msc case study or phd thesis.}
#'   \item{year}{ Year in which the work started.}
#'   \item{research_collection_link}{ Address of the work in the ETH Research Collection, where it is deposited; empty otherwise.}
#' }
#' @source The supervision table of the group, kept by the data steward. It
#'   holds names and stays outside the package; the table is built by
#'   `data-raw/data_processing.R`.
"outputs"
