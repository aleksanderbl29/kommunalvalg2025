bulk_get_dst_table <- function(table) {
  metadata <- dst_meta(table)

  variable_names <- dkstat:::get_vars(metadata)

  query <- dkstat:::get_var_options(metadata, variable_names)

  dst_get_data(
    table = table,
    query = query,
    lang = "da",
    parse_dst_tid = TRUE,
    format = "BULK"
  )
}
