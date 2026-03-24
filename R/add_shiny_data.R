#' Calculate the average occupancy per country and per time step
#'
#' @param sp_files Vector of paths to psi files (qs/rds/csv objects)
#' @param grid_file Path to a grid file (gpkg object)
#' @param sp_list Species name corresponding to each of the file in sp_files
#' @param label name of the dataset
#' @param country a `terra::SpatVector` object with the country definition
#' @param overwrite whether existing data will be overwritten
#'
#' @returns A `data.frame` with the grid_id in rows and country in columns
#'
#' @export
#'
add_shiny_data <- function(
  sp_files,
  grid_file,
  sp_list = remove_common_strings(sp_files),
  label = "test",
  country = rnaturalearth::ne_countries(
    country = c(
      "Austria",
      "Belgium",
      "Cyprus",
      "Czechia",
      "Denmark",
      "Finland",
      "France",
      "Germany",
      "Ireland",
      "Isle of Man",
      "Italy",
      "Luxembourg",
      "Netherlands",
      "Norway",
      "Portugal",
      "Slovenia",
      "Spain",
      "Sweden",
      "Switzerland",
      "United Kingdom"
    ),
    scale = 10
  ),
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
  stopifnot(
    "`sp_files` must contains `.qs`, `.rds` or `.csv` files." = {
      all(tools::file_ext(sp_files) %in% c("rds", "qs", "csv"))
    }
  )
  stopifnot("Incorrect file naming" = {
    length(sp_list) == length(sp_files) & all(sp_list != "")
  })
  # Create folder to save the dataset
  dirdata <- file.path(find_shinyapp(), "data")
  dirfile <- file.path(dirdata, label)
  if (!file.exists(dirfile)) {
    dir.create(dirfile)
  } else {
    if (!overwrite) {
      stop("A dataset with the same `label` already exist.")
    } else {
      rm_shiny_data(label, rm.last = TRUE)
      dir.create(dirfile)
    }
  }
  # Format occupancy per grid as spatial vector
  gd <- get_poly_occupancy(grid, sp_files, sp_list)
  saveRDS(data.frame(gd), file.path(dirfile, "grid_df.rds"))
  terra::writeVector(
    gd[, "grid_id"],
    file.path(dirfile, "grid.gpkg"),
    overwrite = overwrite
  )
  # Calculate the weighted mean per country
  df <- get_ts_country(grid, sp_files, sp_list, country)
  utils::write.csv(df, file.path(dirfile, "ts_country.csv"), row.names = FALSE)

  invisible(list("pt" = gd, "ts" = df))
}
