#' Calculate the country coverage per grid cell
#'
#' @param grid a `terra::SpatVector` object with the grid
#' @param country a `terra::SpatVector` object with the country definition
#' @param th coverage threshold value to keep countries in
#' @returns A `data.frame` with the grid_id in rows and country in columns
#'
#' @export
#'
get_area_country <- function(
  grid,
  country = rnaturalearth::ne_countries(country = c("Austria", "Belgium", "Cyprus", "Czechia",
                                                    "Denmark", "Finland", "France", "Germany",
                                                    "Ireland", "Isle of Man", "Italy", "Luxembourg", 
                                                    "Netherlands", "Norway", "Portugal", "Slovenia", "Spain", 
                                                    "Sweden", "Switzerland", "United Kingdom"), 
                                        scale = 10),
  th = 0.5
) {
  stopifnot("`grid` must be a `SpatVector`." = {
    "SpatVector" %in% class(grid)
  })
  stopifnot("`grid_id` must be in `grid`." = {
    "grid_id" %in% names(grid)
  })
  if ("sf" %in% class(country)) {
    country <- terra::vect(country)
  }
  stopifnot("`country` must be a `SpatVector`." = {
    "SpatVector" %in% class(country)
  })
  stopifnot("`admin` must be in `country`." = {
    "admin" %in% names(country)
  })

  # calculate the intersection
  int_country <- terra::intersect(country, grid)
  # transform to wide per grid_id and country
  area_country <- tapply(
    terra::expanse(int_country),
    list(int_country$grid_id, int_country$admin),
    mean
  )
  # replace NA per 0
  area_country[is.na(area_country)] <- 0
  # transform to data.frame
  area_country <- data.frame(area_country, check.names = FALSE)
  # remove countries that are too partially covered
  sum_country <- tapply(terra::expanse(int_country), int_country$admin, sum)
  perc_country <- sum_country /
    terra::expanse(country[match(names(sum_country), country$admin)])
  area_country <- area_country[, names(perc_country)[perc_country > th]]
  # add information on total surface on countries of interest
  area_country$All <- rowSums(area_country)
  # should we remove grid cell with no coverage ?
  # table(area_country$All == 0)
  return(area_country)
}

#' Calculate the average occupancy per country and per time step
#'
#' @param grid a `terra::SpatVector` object with the grid
#' @param oc_list vector of files containing the occupancy probabilities
#' @param sp_list species name corresponding to `oc_list`
#' @param country a `terra::SpatVector` object with the country definition
#' @param digits integer indicating the number of decimal places to be kept.
#' @returns A `data.frame` with the grid_id in rows and country in columns
#'
#' @export
#'
get_ts_country <- function(
  grid,
  oc_list,
  sp_list,
  country = rnaturalearth::ne_countries(country = c("Austria", "Belgium", "Cyprus", "Czechia",
                                                    "Denmark", "Finland", "France", "Germany",
                                                    "Ireland", "Isle of Man", "Italy", "Luxembourg", 
                                                    "Netherlands", "Norway", "Portugal", "Slovenia", "Spain", 
                                                    "Sweden", "Switzerland", "United Kingdom"), 
                                        scale = 10),
  digits = 5
) {
  # Checking the inputs ------------
  # transform sf object into terra::vect
  if ("sf" %in% class(grid)) {
    grid <- terra::vect(grid)
  }
  stopifnot("`grid` must be a `SpatVector`." = {
    "SpatVector" %in% class(grid)
  })
  stopifnot("`grid` must contains 'polygons`." = {
    terra::is.polygons(grid)
  })
  stopifnot("`grid_id` must be in `grid`." = {
    "grid_id" %in% names(grid)
  })
  stopifnot("`oc_list` and `sp_list` must have the same length." = {
    length(oc_list) == length(sp_list)
  })
  if ("sf" %in% class(country)) {
    country <- terra::vect(country)
  }
  stopifnot("`country` must be a `SpatVector`." = {
    "SpatVector" %in% class(country)
  })
  stopifnot("`admin` must be in `country`." = {
    "admin" %in% names(country)
  })
  area_country <- get_area_country(grid, country)
  # Make a large
  tsout <- list()
  for (i in seq_along(oc_list)) {
    # load data
    # dfi <- readRDS(oc_list[i])
    dfi <- qs2::qs_read(oc_list[i])
    # rapid check
    stopifnot("rds file must have columns `median`, `grid_id`, `year`." = {
      all(c("median", "grid_id", "year") %in% names(dfi))
    })

    for (y in sort(unique(dfi$year))) {
      dfy <- dfi[dfi$year == y, c("grid_id", "median")]
      med <- dfy$median[match(row.names(area_country), dfy$grid_id)]
      outi <- data.frame(
        "species" = sp_list[i],
        "year" = y,
        "country" = names(area_country),
        "mean" = sapply(1:ncol(area_country), function(i) {
          stats::weighted.mean(med, area_country[, i], na.rm = TRUE)
        })
      )
      tsout[[length(tsout) + 1]] <- outi
    }
  }
  # merge into a data.frame
  df <- do.call(rbind, tsout)
  # round values to make file smaller (does that actually work?)
  df$mean <- round(df$mean, digits)
  return(df)
}
