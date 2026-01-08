suppressPackageStartupMessages({
  require(shiny)
  require(bslib)
  require(shinycssloaders)
  require(leaflet)
  require(mapview)
  require(plotly)
  require(here)
  require(terra)
  require(munsell)
})

nodup <- function(x, na.rm = FALSE) {
  if (na.rm) {
    x2 <- na.omit(x)
  } else {
    x2 <- x
  }
  return(sum(!duplicated(x2)))
}

addLegend_decreasing <- function(
  map,
  position = c("topright", "bottomright", "bottomleft", "topleft"),
  pal,
  values,
  na.label = "NA",
  bins = 7,
  colors,
  opacity = 0.5,
  labels = NULL,
  labFormat = labelFormat(),
  title = NULL,
  className = "info legend",
  layerId = NULL,
  group = NULL,
  data = getMapData(map),
  decreasing = FALSE
) {
  position <- match.arg(position)
  type <- "unknown"
  na.color <- NULL
  extra <- NULL
  if (!missing(pal)) {
    if (!missing(colors)) {
      stop("You must provide either 'pal' or 'colors' (not both)")
    }
    if (missing(title) && inherits(values, "formula")) {
      title <- deparse(values[[2]])
    }
    values <- evalFormula(values, data)
    type <- attr(pal, "colorType", exact = TRUE)
    args <- attr(pal, "colorArgs", exact = TRUE)
    na.color <- args$na.color
    if (!is.null(na.color) && col2rgb(na.color, alpha = TRUE)[[4]] == 0) {
      na.color <- NULL
    }
    if (type != "numeric" && !missing(bins)) {
      warning("'bins' is ignored because the palette type is not numeric")
    }
    if (type == "numeric") {
      cuts <- if (length(bins) == 1) {
        pretty(values, bins)
      } else {
        bins
      }
      if (length(bins) > 2) {
        if (
          !all(abs(diff(bins, differences = 2)) <= sqrt(.Machine$double.eps))
        ) {
          stop("The vector of breaks 'bins' must be equally spaced")
        }
      }
      n <- length(cuts)
      r <- range(values, na.rm = TRUE)
      cuts <- cuts[cuts >= r[1] & cuts <= r[2]]
      n <- length(cuts)
      p <- (cuts - r[1]) / (r[2] - r[1])
      extra <- list(p_1 = p[1], p_n = p[n])
      p <- c("", paste0(100 * p, "%"), "")
      if (decreasing == TRUE) {
        colors <- pal(rev(c(r[1], cuts, r[2])))
        labels <- rev(labFormat(type = "numeric", cuts))
      } else {
        colors <- pal(c(r[1], cuts, r[2]))
        labels <- rev(labFormat(type = "numeric", cuts))
      }
      colors <- paste(colors, p, sep = " ", collapse = ", ")
    } else if (type == "bin") {
      cuts <- args$bins
      n <- length(cuts)
      mids <- (cuts[-1] + cuts[-n]) / 2
      if (decreasing == TRUE) {
        colors <- pal(rev(mids))
        labels <- rev(labFormat(type = "bin", cuts))
      } else {
        colors <- pal(mids)
        labels <- labFormat(type = "bin", cuts)
      }
    } else if (type == "quantile") {
      p <- args$probs
      n <- length(p)
      cuts <- quantile(values, probs = p, na.rm = TRUE)
      mids <- quantile(values, probs = (p[-1] + p[-n]) / 2, na.rm = TRUE)
      if (decreasing == TRUE) {
        colors <- pal(rev(mids))
        labels <- rev(labFormat(type = "quantile", cuts, p))
      } else {
        colors <- pal(mids)
        labels <- labFormat(type = "quantile", cuts, p)
      }
    } else if (type == "factor") {
      v <- sort(unique(na.omit(values)))
      colors <- pal(v)
      labels <- labFormat(type = "factor", v)
      if (decreasing == TRUE) {
        colors <- pal(rev(v))
        labels <- rev(labFormat(type = "factor", v))
      } else {
        colors <- pal(v)
        labels <- labFormat(type = "factor", v)
      }
    } else {
      stop("Palette function not supported")
    }
    if (!any(is.na(values))) {
      na.color <- NULL
    }
  } else {
    if (length(colors) != length(labels)) {
      stop("'colors' and 'labels' must be of the same length")
    }
  }
  legend <- list(
    colors = I(unname(colors)),
    labels = I(unname(labels)),
    na_color = na.color,
    na_label = na.label,
    opacity = opacity,
    position = position,
    type = type,
    title = title,
    extra = extra,
    layerId = layerId,
    className = className,
    group = group
  )
  invokeMethod(map, data, "addLegend", legend)
}

if (Sys.getenv('SHINY_PORT') == "") {
  options(shiny.maxRequestSize = 10000 * 1024^2)
}

folder <- "data"
# folder <- here("app_vect50", "data")
# load gis data
dt <- readRDS(here(folder, "occ_50.rds"))
pt <- vect(here(folder, "points_50.gpkg"))

sp_choices <- sort(unique(dt$species))

yr_range <- range(dt$year, na.rm = TRUE)

googleform_embed_link <- "https://docs.google.com/forms/d/e/1FAIpQLSep9uOoxrMytyqGgH7yOq5XDurYq7dJRaFJJpAujX3y6VoH0g/viewform?embedded=true"
