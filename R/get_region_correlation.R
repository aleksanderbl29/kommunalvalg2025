get_region_correlation <- function(mcp_info) {
  mcp_info |>
    select(kommune, region) |>
    filter(!kommune == "Christiansø") |>
    mutate(value = 1) |>
    pivot_wider(
      names_from = region,
      values_from = value,
      values_fill = 0
    ) |> # pivot df to wide format (regions as cols and municipalities as rows)
    janitor::clean_names() |>
    coerce_to_correlation()
}
