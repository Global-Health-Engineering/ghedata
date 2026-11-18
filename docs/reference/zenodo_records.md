# zenodo_records: Records on Zenodo with views and downloads

One row per record on Zenodo that has a creator from the group or that
is part of the openwashdata community, published since 2021. A record is
listed once, with its latest version; views and downloads are the totals
over all versions on the snapshot date. The table holds no name of a
creator.

## Usage

``` r
zenodo_records
```

## Format

A tibble with 11 variables

- record_id:

  Identifier of the record on Zenodo (latest version).

- doi:

  DOI of the latest version.

- title:

  Title of the record.

- publication_date:

  Publication date of the latest version.

- resource_type:

  Type of the record on Zenodo, for example dataset, software,
  publication.

- openwashdata_community:

  TRUE if the record is part of the openwashdata community on Zenodo.

- views:

  Views of the record page, all versions.

- unique_views:

  Unique views, all versions, as counted by Zenodo.

- downloads:

  Downloads of files, all versions.

- unique_downloads:

  Unique downloads, all versions, as counted by Zenodo.

- snapshot_date:

  Date on which the counts were read.

## Source

Zenodo REST API, read with `data-raw/data_processing_reach.R`.

## Details

The records of a creator are found through a list of ORCID identifiers
of group members, which is not part of the package. A record of a group
member who is not on that list is missing, and a record that a listed
person published outside the work of the group is included, unless it is
named in `data-raw/zenodo_records_excluded.csv`.
