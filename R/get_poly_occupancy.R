#' Attach the occupancy outputs to the grid
#'
#' @param grid a `terra::SpatVector` object with the grid
#' @param oc_list vector of files containing the occupancy probabilities
#' @param sp_list species name corresponding to `oc_list`
#' @param digits integer indicating the number of decimal places to be kept.
#'
#' @returns A `terra::SpatVector` with occupancy summarized per species
#'
#' @export
#'
get_poly_occupancy <- function(grid, oc_list, sp_list, digits = 5) {
  # Checking the inputs ------------
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
  # transform projection if not in EPSG:4326
  if (terra::crs(grid, proj = TRUE) != "+proj=longlat +datum=WGS84 +no_defs") {
    grid <- terra::project(grid, "EPSG:4326")
  }

  # output
  gdout <- data.frame("grid_id" = grid$grid_id)

  for (i in seq_along(oc_list)) {
    # load data
    # df <- readRDS(oc_list[i])
    df <- qs2::qs_read(oc_list[i])
    # rapid check
    msg <- paste0(oc_list[i], " must have columns `median`, `grid_id`, `year`.")
    stopifnot(msg = {
      all(c("median", "grid_id", "year") %in% names(df))
    })
    # transform to wide
    wide <- tapply(df$median, list(df$grid_id, df$year), mean)
    # replace NA by 0
    wide[is.na(wide)] <- 0
    # get characteristics
    average <- apply(wide, 1, mean)
    slope <- apply(wide, 1, get_slope)
    outi <- data.frame(average, slope, wide)
    names(outi) <- paste(
      sp_list[i],
      c("average", "slope", colnames(wide)),
      sep = ";"
    )
    # round values to make dataset smaller
    outi <- apply(outi, 2, round, digits = digits)
    # attach with grid
    gdout <- cbind(gdout, outi[match(gdout$grid_id, row.names(outi)), ])
  }

  # attach to the original grid
  gd <- terra::merge(grid, gdout, by = "grid_id")
  # keep only relevant columns
  gd <- gd[, names(gdout)]
  return(gd)
}
