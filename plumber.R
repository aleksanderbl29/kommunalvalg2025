#* Run the pipeline
#*
#* This function updates the pipeline with the latest data.
#*
#* @post /pipeline/tar-make
#*
function() {
  tar_make()
}

#* Plot out data from the palmer penguins dataset
#*
#* @get /plot
#*
#* @query spec:string If provided, filter the data to only this species
#* (e.g. 'Adelie')
#*
#* @serializer png
#*
function(query) {
  myData <- penguins
  title <- "All Species"

  # Filter if the species was specified
  if (!is.null(query$spec)) {
    title <- paste0("Only the '", query$spec, "' Species")
    myData <- subset(myData, species == query$spec)
  }

  plot(
    myData$flipper_len,
    myData$bill_len,
    main = title,
    xlab = "Flipper Length (mm)",
    ylab = "Bill Length (mm)"
  )
}
