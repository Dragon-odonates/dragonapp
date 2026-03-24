function(input, output, session) {
  ## Reactive input ----------------
  output$inSpe <- renderUI({
    req(input$set)
    df <- get_ts()
    sp_choices <- sort(unique(df$species))
    selectInput(
      "spe",
      "Species:",
      choices = sp_choices,
      selected = sp_choices[1],
      multiple = FALSE
    )
  })

  output$inYear <- renderUI({
    req(input$set)
    df <- get_ts()
    yr_range <- sort(unique(df$year, na.rm = TRUE))
    sliderInput(
      "year",
      "Year",
      min = min(yr_range),
      max = max(yr_range),
      value = min(yr_range),
      step = 1,
      sep = "",
      animate = animationOptions(
        interval = 1500,
        loop = TRUE
      )
    )
  })

  ## Reactive data subset ----------
  get_pt <- reactive({
    req(input$set)
    pt <- sf::st_read(
      file.path(folder, input$set, "grid.gpkg"),
      quiet = TRUE
    )
    pt <- sf::st_cast(pt, "POLYGON", warn = FALSE)
    pt_df <- readRDS(file.path(folder, input$set, "grid_df.rds"))
    pt <- cbind(pt, pt_df[, -1])
    return(pt)
  })

  get_ts <- reactive({
    req(input$set)
    df <- read.csv(file.path(folder, input$set, "ts_country.csv"))
    return(df)
  })

  sub_pt <- reactive({
    req(input$spe)
    pt <- get_pt()
    # if statement to avoid issue when changing dataset
    if (any(grepl(input$spe, names(pt)))) {
      spt <- pt[grepl(input$spe, names(pt))]
    } else {
      sp_choices <- gsub(".average", "", names(pt)[grepl("average", names(pt))])
      # sort(unique(get_ts()$species))
      spt <- pt[grepl(sp_choices[1], names(pt))]
    }
    return(spt)
  })

  sub_ts <- reactive({
    req(input$spe)
    df <- get_ts()
    # if statement to avoid issue when changing dataset
    if (input$spe %in% df$species) {
      sdf <- df[df$species == input$spe, ]
    } else {
      sdf <- df[df$species == sort(df$species)[1], ]
    }
    return(sdf)
  })

  colpal <- reactive({
    pts <- sub_pt()
    if (input$map == "dynamic") {
      ind <- names(pts)[-c(1, 2, ncol(pts))]
      # paste0(input$spe, ".", yr_shape)
    } else {
      ind <- names(pts)[grepl(input$map, names(pts))]
    }

    if (input$map == "slope") {
      max_abs <- max(abs(data.frame(pts)[, ind]), na.rm = TRUE)
      pal <- colorNumeric(
        palette = "RdYlBu",
        domain = c(-max_abs, max_abs),
        na.color = "transparent"
      )
    } else {
      pal <- colorNumeric(
        palette = "viridis",
        domain = unlist(data.frame(pts)[, ind]),
        na.color = "transparent"
      )
    }
    return(pal)
  })

  # Maps --------------------------------------------------------------------
  output$mapdistri <- renderLeaflet({
    req(input$spe)
    pt <- get_pt()
    leaflet(pt, options = leafletOptions(minZoom = Zmin, maxZoom = Zmax)) |>
      addTiles() |>
      setView(lng = 15, lat = 55, zoom = Z)
  })

  observe({
    pts <- sub_pt()
    pal <- colpal()
    ind <- ifelse(
      input$map == "dynamic",
      names(pts)[grepl(input$year, names(pts))],
      names(pts)[grepl(input$map, names(pts))]
    )

    leg <- ifelse(input$map == "dynamic", input$year, input$map)

    leafletProxy("mapdistri", data = pts) |>
      #clearShapes() |>
      removeGlPolygons(layerId = 'mapid') |>
      addGlPolygons(
        data = pts,
        fillColor = pal(pts[[ind]]),
        fillOpacity = 0.7,
        popup = pts[[ind]],
        layerId = 'mapid'
      ) |>
      clearControls() |>
      # fmt:skip
      addLegend_decreasing(
        position = "bottomright",
        values = pts[[ind]],
        pal = pal,
        opacity = 1,
        title = leg,
        decreasing = TRUE
      )
  })

  # Trends per species ------------------------------------------------------
  output$psits <- renderPlotly({
    req(input$year)
    dts <- sub_ts()
    num_countries <- length(unique(dts$country))
    pal <- colorRampPalette(RColorBrewer::brewer.pal(8, "Set2"))(num_countries)

    plot_ly(
      dts[dts$country != "All", ],
      x = ~year,
      y = ~mean,
      color = ~country,
      colors = pal,
      type = "scatter",
      mode = "lines+markers"
    ) |>
      add_trace(
        data = dts[dts$country == "All", ],
        x = ~year,
        y = ~mean,
        name = "all",
        type = "scatter",
        mode = "lines+markers",
        line = list(color = "black", width = 4),
        marker = list(color = "black")
      ) |>
      layout(
        xaxis = list(title = 'Year'),
        yaxis = list(title = 'Average probability'),
        shapes = list(list(
          type = "line",
          x0 = input$year,
          x1 = input$year,
          y0 = 0,
          y1 = max(dts$mean, na.rm = TRUE),
          line = list(color = "black")
        ))
      ) |>
      config(
        modeBarButtons = list(list("toImage")),
        displaylogo = FALSE
      )
  })
}
