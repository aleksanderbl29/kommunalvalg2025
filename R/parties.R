parties <- aleksandeR::parties |>
  dplyr::select(party_code, party_name) |>
  tibble::add_row(party_code = c("K", "D", "Q"),
          party_name = c("KristenDemokraterne", "Nye Borgerlige", "Frie Grønne, Danmarks Nye Venstrefløjsparti"))
