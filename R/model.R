run_model <- function(prior_draws, polls, election_day) {
  prior <- prior_draws |>
    select(kommune, pred, party)

  new_polls <- polls |>
    distinct() |>
    filter(election == election_day) |>
    mutate(poll_value = as.numeric(value)) |>
    select(party_code, poll_date, poll_value, segment, pollster) |>
    distinct() |>
    pivot_wider(
      names_from = party_code,
      values_from = poll_value,
      values_fill = 0
    ) |>
    janitor::clean_names() |>
    replace_na(list(h = 0)) |>
    mutate(days_out = poll_date - election_day, area = "nationwide") |>
    arrange(days_out) %>%
    mutate(across(
      c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
      ~ ifelse(. == 0, 0.01, .)
    )) %>%
    mutate(
      row_sum = a +
        b +
        c +
        f +
        o +
        v +
        k +
        i +
        o_2 +
        d +
        a_2 +
        q +
        h +
        m +
        ae +
        g,
      across(
        c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
        ~ . / row_sum
      ),
      days_out = as.numeric(days_out)
    ) %>%
    select(-row_sum)

  # brm(
  #   formula = cbind(
  #     a,
  #     b,
  #     c,
  #     f,
  #     o,
  #     v,
  #     k,
  #     i,
  #     o_2,
  #     d,
  #     a_2,
  #     q,
  #     h,
  #     m,
  #     ae,
  #     g
  #   ) ~ days_out +
  #     # (1 | area) +
  #     (1 | pollster) +
  #     (1 | segment),
  #   data = new_polls,
  #   family = dirichlet(),
  #   # prior = ,
  #   # cores = parallel::detectCores()
  #   # iter = 7500,
  #   cores = 4,
  #   iter = 3500,
  #   chains = 4,
  #   backend = "cmdstanr",
  #   refresh = 75
  # )

  fit <- brm(
    cbind(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g) ~ 1, #+
    # (1 | segment),
    data = new_polls,
    family = dirichlet(),
    # prior = prior(constant(1), class = "phi"), # Keep precision fixed
    cores = 4,
    chains = 4,
    backend = "cmdstanr"
  ) #|>
  # add_criterion("loo", weights = new_polls$poll_weight)

  # Predict vote shares for each segment
  pred <- predict(
    fit,
    newdata = expand.grid(segment = unique(new_polls$segment))
  )

  # Or get posterior draws for overall average (most recent polls weighted most)
  post <- as_draws_df(fit)

  # Extract party vote shares on probability scale
  fit %>%
    epred_draws(
      newdata = data.frame(
        segment = c("all", "men", "women", "young", "doubts")
      )
    ) %>%
    median_qi()
}

run_hierarchical_model <- function(polls, election_day, election_results) {
  new_polls <- polls |>
    distinct() |>
    filter(election == election_day) |>
    mutate(poll_value = as.numeric(value)) |>
    select(party_code, poll_date, poll_value, segment, pollster) |>
    distinct() |>
    pivot_wider(
      names_from = party_code,
      values_from = poll_value,
      values_fill = 0
    ) |>
    janitor::clean_names() |>
    replace_na(list(h = 0)) |>
    mutate(days_out = poll_date - election_day, area = "nationwide") |>
    arrange(days_out) %>%
    mutate(across(
      c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
      ~ ifelse(. == 0, 0.01, .)
    )) %>%
    mutate(
      row_sum = a +
        b +
        c +
        f +
        o +
        v +
        k +
        i +
        o_2 +
        d +
        a_2 +
        q +
        h +
        m +
        ae +
        g,
      across(
        c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
        ~ . / row_sum
      ),
      days_out = as.numeric(days_out) |> abs()
    ) |>
    select(-row_sum)

  # new_polls
  #
  # election_results
  #
  # prior_draws |>
  #   group_by(party) |>
  #   summarise(
  #     mean = mean(pred + r_effect),
  #     sd = sd(pred + r_effect)
  #   )

  priors <- c(
    # prior(normal(28, 13), class = "Intercept", resp = "a")
    prior(normal(20, 15), class = "Intercept"),
    prior(normal(0, 3), class = "b")
  )

  fit <- brm(
    cbind(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g) ~ pollster +
      segment, #+
    # (1 | segment),
    data = new_polls,
    # prior = priors,
    family = dirichlet(),
    cores = 4,
    chains = 4,
    backend = "cmdstanr"
  )
  # summary(fit)
  # plot(fit)

  return(fit)
}

run_another_model <- function(polls, election_day) {
  new_polls <- polls |>
    distinct() |>
    filter(election == election_day) |>
    mutate(poll_value = as.numeric(value)) |>
    select(party_code, poll_date, poll_value, segment, pollster) |>
    distinct() |>
    pivot_wider(
      names_from = party_code,
      values_from = poll_value,
      values_fill = 0
    ) |>
    janitor::clean_names() |>
    replace_na(list(h = 0)) |>
    mutate(days_out = poll_date - election_day, area = "nationwide") |>
    arrange(days_out) %>%
    mutate(across(
      c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
      ~ ifelse(. == 0, 0.01, .)
    )) %>%
    mutate(
      row_sum = a +
        b +
        c +
        f +
        o +
        v +
        k +
        i +
        o_2 +
        d +
        a_2 +
        q +
        h +
        m +
        ae +
        g,
      across(
        c(a, b, c, f, o, v, k, i, o_2, d, a_2, q, h, m, ae, g),
        ~ . / row_sum
      ),
      days_out = as.numeric(days_out) |> abs()
    ) |>
    select(-row_sum)

  # Define the model using dirichlet
  formula <- bf(
    cbind(a, b, c, f, v, k, i, o_2, d, a_2, q, h, m, ae, g, o) ~
      pollster + segment
  ) +
    dirichlet()

  # Now set priors for each response
  priors <- c(
    # Intercept for each party
    prior(normal(28, 13), class = "Intercept", resp = "a"),
    prior(normal(4.09, 3.93), class = "Intercept", resp = "b"),
    prior(normal(12.8, 19.2), class = "Intercept", resp = "c"),
    prior(normal(2.82, 0.235), class = "Intercept", resp = "d"),
    prior(normal(6.28, 5.8), class = "Intercept", resp = "f"),
    prior(normal(2.5, 1.08), class = "Intercept", resp = "i"),
    prior(normal(0.644, 2.39), class = "Intercept", resp = "k"),
    prior(normal(8.16, 4.88), class = "Intercept", resp = "o"),
    prior(normal(0.107, 0.102), class = "Intercept", resp = "q"),
    prior(normal(23.3, 18.7), class = "Intercept", resp = "v"),
    prior(lkj(2), class = "rescor")
  )

  # Fit the model
  fit <- brm(
    formula,
    data = new_polls,
    prior = priors,
    chains = 6,
    iter = 7500,
    cores = 6
  )

  return(fit)
}

get_another_model_posterior <- function(another_model) {
  variables <- another_model |>
    get_variables()

  draws <- another_model |>
    spread_draws(
      b_a_Intercept,
      b_a_pollsterVerian,
      b_b_Intercept,
      b_b_pollsterVerian,
      b_c_Intercept,
      b_c_pollsterVerian,
      b_f_Intercept,
      b_f_pollsterVerian,
      b_o_Intercept,
      b_o_pollsterVerian,
      b_v_Intercept,
      b_v_pollsterVerian,
      b_k_Intercept,
      b_k_pollsterVerian,
      b_i_Intercept,
      b_i_pollsterVerian,
      b_o2_Intercept,
      b_o2_pollsterVerian,
      b_d_Intercept,
      b_d_pollsterVerian,
      b_a2_Intercept,
      b_a2_pollsterVerian,
      b_q_Intercept,
      b_q_pollsterVerian,
      b_h_Intercept,
      b_h_pollsterVerian,
      b_m_Intercept,
      b_m_pollsterVerian,
      b_ae_Intercept,
      b_ae_pollsterVerian,
      b_g_Intercept,
      b_g_pollsterVerian
    ) |>
    mutate(
      # Reference segment (all), reference pollster (Epinion)
      a_ref = b_a_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,
      b_ref = b_b_Intercept,

      # Reference segment (all), Verian pollster
      a_verian = b_a_Intercept + b_a_pollsterVerian,
      b_verian = b_b_Intercept + b_b_pollsterVerian,
      # ... etc

      # Reference segment (all), averaged across pollsters (50/50 weight)
      a_avg = b_a_Intercept + 0.5 * b_a_pollsterVerian,
      b_avg = b_b_Intercept + 0.5 * b_b_pollsterVerian,
      # ... etc for all parties
    )

  draws_long <- another_model |>
    gather_draws(`b_.+_Intercept|b_.+_pollsterVerian`, regex = TRUE) |>
    separate(.variable, into = c("type", "party", "param"), sep = "_") |>
    pivot_wider(names_from = param, values_from = .value) |>
    mutate(
      ref_pollster = Intercept, # Reference segment & pollster
      verian_pollster = Intercept + pollsterVerian, # Reference segment & Verian
      avg_pollster = Intercept + 0.5 * pollsterVerian # Reference segment, avg pollster
    )
  draws_long |>
    group_by(party) |>
    summarise(
      mean(avg_pollster),
      sd(avg_pollster)
    )
}
