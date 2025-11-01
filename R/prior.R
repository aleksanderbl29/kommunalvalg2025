fit_prior_model <- function(mcp_hist_results) {
  votes <- mcp_hist_results |>
    pivot_wider(
      names_from = party_code,
      values_from = voteshare,
      values_fill = 0
    ) |>
    mutate(
      t = case_when(
        valg == "KV2001" ~ -6,
        valg == "KV2005" ~ -5,
        valg == "KV2009" ~ -4,
        valg == "KV2013" ~ -3,
        valg == "KV2017" ~ -2,
        valg == "KV2021" ~ -1,
      )
    ) |>
    janitor::clean_names()

  model <- brm(
    mvbind(a, b, c, f, o, v, k, i, o_2, d, a_2, q) ~ t + kommune,
    data = votes,
    cores = parallel::detectCores(),
    chains = 6,
    iter = 7500,
    backend = "cmdstanr",
    refresh = 75
  )

  return(model)
}

predict_priors <- function(prior_model, mcp_hist_results) {
  data <- mcp_hist_results |>
    mutate(t = 0) |>
    select(t, kommune) |>
    distinct() |>
    arrange(kommune)

  predictions <- list()

  for (mcp in data$kommune) {
    predictions[[mcp]] <- prior_model |>
      predict(
        tibble(
          t = 0,
          kommune = mcp
        )
      ) |>
      _[,,] |>
      as_tibble(rownames = "parameter")
  }

  return(predictions)
}
