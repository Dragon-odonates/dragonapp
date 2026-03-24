#' Get about markdown file
#'
#' @param dir a directory path where about.md will be saved
#' @param overwrite whether existing file will be overwritten
#' @export
#'
get_about_md <- function(dir, overwrite = TRUE) {
  # Get the direction of about.md in the package
  dirfile <- file.path(find_shinyapp(), "about.md")

  # Make sure the directory exist
  if (!file.exists(dir)) {
    dir.create(dir)
  }
  # copy about.md at the desired location
  if (!file.copy(dirfile, dir, overwrite = overwrite)) {
    warning("The export was aborted.")
  }
}


#' Update the about markdown file
#'
#' @param file a file path to a markdown file
#'
#' @export
#'
update_about_md <- function(file) {
  stopifnot("`file` must be a `.md` file." = {
    tools::file_ext(file) == "md"
  })

  # Get the direction of about.md in the package
  oldfile <- file.path(find_shinyapp(), "about.md")

  # copy about.md at the desired location
  if (!file.copy(file, oldfile, overwrite = TRUE)) {
    warning("Error: the update was aborted.")
  }
}
