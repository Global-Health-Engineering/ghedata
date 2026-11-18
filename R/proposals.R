#' proposals: Funding proposals submitted by Global Health Engineering
#'
#' One row per funding proposal the group has submitted since 2020, with the
#' status, the funder and the requested budget. The names of projects, leads,
#' co-leads and partner organisations are not part of the data. Budgets in
#' other currencies are converted to Swiss francs with the exchange rate of
#' 1 July of the year of submission.
#'
#' A project that was requested from several funders appears once per request,
#' because each request is a proposal of its own. `project_id` shows which
#' proposals belong to the same project.
#'
#' @format A tibble with 16 variables
#' \describe{
#'   \item{proposal_id}{ Identifier of the proposal, numbered in the order of submission. Carries no name of a project or a person.}
#'   \item{project_id}{ Identifier of the project. Proposals with the same project_id are requests for the same project to different funders or in different years.}
#'   \item{status}{ Status of the proposal. Levels: accepted, rejected, submitted (no answer yet), withdrawn.}
#'   \item{submitted_date}{ Date the proposal was submitted. Where only the month is known, the first day of the month.}
#'   \item{submitted_year}{ Year the proposal was submitted.}
#'   \item{answer_date}{ Date of the answer of the funder. Where only the month is known, the first day of the month. NA when no answer was recorded.}
#'   \item{days_to_answer}{ Days between submission and answer. NA when no answer was recorded or when the recorded answer lies before the submission.}
#'   \item{funder}{ Funder or funding programme the proposal was submitted to, with one spelling per funder.}
#'   \item{snsf}{ TRUE when the proposal went to a programme of the Swiss National Science Foundation.}
#'   \item{budget}{ Requested budget in the currency of the proposal.}
#'   \item{currency}{ Currency of the requested budget (ISO 4217 code).}
#'   \item{rate_date}{ Date of the exchange rate used for budget_chf: 1 July of the year of submission, or the last banking day before it. NA for budgets in CHF.}
#'   \item{budget_chf}{ Requested budget in Swiss francs, rounded to the franc. Converted with the reference rate of the European Central Bank on rate_date. NA when the budget or the currency is missing.}
#'   \item{lead_data_steward}{ TRUE when the data steward of the group led the proposal. The only information on a lead in the data.}
#'   \item{co_lead_external}{ TRUE when the proposal had a co-lead outside the group.}
#'   \item{partner_organisation}{ TRUE when the proposal named a partner organisation.}
#' }
#' @source Table of submitted proposals kept by the group, read from Google
#'   Sheets with `data-raw/data_processing_proposals.R`. Exchange rates:
#'   reference rates of the European Central Bank, kept in
#'   `data-raw/proposals_exchange_rates.csv`.
"proposals"
