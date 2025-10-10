get_kv_election_overview <- function(
  base_url = "https://valg.dk/api/overview/kv-election-overview"
) {
  cookie <- paste0(
    "NSC_mc_wt_wbm_qspe=",
    paste0(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
  )
  headers <- list(
    "X-Election-ID" = "1705ff7b-7390-48d8-b701-6bcd430dc835",
    # "Cookie" = "NSC_mc_wt_wbm_qspe=ffffffff090a364345525d5f4f58455e445a4a4229a0"
    "Cookie" = cookie
  )

  request(base_url) |>
    req_headers(!!!headers) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$municipalities |>
    as_tibble() |>
    mutate(lastUpdate = as_datetime(lastUpdate))
}

get_kv_data_csv <- function(municipality_id) {
  base_url <- "https://valg.dk/api/export-data/export-kv-data-csv"
  election_id <- "1705ff7b-7390-48d8-b701-6bcd430dc835"

  url <- paste0(
    base_url,
    "?",
    "ElectionId=",
    election_id,
    "&",
    "MunicipalityId=",
    municipality_id |> pull(id)
  )

  x <- request(url) |>
    req_perform() |>
    resp_body_string() |>
    read_csv2(col_types = cols("c", "c", "c", "c", "d"))

  Sys.sleep(0.5) # Sleep for half a second to not overload API

  return(x)
}
# "https://valg.dk/api/export-data/export-kv-data-csv?
# ElectionId=1705ff7b-7390-48d8-b701-6bcd430dc835
# &
# MunicipalityId=613bbb61-4de7-426d-a1a9-e6ffbaf41140"
