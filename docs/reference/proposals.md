# proposals: Funding proposals submitted by Global Health Engineering

One row per funding proposal the group has submitted since 2020, with
the status, the funder and the requested budget. The names of projects,
leads, co-leads and partner organisations are not part of the data.
Budgets in other currencies are converted to Swiss francs with the
exchange rate of 1 July of the year of submission.

## Usage

``` r
proposals
```

## Format

A tibble with 16 variables

- proposal_id:

  Identifier of the proposal, numbered in the order of submission.
  Carries no name of a project or a person.

- project_id:

  Identifier of the project. Proposals with the same project_id are
  requests for the same project to different funders or in different
  years.

- status:

  Status of the proposal. Levels: accepted, rejected, submitted (no
  answer yet), withdrawn.

- submitted_date:

  Date the proposal was submitted. Where only the month is known, the
  first day of the month.

- submitted_year:

  Year the proposal was submitted.

- answer_date:

  Date of the answer of the funder. Where only the month is known, the
  first day of the month. NA when no answer was recorded.

- days_to_answer:

  Days between submission and answer. NA when no answer was recorded or
  when the recorded answer lies before the submission.

- funder:

  Funder or funding programme the proposal was submitted to, with one
  spelling per funder.

- snsf:

  TRUE when the proposal went to a programme of the Swiss National
  Science Foundation.

- budget:

  Requested budget in the currency of the proposal.

- currency:

  Currency of the requested budget (ISO 4217 code).

- rate_date:

  Date of the exchange rate used for budget_chf: 1 July of the year of
  submission, or the last banking day before it. NA for budgets in CHF.

- budget_chf:

  Requested budget in Swiss francs, rounded to the franc. Converted with
  the reference rate of the European Central Bank on rate_date. NA when
  the budget or the currency is missing.

- lead_data_steward:

  TRUE when the data steward of the group led the proposal. The only
  information on a lead in the data.

- co_lead_external:

  TRUE when the proposal had a co-lead outside the group.

- partner_organisation:

  TRUE when the proposal named a partner organisation.

## Source

Table of submitted proposals kept by the group, read from Google Sheets
with `data-raw/data_processing_proposals.R`. Exchange rates: reference
rates of the European Central Bank, kept in
`data-raw/proposals_exchange_rates.csv`.

## Details

A project that was requested from several funders appears once per
request, because each request is a proposal of its own. `project_id`
shows which proposals belong to the same project.
