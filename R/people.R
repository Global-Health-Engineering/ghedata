#' people: A registry of all people that have worked for Global Health Engineering, including undergraduate student projects.
#'
#' This dataset contains the following columns:
#'
#' @format A tibble with 96 rows and 7 variables
#' \describe{
#'   \item{project_id}{Unique identifier for each person using a combination of other metadata. Folder name on Google Drive.}
#'   \item{degree}{Categorical variable with four levels: bsc, msc, phd, staff.}
#'   \item{type}{Categorical variable with six levels: hiwi, intern, post-doc, scientific-assitant, sem-proj, thesis.}
#'   \item{b_m_student}{Binary variable to identify if person is BSc or MSc students. Levels: yes, no.}
#'   \item{start_date}{Start date of the person.}
#'   \item{year}{Year of the start date.}
#'   \item{thesis_title}{Title of the thesis.}
#' }
"people"
