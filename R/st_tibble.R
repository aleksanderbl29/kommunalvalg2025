st_tibble <- function(df) {
  df |>
    st_drop_geometry() |>
    as_tibble()
}
