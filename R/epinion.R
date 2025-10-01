get_epinion_poll_list <- function() {
  base_url <- "https://www.dr.dk/nyheder/politik/meningsmaalinger/api/opinionPollData"

  request(base_url) |>
    req_perform() |>
    resp_body_string() |>
    jsonlite::fromJSON() |>
    filter(!isTRUE(isElection))
}

get_epinion_poll <- function(poll_list) {
  base_url <- "https://www.dr.dk/nyheder/politik/meningsmaalinger/api/opinionPollData"

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
