get_municipality_correlation <- function(df) {
  df |>
    select(kommune) |> #, region_name) |>
    mutate(value = 1) |>
    janitor::clean_names() |>
    pivot_wider(
      names_from = kommune,
      values_from = value
    ) |>
    na.omit()
}
