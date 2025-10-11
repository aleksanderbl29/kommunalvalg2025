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
  polls <- tibble()

  id <- poll_list |> pull(id)

  poll_date <- poll_list |>
    pull(validFromDate) |>
    as_date()

  x <- request(base_url) |>
    req_url_query(id = id) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    _$surveyDataPoints |>
    as_tibble() |>
    mutate(poll_date = poll_date)

  Sys.sleep(0.5) # Sleep for half a second to not overload API

  return(x)
}
