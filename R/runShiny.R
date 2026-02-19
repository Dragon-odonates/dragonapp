# runShiny ---------------------------------------
#' Run shiny app made using cuspra package functions
#'
#' @export
runShiny <- function() {
  # for test
  appDir <- system.file("app", package = "dragonapp")
  # here::here("app")
  if (appDir == "") {
    stop(
      "Could not find example directory. Try re-installing `dragonapp`.",
      call. = FALSE
    )
  }
  shiny::runApp(appDir, display.mode = "normal")
}
