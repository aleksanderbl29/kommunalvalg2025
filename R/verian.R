estimated_verian_gallup_respondents <- 1500 # Based off e-mail correspondance with their National Director.

read_verian_excel <- function(path) {
  import <- readxl::read_excel(path)[5:21, ]

  colnames(import) <- c("party", import[1, 2:ncol(import)])

  import[3:nrow(import), 1:(ncol(import) - 2)] |>
    pivot_longer(!party, names_to = "poll_date", values_to = "value") |>
    filter(!poll_date %in% c("Valget den 1-11-2022", "38370")) |>
    separate(
      party,
      into = c("party_code", "party_name"),
      sep = " – ",
      extra = "merge"
    ) |>
    mutate(
      value = as.numeric(value),
      poll_date = dmy(poll_date),
      pollster = "Verian",
      n = estimated_verian_gallup_respondents,
      segment = "all"
    ) |>
    select(party_code, party_name, poll_date, value, segment, pollster, n)
}

read_gallup_excel <- function(path) {
  readxl::read_excel(path) |>
    select(!c(Andre, SUM)) |>
    pivot_longer(!Dato, names_to = "party", values_to = "value") |>
    separate(
      party,
      into = c("party_code", "party_name"),
      sep = " - ",
      extra = "merge"
    ) |>
    drop_na(value) |>
    rename(poll_date = Dato) |>
    mutate(
      date_from_string = suppressWarnings(dmy(poll_date)),
      date_from_excel_serial = if_else(
        is.na(date_from_string) &
          !is.na(suppressWarnings(as.numeric(poll_date))),
        as.Date(as.numeric(poll_date), origin = "1899-12-30"),
        as.Date(NA_real_)
      ),
      poll_date = coalesce(date_from_string, date_from_excel_serial),
      pollster = "Verian",
      n = estimated_verian_gallup_respondents,
      segment = "all"
    ) |>
    select(party_code, party_name, poll_date, value, segment, pollster, n)
}
