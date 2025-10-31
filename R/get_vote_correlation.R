get_vote_correlation <- function(mcp_hist_results) {
  mcp_hist_results |>
    mutate(election_party = paste0(valg, "_", party_code)) |>
    select(kommune, voteshare, election_party) |>
    pivot_wider(
      names_from = election_party,
      values_from = voteshare,
      values_fill = 0
    ) |>
    coerce_to_correlation()
}
