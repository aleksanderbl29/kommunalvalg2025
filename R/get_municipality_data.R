dst_areas_filter <- c(
  "084 Region Hovedstaden",
  "085 Region Sjælland",
  "000 Hele landet",
  "081 Region Nordjylland",
  "082 Region Midtjylland",
  "083 Region Syddanmark",
  "411 Christiansø"
)

get_mcp_geo <- function(date) {
  geodk::municipalities()
}

get_mcp_info <- function(mcp_geo) {
  mcp_geo |>
    sf::st_drop_geometry() |>
    as_tibble() |>
    mutate(kommune_id = substr(code, 2, 4), region_id = region_code) |>
    mutate(across(ends_with("_id"), as.numeric)) |>
    select(kommune_id, kommune = name, region_id, region = region_name)
}

get_mcp_pop <- function(date) {
  # bulk_get_dst_table("FOLK1AM") |>
  bulk_get_dst_table("FOLK1D") |>
    janitor::clean_names() |>
    filter(!omrade %in% dst_areas_filter) |>
    mutate(year = year(tid)) |>
    group_by(omrade, kon, alder, year) |>
    summarise(value = mean(value, na.rm = TRUE)) |>
    ungroup() |>
    select(omrade, kon, alder, year, value)
}

get_mcp_accounts <- function(date) {
  # REGK11: Kommunernes regnskaber på hovedkonti - efter område, hovedkonto,
  # dranst, art og prisenhed

  # Filtered for løbende priser pr. indbygger (kr.)
  bulk_get_dst_table("REGK11") |>
    janitor::clean_names() |>
    filter(
      str_starts(prisenhed, "INDL"),
      !omrade %in% dst_areas_filter
    ) |>
    mutate(year = year(tid)) |>
    select(omrade, funk1, dranst, art, year, value)
}

get_mcp_daycare_pricing <- function(date) {
  # RES88: Årstakster i børnepasning efter område og foranstaltningsart
  dst_get_all_data("RES88")
}
