# ghedata (development version)

* The package names its four authors and its funder, and carries a citation file, discovery keywords, and the place and period the data covers. The description says what the data contains (#20).
* `people` no longer holds thesis titles or an identifier. The titles are in the new table `outputs`, one row per thesis or project of a student, with no key between the two tables. `computational` holds counts per question and answer in place of one row per respondent, and `separate_delimited_column()` is removed. Six files that were not package data are removed (#22).
