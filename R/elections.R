# https://valgdatabase.dst.dk/data?query=a93a130b-4358-4fed-8b72-aa0d8ea0c927-5

read_election_dates <- function(path) {
  read_csv2(path) |>
    select(Valgdag, ValgId) |>
    rename(valg_dato = Valgdag, valg_id = ValgId) |>
    mutate(valg_dato = ymd(valg_dato)) |>
    add_row(valg_dato = date("2025-11-18"), valg_id = 999) |>
    arrange(ymd(valg_dato))
}

read_election_results <- function(path, election_dates) {
  x <- read_csv2(path) |>
    select(
      !ends_with(
        c("Afgivne stemmer", "Andre ugyldige stemmer", "Blanke stemmer")
      )
    ) |>
    rename(
      gruppe = Gruppe,
      valgsted_id = ValgstedId,
      kreds_nr = KredsNr,
      storkreds_nr = StorKredsNr,
      landsdel_nr = LandsdelsNr
    ) |>
    # naniar::replace_with_na_all(condition = ~.x == "-") |>
    mutate(across(!c("valgsted_id"), ~ str_replace_all(., ",", "."))) |>
    mutate(across(!c("valgsted_id"), as.double)) |>
    select(
      any_of(
        c(
          "gruppe",
          "valgsted_id",
          "kreds_nr",
          "storkreds_nr",
          "landsdel_nr"
        )
      ),
      starts_with("KV")
    ) |>
    pivot_longer(
      cols = starts_with("KV"),
      names_to = "valg",
      values_to = "stemmer"
    ) |>
    separate(col = valg, into = c("valg", "party_code"), sep = " - ")

  x |>
    left_join(
      x |>
        filter(party_code == "Gyldige stemmer") |>
        select(valgsted_id, valg, total_votes = stemmer) |>
        distinct(),
      by = c("valgsted_id", "valg")
    ) |>
    filter(!party_code %in% c("Stemmeberettigede", "Gyldige stemmer")) |>
    mutate(
      valg = as.factor(valg),
      date = case_when(
        valg == "KV2001" ~ election_dates$valg_dato[1],
        valg == "KV2005" ~ election_dates$valg_dato[2],
        valg == "KV2009" ~ election_dates$valg_dato[3],
        valg == "KV2013" ~ election_dates$valg_dato[4],
        valg == "KV2017" ~ election_dates$valg_dato[5],
        valg == "KV2021" ~ election_dates$valg_dato[6]
      ),
      percent = stemmer / total_votes
    ) |>
    left_join(parties, by = join_by(party_code)) |> drop_na(percent)
}
