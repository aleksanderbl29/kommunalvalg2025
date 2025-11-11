#* Welcome to the api
#*
#* Simple welcome message when arriving at the root path
#*
#* @get /
#* @serializer json
#*
function() {
  list(msg = "Velkommen til Aleksanders kommunalvalg 2025 analyse API")
}

#* Welcome to the api
#*
#* Simple welcome message when arriving at the root path
#*
#* @get /
#* @serializer html
#*
function() {
  "<html><h1>Velkommen til Aleksanders kommunalvalg 2025 analyse API</h1></html>"
}

#* Run the pipeline
#*
#* This function updates the pipeline with the latest data.
#*
#* @get /pipeline/tar-make
#*
function() {
  tar_make()
}

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function() {
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
  as.numeric(a) + as.numeric(b)
}
