get_mcp_hist_results <- function(election_results) {
  election_results |>
    group_by(kommune, valg, party_code) |>
    summarise(
      voteshare = sum(votes) / sum(total_votes)
    ) |>
    ungroup()
}
