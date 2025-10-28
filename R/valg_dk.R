kv_request_headers <- list(
  "X-Election-ID" = "1705ff7b-7390-48d8-b701-6bcd430dc835",
  "Cookie" = paste0(
    "NSC_mc_wt_wbm_qspe=",
    "0dde57ead4f0f501e1df555e53be196b"
    # this random string was generated with:
    # paste0(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
  )
)

get_kv_election_overview <- function(
  base_url = "https://valg.dk/api/overview/kv-election-overview"
) {
  request(base_url) |>
    req_headers(!!!kv_request_headers) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$municipalities |>
    as_tibble() |>
    mutate(lastUpdate = as_datetime(lastUpdate))
}

get_kv_data_csv <- function(
  municipality_id,
  election_id = "kv2025"
) {
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
    read_csv2(col_types = cols("c", "c", "c", "c", "d")) |>
    janitor::clean_names() |>
    mutate(
      municipality = municipality_id |> pull(name),
      last_pull = now()
    )

  Sys.sleep(api_sleep_time)

  return(x)
}
# "https://valg.dk/api/export-data/export-kv-data-csv?
# ElectionId=1705ff7b-7390-48d8-b701-6bcd430dc835
# &
# MunicipalityId=613bbb61-4de7-426d-a1a9-e6ffbaf41140"

get_kv_coalitions <- function(municipality_id) {
  url <- paste0(
    "https://valg.dk/api/detail/municipality/",
    municipality_id |> pull(id)
  )

  response <- request(url) |>
    req_headers(!!!kv_request_headers) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON()

  x <- response |>
    _$electoralCoalitionList$listLettersOrName |>
    str_split(",\\s*")

  Sys.sleep(api_sleep_time)

  return(list(municipality_name = response$countStatusDto$name, coalitions = x))
}

get_kv_election_ids <- function() {
  url <- paste0(
    "https://valg.dk/api/election" #,
    # municipality_id |> pull(id)
  )

  request(url) |>
    req_headers(!!!list("Cookie" = kv_request_headers$Cookie)) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$municipalElections |>
    as_tibble() |>
    mutate(electionDate = ymd(electionDate)) |>
    arrange(desc(electionDate))
}
