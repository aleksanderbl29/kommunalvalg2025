library(targets)
library(tarchetypes)
library(stantargets)
library(glue)

tar_option_set(
  packages = c("tidyverse", "glue", "dkstat", "geodk", "lubridate", "httr2"),
  format = "qs",
  seed = 42,
  controller = crew::crew_controller_local(workers = 4, seconds_idle = 60)
)
tar_source()

list(
  tar_target(this_week, week(today("CET"))),

  # Municipality level data
  tar_target(mcp_geo, get_mcp_geo(this_week)),
  tar_target(mcp_pop, get_mcp_pop(this_week)),
  tar_target(mcp_accounts, get_mcp_accounts(this_week)),
  tar_target(mcp_daycare_pricing, get_mcp_daycare_pricing(this_week)),
  tar_target(turnout_pct, get_turnout_pct(this_week)),

  # Election results
  tar_file_read(election_dates, "data/dst/Valg.csv", read_election_dates(!!.x)),
  tar_file_read(election_results, "data/dst/ValgData.csv", read_election_results(!!.x, election_dates)),

  # Valg.dk
  tar_group_by(kv_election_overview, get_kv_election_overview(), id),
  tar_target(kv_data, get_kv_data_csv(kv_election_overview), pattern = map(kv_election_overview)),

  # Polls
  tar_file_read(verian_polls, "data/verian/PI250604.xls", read_verian_excel(!!.x)),
  tar_file_read(gallup_polls, "data/verian/Politisk indeks 1953-2023.xlsx", read_gallup_excel(!!.x)),
  tar_target(polls, dplyr::bind_rows(verian_polls, gallup_polls))#,

  # Calculation of prior
  # tar_target(mcp_deviation, calculate_poll_result_deviation(polls, election_results)),
)
