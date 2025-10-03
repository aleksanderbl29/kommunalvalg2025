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

generate_data <- function(n = 10) {
  true_beta <- stats::rnorm(n = 1, mean = 0, sd = 1)
  x <- seq(from = -1, to = 1, length.out = n)
  y <- stats::rnorm(n, x * true_beta, 1)
  list(n = n, x = x, y = y, true_beta = true_beta)
}

list(
  tar_target(today_date, today("CET")),
  tar_target(mcp_geo, get_mcp_geo(today_date)),
  tar_target(mcp_pop, get_mcp_pop(today_date)),
  tar_target(mcp_accounts, get_mcp_accounts(today_date)),
  tar_target(mcp_daycare_pricing, get_mcp_daycare_pricing(today_date)),
  tar_target(turnout_pct, get_turnout_pct(today_date)),
  tar_download(verian_pdf_downloads, verian_poll_urls, path = glue("data/verian/{basename(verian_poll_urls)}")),
  tar_files(verian_pdf_paths, verian_pdf_downloads),
  tar_target(verian, get_verian_polls_from_pdf(verian_pdf_paths), pattern = map(verian_pdf_paths)),
  tar_stan_mcmc(
    example,
    "x.stan",
    generate_data(),
    stdout = R.utils::nullfile(),
    stderr = R.utils::nullfile()
  ),
  tar_stan_summary(
    custom_summary,
    fit = example_mcmc_x,
    summaries = list(~posterior::quantile2(.x, probs = c(0.25, 0.75)))
  )
)
