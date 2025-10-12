bind_polls <- function(election_dates, verian_polls, gallup_polls, epinion_polls) {
  x <- bind_rows(verian_polls, gallup_polls, epinion_polls) |>
    mutate(
      kv01 = election_dates$valg_dato[1],
      kv05 = election_dates$valg_dato[2],
      kv09 = election_dates$valg_dato[3],
      kv13 = election_dates$valg_dato[4],
      kv17 = election_dates$valg_dato[5],
      kv21 = election_dates$valg_dato[6],
      kv25 = election_dates$valg_dato[7],
      ttl_kv01 = kv01 - poll_date,
      ttl_kv05 = kv05 - poll_date,
      ttl_kv09 = kv09 - poll_date,
      ttl_kv13 = kv13 - poll_date,
      ttl_kv17 = kv17 - poll_date,
      ttl_kv21 = kv21 - poll_date,
      ttl_kv25 = kv25 - poll_date
    ) |>
    mutate(
      across(
        where(~ inherits(.x, "difftime")),
        ~ replace(.x, .x < 0, as.difftime(NA_real_, units = attr(.x, "units")))
      )
    )

  ttl_cols <- x |> select(starts_with("ttl_kv")) |> names()

  long_min <- x |>
    pivot_longer(
      cols = all_of(ttl_cols),
      names_to = "election",
      values_to = "time_to"
    ) |>
    filter(!is.na(time_to)) |>
    group_by(poll_date) |>
    slice_min(as.numeric(time_to, units = "days"), with_ties = FALSE) |>
    ungroup() |>
    mutate(
      days_out = as.numeric(time_to, units = "days"),
      election = sub("^ttl_", "", election)
    )

  kv_lookup <- x |>
    select(starts_with("kv")) |>
    slice_head(n = 1) |>
    pivot_longer(everything(), names_to = "kv_name", values_to = "kv_date")

  x |>
    left_join(
      long_min |>
        left_join(kv_lookup, by = c("election" = "kv_name")) |>
        select(poll_date, election = kv_date, days_out),
      by = "poll_date"
    ) |>
    mutate(days_out = as.difftime(days_out, units = "days")) |>
    select(-starts_with(c("ttl", "kv")))
}

