suppressPackageStartupMessages({
  require(shiny)
  require(bslib)
  require(leaflet)
  require(leafgl)
  require(plotly)
  require(here)
  require(sf)
  require(htmltools)
  require(markdown)
  require(shinycssloaders)
  require(dragonapp)
})

folder <- "data"

# load datasets
data_choices <- list.dirs(folder, recursive = FALSE, full.names = FALSE)

# Leaflet zoom parameter
Zmin <- 2
Zmax <- 7
Z <- 4

# type of maps
map_choices <- c("average", "slope", "dynamic")
