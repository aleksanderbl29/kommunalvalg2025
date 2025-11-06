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
  prior_draws |>
    group_by(party) |>
    summarise(
      mean = mean(pred + r_effect),
      sd = sd(pred + r_effect)
    )

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


#   ggplot() +
#   geom_sf()
#
# x_plot + y_plot / l_plot
