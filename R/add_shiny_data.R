#' Calculate the average occupancy per country and per time step
#'
#' @param folder directory containing files with occupancy probabilities and grid
#' @param label name of the dataset
#' @param country a `terra::SpatVector` object with the country definition
#' @param overwrite whether existing data will be overwritten
#'
#' @returns A `data.frame` with the grid_id in rows and country in columns
#'
#' @export
#'
add_shiny_data <- function(
  folder,
  label = "psi",
  country = rnaturalearth::ne_countries(continent = "europe"),
  overwrite = FALSE
) {
  # Checking the grid ------------
  # the folder must contains a grid file in gpkg
  stopifnot("`folder` must contains a file `grid.gpkg`." = {
    file.exists(file.path(folder, "grid.gpkg"))
  })
  grid <- terra::vect(file.path(folder, "grid.gpkg"))
  stopifnot("`grid` must contains 'polygons`." = {
    terra::is.polygons(grid)
  })
  if (terra::crs(grid, proj = TRUE) != "+proj=longlat +datum=WGS84 +no_defs") {
    grid <- terra::project(grid, "EPSG:4326")
    warning("The grid was projected to EPSG:4326")
  }
  # Checking the occupancy files -------------------------
  # occupancy files start with psi and ends with rds
  oc_list <- list.files(folder, "^psi_.*rds$", full.names = TRUE)
  # get species name
  sp_list <- gsub(file.path(folder, "psi_"), "", oc_list)
  sp_list <- gsub("\\.rds", "", sp_list)
  stopifnot("`folder` must contains `.rds` files starting with `psi_`." = {
    length(oc_list) > 0
  })
  stopifnot("Incorrect file naming" = {
    all(sp_list != "")
  })
  # Create folder to save the dataset
  dirpack <- path.package("dragonapp", quiet = FALSE)
  dirfile <- file.path(dirpack, "app", "data", label)
  if (!file.exists(dirfile)) {
    dir.create(dirfile)
  } else {
    if (!overwrite) {
      stop("A dataset with the same `label` already exist.")
    }
  }
  # Format occupancy per grid as spatial vector
  gd <- get_poly_occupancy(grid, oc_list, sp_list)
  terra::writeVector(
    gd,
    file.path(dirfile, "poly_psi.gpkg"),
    overwrite = overwrite
  )
  # Calculate the weighted mean per country
  df <- get_ts_country(grid, oc_list, sp_list)
  utils::write.csv(df, file.path(dirfile, "ts_psi.csv"), row.names = FALSE)

  invisible(list("pt" = gd, "ts" = df))
}
