parties <- aleksandeR::parties |>
  dplyr::select(party_code, party_name) |>
  tibble::add_row(
    party_code = c("K", "D", "Q"),
    party_name = c(
      "KristenDemokraterne",
      "Nye Borgerlige",
      "Frie Grønne, Danmarks Nye Venstrefløjsparti"
    )
  ) |>
  dplyr::mutate(
    party_begin = dplyr::case_when(
      # Date for the beginning of the party
      # "01-01-xxxx" is just the year
      party_code == "A" ~ "01-01-1871",
      party_code == "B" ~ "21-05-1905",
      party_code == "C" ~ "22-02-1916",
      party_code == "F" ~ "01-01-1959",
      party_code == "I" ~ "07-05-2007", # Ny alliance
      party_code == "M" ~ "01-01-2022",
      party_code == "O" ~ "06-10-1995",
      party_code == "V" ~ "01-01-1870",
      party_code == "Æ" ~ "23-06-2022",
      party_code == "Ø" ~ "01-01-1989",
      party_code == "Å" ~ "27-11-2013",
      party_code == "H" ~ "15-01-2025",
      party_code == "K" ~ "13-04-1970",
      party_code == "D" ~ "19-10-2015", # Vermud and Seier Christensen presents
                                        # the name of the party
      party_code == "Q" ~ "07-09-2020",
    ),
    party_begin = lubridate::dmy(party_begin)
  )
