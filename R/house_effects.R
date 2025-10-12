calc_house_effects <- function(election_results, election_dates, polls) {
  latest_election <- election_dates |>
    filter(valg_id != 999) |>
    pull(valg_dato) |>
    max()

  polls |>
    filter(poll_date < latest_election) |>
    left_join(election_results |> select(-party_name), by = join_by(election == date, party_code)) |>
    mutate(deviation = value - percent) #|>
    # select(party_name, value, pollster, percent, deviation)
}
