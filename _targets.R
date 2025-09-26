library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tidyverse", "dkstat", "geodk", "lubridate", "tidylog"),
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
  tar_target(turnout_pct, get_turnout_pct(today_date))
)
