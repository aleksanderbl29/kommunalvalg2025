get_epinion_poll_list <- function(
    base_url = "https://www.dr.dk/nyheder/politik/meningsmaalinger/api/opinionPollData"
) {
  request(base_url) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    as_tibble() |>
    mutate(isElection = as.logical(replace_na(isElection, FALSE))) |>
    filter(isElection != TRUE)
}

get_epinion_polls <- function(
  poll_list,
  base_url = "https://www.dr.dk/nyheder/politik/meningsmaalinger/api/opinionPollData"
) {
  id <- poll_list |> pull(id)

  poll_date <- poll_list |>
    pull(validFromDate) |>
    as_date()

  description <- request(base_url) |>
    req_url_query(id = id) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$description

  n <- str_extract_all(description, "\\d+\\.\\d{3}|\\b\\d{3}\\b") |>
    _[[1]] |>
    unique() |>
    str_replace_all("[.]", "") |>
    tail(n = 1) |>
    as.numeric()

  x <- request(base_url) |>
    req_url_query(id = id) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$surveyDataPoints |>
    as_tibble() |>
    mutate(
      poll_date = poll_date,
      pollster = "Epinion",
      n = n,
      party_code = case_when(
        partyId == "a" ~ "A",
        partyId == "b" ~ "B",
        partyId == "c" ~ "C",
        partyId == "f" ~ "F",
        partyId == "k" ~ "K",
        partyId == "o" ~ "O",
        partyId == "v" ~ "V",
        partyId == "i" ~ "I",
        partyId == "oe" ~ "Ø",
        partyId == "aa" ~ "Å",
        partyId == "d" ~ "D",
        partyId == "e" ~ "E",
        partyId == "p" ~ "P",
        partyId == "g" ~ "G",
        partyId == "q" ~ "Q",
        partyId == "m" ~ "M",
        partyId == "ae" ~ "Æ",
        partyId == "h" ~ "H"
      ),
      value = percentage
    ) |>
    left_join(parties, by = join_by(party_code)) |>
    drop_na() |>
    select(party_code, party_name, poll_date, value, pollster, n)

  Sys.sleep(api_sleep_time)

  return(x)
}
