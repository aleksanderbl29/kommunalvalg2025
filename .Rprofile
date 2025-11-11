source("renv/activate.R")

if (interactive()) {
  source("~/.Rprofile")
}

library(targets)
library(tarchetypes)
# library(plumber2)
library(plumber)

tar_view <- function(target) {
  targets::tar_read_raw(target) |>
    View()
}
