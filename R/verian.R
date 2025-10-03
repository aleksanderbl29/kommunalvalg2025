verian_2025 <- c(
  "https://www.veriangroup.com/hubfs/Verian%20Politisk%20Indeks%2c%20LinkedIn%20Juni%202025.pdf",
  "https://www.veriangroup.com/hubfs/Verian%20Politisk%20Indeks%2c%20LinkedIn%20Maj%202025-1.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/april-2025.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/marts-2025.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/februar-2025.pdf"
)

verian_2024 <- c(
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/december-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/november-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/oktober-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/september-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/juni-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/maj-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/marts-2024.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/februar-2024.pdf"
)

verian_2023 <- c(
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/december-2023.pdf",
  "https://www.veriangroup.com/hubfs/DK/Verian-Politisk-Indeks/september-2023.pdf"
)

verian_poll_urls <- c(verian_2025) #, verian_2024, verian_2023)

get_verian_polls_from_pdf <- function(path) {
  page1 <- pdf_text(path)[1]

  lines <- str_split(page1, "\n")[[1]] |>
    str_trim()

  data_lines <- lines[str_detect(lines, "^[A-Z,Æ,Ø,Å]\\s")]

  parsed <- lapply(data_lines, parse_line) |>
    map_df(function(row) {
      # Handle variable length rows
      if (length(row) == 7) {
        # Standard case: code and name together
        tibble(
          party_code = substr(row[1], 1, 1),
          party_name = substr(row[1], 3, nchar(row[1])),
          # valg_2022 = row[2],
          # may_7_25 = row[3],
          value = row[4],
          uncertainty = row[5]
          # seats_2022 = row[6],
          # seats_jun_25 = row[7]
        )
      } else if (length(row) == 8) {
        # Case where code and name are separate (like Liberal Alliance)
        tibble(
          party_code = row[1],
          party_name = row[2],
          # valg_2022 = row[3],
          # may_7_25 = row[4],
          value = row[5],
          uncertainty = row[6]
          # seats_2022 = row[7],
          # seats_jun_25 = row[8]
        )
      } else {
        # Handle any other cases
        NULL
      }
    }) %>%
    mutate(across(3:ncol(.),
                  ~as.numeric(str_replace(., ",", "."))))

  poll_date <- get_verian_pdf_poll_date(lines)

  parsed |>
    mutate(poll_date = poll_date)
}

parse_line <- function(line) {
  parts <- str_split(line, "\\s{2,}")[[1]]
  parts <- str_trim(parts[parts != ""])
  return(parts)
}

get_verian_pdf_poll_date <- function(lines) {
  # Line 3 has "4/6-"
  date_str <- str_extract_all(lines[3], "\\d+/\\d+-")[[1]][2]  # "4/6-"

  # Line 4: Extract ALL numbers (both 2-digit and 4-digit)
  line_4_numbers <- str_extract_all(lines[4], "\\d+")[[1]]

  # Get the 3rd number
  year_str <- line_4_numbers[3]

  # Parse
  parts <- str_match(date_str, "(\\d+)/(\\d+)-")
  day <- parts[2]
  month <- parts[3]

  dmy(paste(day, month, paste0("20", year_str), sep = "-"))
}


