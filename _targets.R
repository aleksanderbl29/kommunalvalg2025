library(targets)
library(tarchetypes)
library(stantargets)
library(glue)

tar_option_set(
  packages = c("tidyverse", "glue", "dkstat", "geodk", "lubridate", "pdftools"),
  format = "qs",
  seed = 42,
  controller = crew::crew_controller_local(workers = 4, seconds_idle = 60)
)
tar_source()

list(
  tar_target(today_date, today("CET")),
  tar_target(mcp_geo, get_mcp_geo(today_date)),
  tar_target(mcp_pop, get_mcp_pop(today_date)),
  tar_target(mcp_accounts, get_mcp_accounts(today_date)),
  tar_target(mcp_daycare_pricing, get_mcp_daycare_pricing(today_date)),
  tar_target(turnout_pct, get_turnout_pct(today_date)),
  tar_file_read(verian_polls, "data/verian/PI250604.xls", read_verian_excel(!!.x)),
  tar_file_read(gallup_polls, "data/verian/Politisk indeks 1953-2023.xlsx", read_gallup_excel(!!.x)),
  tar_target(polls, dplyr::bind_rows(verian_polls, gallup_polls)),

  # Calculation of prior
  # tar_target(mcp_deviation, calculate_poll_result_deviation(polls, election_results)),
)
