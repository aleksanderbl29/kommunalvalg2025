ARG R_VERSION=latest

FROM rocker/r-ver:${R_VERSION} AS plumber_base
LABEL org.opencontainers.image.authors="github@aleksanderbl.dk"

# BEGIN plumber2 layers

# `rm` call removes `apt` cache
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  libsodium-dev \
  libxml2-dev \
  libwebp-dev \
  && rm -rf /var/lib/apt/lists/*

# `rm` call removes install2.r's cache
RUN install2.r --error --skipinstalled --ncpus -1 \
  remotes \
  && rm -rf /tmp/downloaded_packages

## Remove this comment to always bust the Docker cache at this step
## https://stackoverflow.com/a/55621942/591574
#ADD https://github.com/posit-dev/plumber2/commits/ _docker_cache

ARG PLUMBER_REF=main
RUN Rscript -e "remotes::install_github('posit-dev/plumber2@${PLUMBER_REF}')"

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber2::plumb(rev(commandArgs())[1]); pr$run(host = '0.0.0.0', port = 8000)"]

# Create a basic default plumber.R if no app is provided
RUN cat > ~/plumber.R << 'EOF'
#* Say hello
#* @get /
#* @response 200 {msg: string}
function() {
  list(msg = "Hello from plumber2!")
}
EOF

CMD ["~/plumber.R"]

# EOF plumber2 layers

# README:

# Usage (adjust the tags/versions according to your preferences):

# build docker file
#   docker build --build-arg R_VERSION=4.0.2 -t plumber2:latest .
# run with defaults
#   docker run -it -p 8000:8000 --rm --name plumber2 plumber2:latest
# open in browser
#   firefox http://localhost:8000/__docs__/ &

# to run with your own api - mount your plumber.R file into the container like so:
#   docker run -it  -p 8000:8000 --rm -v ~/path/to/plumber.R:/api/plumber.R:ro --name myapi plumber2:latest /api/plumber.R
# then browse with
#   curl http://localhost:8000/


# Extend the plumber2:TAG Dockerfile / build your own custom image adding debian packages and your own api:

## ./Dockerfile
#   FROM plumber2:latest
#   RUN apt-get update -qq && apt-get install -y \
#     [list-your-debian-packages-here]
#   # add app files from host's present working dir
#   COPY . /api
#   # set default startup command to run the app's "plumber.R" file
#   CMD ["/api/plumber.R"]

FROM plumber_base

LABEL org.opencontainers.image.authors="github@aleksanderbl.dk"

RUN R -e "install.packages('bslib'); install.packages('crew'); install.packages('curl'); install.packages('dkstat', repos = c('https://ropengov.r-universe.dev', 'https://cloud.r-project.org')); install.packages('geodk', repos = c('https://ropengov.r-universe.dev', 'https://cloud.r-project.org')); install.packages('glue'); install.packages('gt'); install.packages('httr2'); install.packages('lubridate'); install.packages('markdown'); install.packages('qs2'); install.packages('rstudioapi'); install.packages('shiny'); install.packages('shinyWidgets'); install.packages('shinybusy'); install.packages('tidyverse'); install.packages('visNetwork'); install.packages('stantargets');"

COPY . /app

CMD ["/app/plumber.R"]
