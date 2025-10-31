coerce_to_correlation <- function(df) {
  df |>
    pivot_longer(
      cols = -1,
      names_to = "variable",
      values_to = "value"
    ) |>
    group_by(variable) |>
    mutate(
      value = (value - min(value, na.rm = T)) /
        (max(value, na.rm = T) - min(value, na.rm = T))
    ) |>
    pivot_wider(
      names_from = kommune,
      values_from = value
    ) |>
    na.omit() |>
    ungroup() |>
    select(-variable)
}

construct_correlation_matrix <- function(
  vote_covariance,
  # municipality_covariance,
  regions_covariance
) {
  # Replace NA with 0
  vote_covariance[is.na(vote_covariance)] <- 0
  # municipality_covariance[is.na(municipality_covariance)] <- 0
  regions_covariance[is.na(regions_covariance)] <- 0

  # Baseline cor
  baseline_cor <- matrix(
    data = 1,
    nrow = nrow(vote_covariance),
    ncol = nrow(vote_covariance)
  )

  # Defining weights estimated in seperate model
  baseline_w <- 0.04175
  vote_w <- 0.25825
  region_w <- 0.1
  mcp_w <- 0.6

  C <- (baseline_w * baseline_cor) +
    (vote_w * vote_covariance) +
    # (mcp_w * municipality_covariance) +
    (region_w * regions_covariance)

  # Ensure no correlations are above 1
  C[C > 1] <- 1

  return(C)
}
