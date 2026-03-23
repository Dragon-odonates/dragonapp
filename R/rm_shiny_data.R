#' Remove dataset from shinyapp
#'
#' @param label name of the dataset to be removed
#' @param rm.last whether removing the data if it is the last one
#'
#' @export
#'
rm_shiny_data <- function(
  label = "psi",
  rm.last = FALSE
) {
  # Create folder to save the dataset
  dirpack <- path.package("dragonapp", quiet = FALSE)
  ndataset <- list.dirs(file.path(dirpack, "app", "data"), recursive = FALSE) |>
    length()
  dirfile <- file.path(dirpack, "app", "data", label)
  if (!file.exists(dirfile)) {
    stop("No dataset called `label` was found.")
  } else {
    if (ndataset > 1 | rm.last) {
      unlink(dirfile, recursive = TRUE)
    }
  }
}
