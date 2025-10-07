epinion_api_url_var <- "https://www.dr.dk/nyheder/politik/meningsmaalinger/api/opinionPollData"

get_epinion_polls <- function(base_url) {

  poll_list <- request(base_url) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    filter(!isTRUE(isElection))

  polls <- tibble()

  ids <- poll_list$id

  for (id in ids) {
    poll_date <- as_date(poll_list[poll_list$id == id, "validFromDate"])
    tbl <- request(base_url) |>
      req_url_query(id = id) |>
      req_perform() |>
      resp_body_string() |>
      jsonlite::fromJSON() |>
      _$surveyDataPoints |>
      as_tibble() |>
      mutate(poll_date = poll_date)
    polls <- bind_rows(polls, tbl)
  }
  return(polls)
}
