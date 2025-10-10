# https://valgdatabase.dst.dk/data?query=a93a130b-4358-4fed-8b72-aa0d8ea0c927-5

read_election_dates <- function(path) {
  read_csv2(path) |>
    select(Valgdag, ValgId) |>
    rename(valg_dato = Valgdag, valg_id = ValgId) |>
    mutate(valg_dato = ymd(valg_dato)) |>
    arrange(ymd(valg_dato))
}

read_election_results <- function(path, election_dates) {
  read_csv2(path) |>
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
    separate(col = valg, into = c("valg", "parti"), sep = " - ") |>
    mutate(
      valg = as.factor(valg),
      partinavn = case_when(
        parti == "A" ~ "Socialdemokratiet",
        parti == "B" ~ "Radikale venstre",
        parti == "C" ~ "Det Konservative Folkeparti",
        parti == "D" ~ "Nye Borgerlige",
        parti == "F" ~ "Socialistisk Folkeparti",
        parti == "G" ~ "Veganerpartiet",
        parti == "I" ~ "Liberal Alliance",
        parti == "J" ~ "Junibevægelsen",
        parti == "K" ~ "Kristendemokraterne",
        parti == "L" ~ "Lokalliste",
        parti == "O" ~ "Dansk Folkeparti",
        parti == "V" ~ "Venstre, Danmarks Liberale Parti",
        parti == "Æ" ~ "Danmarksdemokraterne - Inger Støjberg",
        parti == "Ø" ~ "Enhedslisten - De Rød-Grønne",
        parti == "Å" ~ "Alternativet",
        parti == "Stemmeberettigede" ~ "Stemmeberettigede",
        parti == "Gyldige stemmer" ~ "Gyldige stemmer"
      ),
      date = case_when(
        valg == "KV2001" ~ election_dates$valg_dato[1],
        valg == "KV2005" ~ election_dates$valg_dato[2],
        valg == "KV2009" ~ election_dates$valg_dato[3],
        valg == "KV2013" ~ election_dates$valg_dato[4],
        valg == "KV2017" ~ election_dates$valg_dato[5],
        valg == "KV2021" ~ election_dates$valg_dato[6]
      )
    )
}
