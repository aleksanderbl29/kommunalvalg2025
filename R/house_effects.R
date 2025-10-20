calc_house_effects <- function(election_results, election_dates, polls, parties) {
  latest_election <- election_dates |>
    filter(valg_id != 999) |>
    pull(valg_dato) |>
    max()

  polls_filtered <- polls |>
    filter(poll_date < latest_election)

  shared_info <- election_results |>
    select(kommune_id, kommune, storkreds_nr, landsdel_nr, valgsted) |>
    distinct()

  municipal_calc <- election_results |>
    group_by(kommune_id, date, party_code) |>
    summarize(
      avg_percent = mean(percent, na.rm = TRUE),
      n = n()
    ) |>
    ungroup() |>
    left_join(polls_filtered, by = join_by(party_code, date == election)) |>
    mutate(poll_delta = avg_percent - value) |>
    group_by(kommune_id, date, party_code, pollster) |>
    summarize(
      municipality_delta = mean(poll_delta, na.rm = TRUE),
      n = n()
    ) |>
    ungroup() |>
    left_join(parties |> select(party_code, party_name))


  valgsted_calc <- election_results |>
    group_by(valgsted, date, party_code) |>
    summarize(
      avg_percent = mean(percent, na.rm = TRUE),
      n = n()
    ) |>
    ungroup() |>
    left_join(polls_filtered, by = join_by(party_code, date == election)) |>
    mutate(poll_delta = avg_percent - value) |>
    group_by(valgsted, date, party_code, pollster) |>
    summarize(
      valgsted_delta = mean(poll_delta, na.rm = TRUE),
      n = n()
    ) |>
    ungroup() |>
    left_join(parties |> select(party_code, party_name))

  shared_info |>
    left_join(valgsted_calc, by = join_by(valgsted)) |>
    left_join(municipal_calc, by = join_by(kommune_id))
}
