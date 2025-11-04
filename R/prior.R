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
        valg == "KV2021" ~ -1
      )
    ) |>
    janitor::clean_names()

  model <- brm(
    mvbind(a, b, c, f, o, v, k, i, o_2, d, a_2, q) ~ t + (1 | kommune),
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

draw_from_prior_model <- function(prior_model) {
  prior_model |>
    spread_draws(
      b_a_Intercept,
      b_a_t,
      b_b_Intercept,
      b_b_t,
      b_c_Intercept,
      b_c_t,
      b_d_Intercept,
      b_d_t,
      b_f_Intercept,
      b_f_t,
      b_i_Intercept,
      b_i_t,
      b_k_Intercept,
      b_k_t,
      b_o_Intercept,
      b_o_t,
      b_o2_Intercept,
      b_o2_t,
      b_q_Intercept,
      b_q_t,
      b_v_Intercept,
      b_v_t,
      b_a2_Intercept,
      b_a2_t,
      r_kommune__a[kommune, Intercept],
      r_kommune__b[kommune, Intercept],
      r_kommune__c[kommune, Intercept],
      r_kommune__d[kommune, Intercept],
      r_kommune__f[kommune, Intercept],
      r_kommune__i[kommune, Intercept],
      r_kommune__k[kommune, Intercept],
      r_kommune__o[kommune, Intercept],
      r_kommune__o2[kommune, Intercept],
      r_kommune__q[kommune, Intercept],
      r_kommune__v[kommune, Intercept],
      r_kommune__a2[kommune, Intercept],
    ) |>
    pivot_longer(
      cols = starts_with("r_kommune"),
      names_to = c("party"),
      names_pattern = "r_kommune__(.)",
      values_to = "r_effect"
    ) |>
    mutate(
      pred = case_when(
        party == "a" ~ b_a_Intercept + r_effect,
        party == "b" ~ b_b_Intercept + r_effect,
        party == "c" ~ b_c_Intercept + r_effect,
        party == "d" ~ b_d_Intercept + r_effect,
        party == "f" ~ b_f_Intercept + r_effect,
        party == "i" ~ b_i_Intercept + r_effect,
        party == "k" ~ b_k_Intercept + r_effect,
        party == "o" ~ b_o_Intercept + r_effect,
        party == "o2" ~ b_o2_Intercept + r_effect,
        party == "q" ~ b_q_Intercept + r_effect,
        party == "v" ~ b_v_Intercept + r_effect,
        party == "a2" ~ b_a2_Intercept + r_effect
      )
    ) |>
    ungroup()
}

plot_priors <- function(prior_draws) {
  prior_draws |>
    select(kommune, pred, party) |>
    # filter(kommune %in% c("Aarhus", "Aalborg", "København")) |>
    filter(!party %in% c("q", "d", "k", "i")) |>
    ggplot(aes(y = kommune, x = pred, fill = party, color = party)) +
    stat_halfeye() +
    scale_color_viridis_d() +
    scale_fill_viridis_d()
}
