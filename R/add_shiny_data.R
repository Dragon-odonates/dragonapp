#' Calculate the average occupancy per country and per time step
#'
#' @param psi_files Vector of paths to psi files (qs objects)
#' @param grid_file Path to a grid file (gpkg object)
#' @param label name of the dataset
#' @param country a `terra::SpatVector` object with the country definition
#' @param overwrite whether existing data will be overwritten
#'
#' @returns A `data.frame` with the grid_id in rows and country in columns
#'
#' @export
#'
add_shiny_data <- function(
  psi_files,
  grid_file,
  label = "psi",
  country = rnaturalearth::ne_countries(country = c("Austria", "Belgium", "Cyprus", "Czechia",
                                                    "Denmark", "Finland", "France", "Germany",
                                                    "Ireland", "Isle of Man", "Italy", "Luxembourg", 
                                                    "Netherlands", "Norway", "Portugal", "Slovenia", "Spain", 
                                                    "Sweden", "Switzerland", "United Kingdom"), 
                                        scale = 10),
  overwrite = FALSE
) {
  # Checking the grid ------------
  grid <- terra::vect(grid_file)
  stopifnot("`grid` must contains 'polygons`." = {
    terra::is.polygons(grid)
  })
  if (terra::crs(grid, proj = TRUE) != "+proj=longlat +datum=WGS84 +no_defs") {
    grid <- terra::project(grid, "EPSG:4326")
    warning("The grid was projected to EPSG:4326")
  }
  # Checking the occupancy files -------------------------
  # get species name
  sp_list <- sapply(psi_files, function(f) gsub("psi_", "", basename(f)))
  sp_list <- gsub("\\.qs", "", sp_list)
  stopifnot("`psi_files` must contains `.qs` files starting with `psi_`." = {
    length(psi_files) > 0
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
  gd <- get_poly_occupancy(grid, psi_files, sp_list)
  terra::writeVector(
    gd[, "grid_id"],
    file.path(dirfile, "grid_psi.gpkg"),
    overwrite = overwrite
  )
  # Calculate the weighted mean per country
  df <- get_ts_country(grid, psi_files, sp_list, country)
  utils::write.csv(df, file.path(dirfile, "ts_psi.csv"), row.names = FALSE)

  invisible(list("pt" = gd, "ts" = df))
}
