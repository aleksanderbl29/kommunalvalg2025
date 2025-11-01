library(targets)
library(tarchetypes)
library(stantargets)
library(glue)

api_sleep_time <- 0.25 # Sleep API calls for some time.

tar_option_set(
  packages = c(
    "tidyverse",
    "glue",
    "dkstat",
    "geodk",
    "lubridate",
    "httr2",
    "tibble",
    "sf",
    "brms"
  ),
  format = "qs",
  seed = 42,
  controller = crew::crew_controller_local(
    workers = parallel::detectCores(),
    seconds_idle = 60
  )
)
tar_source()

list(
  tar_target(this_week, week(today("CET"))),
  tar_target(run_date, today()),
  tar_target(election_day, dmy("18-11-2025")),

  # Set options for runtime and estimation
  tar_target(n_chains, 4),
  tar_target(n_cores, getOption("mc.cores")),
  tar_target(n_warmup, 1000),
  tar_target(n_iter, 3500),
  tar_target(n_sampling, n_iter * 0.1),
  tar_target(n_refresh, n_sampling * 0.1),
  tar_target(sigma_measure_noise_national, 0.05),
  tar_target(sigma_measure_noise_state, 0.05),
  tar_target(sigma_c, 0.06),
  tar_target(sigma_m, 0.04),
  tar_target(sigma_pop, 0.04),
  tar_target(sigma_e_bias, 0.02),

  # Municipality level data
  tar_target(mcp_geo, get_mcp_geo(this_week)),
  tar_target(mcp_pop, get_mcp_pop(this_week)),
  tar_target(mcp_info, get_mcp_info(mcp_geo)),
  tar_target(mcp_accounts, get_mcp_accounts(this_week)),
  tar_target(mcp_daycare_pricing, get_mcp_daycare_pricing(this_week)),
  tar_target(turnout_pct, get_turnout_pct(this_week)),

  # Valg.dk
  tar_group_by(kv_election_overview, get_kv_election_overview(), id),
  tar_group_by(kv_election_ids, get_kv_election_ids(), id),
  tar_target(
    current_election_results,
    get_kv_data_csv(kv_election_overview),
    pattern = map(kv_election_overview)
  ),
  tar_target(
    kv_coalitions,
    get_kv_coalitions(kv_election_overview),
    pattern = map(kv_election_overview)
  ),

  # Election results
  tar_file_read(election_dates, "data/dst/Valg.csv", read_election_dates(!!.x)),
  tar_file_read(
    election_results,
    "data/dst/ValgData.csv",
    read_election_results(!!.x, election_dates, mcp_info, parties)
  ),
  tar_target(mcp_hist_results, get_mcp_hist_results(election_results)),

  # Parties
  tar_target(parties, get_parties()),

  # Polls
  ## Verian
  tar_file_read(
    verian_polls,
    "data/verian/PI250604.xls",
    read_verian_excel(!!.x)
  ),
  tar_file_read(
    gallup_polls,
    "data/verian/Politisk indeks 1953-2023.xlsx",
    read_gallup_excel(!!.x)
  ),
  ## Epinion
  tar_group_by(epinion_poll_list, get_epinion_poll_list(), id),
  tar_target(
    epinion_polls,
    get_epinion_polls(epinion_poll_list, parties),
    pattern = map(epinion_poll_list)
  ),

  ## Merged
  tar_target(
    polls,
    bind_polls(election_dates, verian_polls, gallup_polls, epinion_polls)
  ),

  ## House effects
  tar_target(
    house_effects,
    calc_house_effects(
      election_results,
      election_dates,
      polls,
      parties
    )
  ),

  # Correlation matrixes
  ## Vote correlations
  tar_target(vote_correlation, get_vote_correlation(mcp_hist_results)),
  tar_target(vote_covariance, cor(vote_correlation)),
  ## Municipality correlations
  tar_target(municipality_correlation, get_municipality_correlation(mcp_info)),
  tar_target(municipality_covariance, cor(municipality_correlation)),
  ## Region correlations
  tar_target(region_correlation, get_region_correlation(mcp_info)),
  tar_target(regions_covariance, cor(region_correlation)),
  ## Matrix
  tar_target(
    C,
    construct_correlation_matrix(
      vote_covariance,
      # municipality_covariance,
      regions_covariance
    )
  ),

  # Calculate prior
  tar_target(prior_model, fit_prior_model(mcp_hist_results)),
  tar_target(prior, predict_priors(prior_model, mcp_hist_results))
  # tar_target(mu_b_prior, get_mu_b_prior(house_effects))
)
