#' Export dataset for the shinyapp
#'
#' @param dir directory where to save the dataset
#' @param name name of the zip archive
#' @param overwrite whether to overwrite or not
#'
#' @export
#'
save_data <- function(
  dir,
  name = "data",
  overwrite = FALSE
) {
  if (!file.exists(dir)) {
    dir.create(dir)
  }
  fileout <- file.path(dir, paste0(name, ".zip"))
  if (file.exists(fileout)) {
    if (overwrite) {
      file.remove(fileout)
    } else {
      stop(paste("The file", fileout, "already exists."))
    }
  }
  # Make sure the working directory will stay the same on exit
  prev_wd <- getwd() # save your current working directory path
  on.exit(setwd(prev_wd))

  # find the data directory of the shiny app
  dirdata <- file.path(find_shinyapp(), "data")

  setwd(dirdata)
  all_data <- list.files(
    dirdata,
    recursive = TRUE
  )
  utils::zip(fileout, all_data)
}


#' Export dataset for the shinyapp
#'
#' @param dir directory where to save the dataset
#' @param compress indicates whether the files are in a zip archive (by default) or not
#' @param overwrite indicates if existing files are overwritten
#'
#' @export
#'
save_app <- function(
  dir,
  compress = TRUE,
  overwrite = FALSE
) {
  # Make sure the working directory will stay the same on exit
  prev_wd <- getwd() # save your current working directory path
  on.exit(setwd(prev_wd))

  # find the location of the app
  dirapp <- find_shinyapp()
  setwd(dirapp)

  # list all files in the app
  all_data <- list.files(
    dirapp,
    recursive = TRUE
  )
  # export
  if (!compress) {
    dirout <- file.path(dir, "app")
    # create the folder structure
    for (d in list.dirs(dirapp, full.names = FALSE)) {
      if (!file.exists(file.path(dirout, d))) {
        dir.create(file.path(dirout, d))
      }
    }
    # make sure to remove all previous files
    if (overwrite) {
      check1 <- file.remove(list.files(
        dirout,
        full.names = TRUE,
        recursive = TRUE
      ))
    }
    # copy files
    check2 <- file.copy(
      all_data,
      file.path(dirout, dirname(all_data), basename(all_data)),
      overwrite = TRUE
    )
  } else {
    fileout <- file.path(dir, paste0("app.zip"))
    if (file.exists(fileout)) {
      if (overwrite) {
        file.remove(fileout)
      } else {
        stop(paste("The file", fileout, "already exists."))
      }
    }
    utils::zip(fileout, all_data)
  }
}
