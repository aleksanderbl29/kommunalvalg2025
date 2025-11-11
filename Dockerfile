FROM rstudio / plumber
LABEL org.opencontainers.image.authors = "Docker User <docker@user.org>"

RUN R - e "install.packages('bslib'); install.packages('crew'); install.packages('curl'); install.packages('dkstat', repos = c('https://ropengov.r-universe.dev', 'https://cloud.r-project.org')); install.packages('geodk', repos = c('https://ropengov.r-universe.dev', 'https://cloud.r-project.org')); install.packages('glue'); install.packages('gt'); install.packages('httr2'); install.packages('lubridate'); install.packages('markdown'); install.packages('qs2'); install.packages('rstudioapi'); install.packages('shiny'); install.packages('shinyWidgets'); install.packages('shinybusy'); install.packages('tidyverse'); install.packages('visNetwork'); install.packages('stantargets'); install.packages('plumber2');"

CMD["/app/plumber.R"]
