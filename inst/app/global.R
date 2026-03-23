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


# if (Sys.getenv('SHINY_PORT') == "") {
#   options(shiny.maxRequestSize = 10000 * 1024^2)
#   folder <- here("app", "data")
# } else {
#   folder <- "data"
# }
folder <- "data"

# load datasets
data_choices <- list.dirs(folder, recursive = FALSE, full.names = FALSE)

# df <- read.csv(here(folder, "ts_psi.csv"))
# pt <- sf::st_read(here(folder, "poly_psi.gpkg"), quiet = TRUE)
# pt <- sf::st_cast(pt, "POLYGON", warn = FALSE)
# sp_choices <- sort(unique(df$species))
# yr_range <- sort(unique(df$year, na.rm = TRUE))

# sp_shape <- sort(unique(first_str(names(pt)[-1])))
# yr_shape <- unique(last_str(names(pt)[-1]))

# Leaflet zoom parameter
Zmin <- 2
Zmax <- 7
Z <- 4

map_choices <- c("average", "slope", "dynamic")
