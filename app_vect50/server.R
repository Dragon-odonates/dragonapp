function(input, output, session) {
  ## Reactive data subset ----------
  sub_df <- reactive({
    yrange <- input$yrs[1]:input$yrs[2]
    return(dt[dt$species %in% input$spe & dt$year %in% yrange, ])
  })

  sub_pt <- reactive({
    sub <- sub_df()
    nobs <- tapply(sub$n, sub$gridID, sum)
    nyr <- tapply(sub$year, sub$gridID, nodup)
    pt$nobs <- as.numeric(nobs)[match(pt$GRD_ID, names(nobs))]
    pt$nyr <- as.numeric(nyr)[match(pt$GRD_ID, names(nyr))]
    return(pt)
  })

  sub_ts <- reactive({
    sub <- sub_df()
    nobs <- tapply(sub$n, sub$year, sum)
    ngrd <- tapply(sub$gridID, sub$year, nodup)
    temp <- data.frame(
      "year" = as.numeric(names(nobs)),
      "nobs" = as.numeric(nobs),
      "ngrd" = as.numeric(ngrd)
    )
    return(temp)
  })

  # Maps --------------------------------------------------------------------
  output$mapobs <- renderLeaflet({
    pts <- sub_pt()
    mypalette <- colorNumeric(
      palette = "viridis",
      domain = pts$nobs,
      na.color = "transparent"
    )
    leaflet(pts, options = leafletOptions(minZoom = 3, maxZoom = 7)) |>
      addTiles() |>
      setView(lng = 15, lat = 55, zoom = 4) |>
      addCircles(
        radius = 25000,
        color = ~ mypalette(nobs),
        stroke = FALSE,
        fillOpacity = 0.7
      ) |>
      addLegend_decreasing(
        position = "bottomright",
        values = ~nobs,
        pal = mypalette,
        opacity = 1,
        title = "N observations",
        decreasing = TRUE
      )
  })

  output$mapyrs <- renderLeaflet({
    pts <- sub_pt()
    mypalette <- colorNumeric(
      palette = "viridis",
      domain = pts$nyr,
      na.color = "transparent"
    )
    leaflet(pts, options = leafletOptions(minZoom = 3, maxZoom = 7)) |>
      addTiles() |>
      setView(lng = 15, lat = 55, zoom = 4) |>
      addCircles(
        radius = 25000,
        color = ~ mypalette(nyr),
        stroke = FALSE,
        fillOpacity = 0.7
      ) |>
      addLegend_decreasing(
        position = "bottomright",
        values = ~nyr,
        pal = mypalette,
        opacity = 1,
        title = "N years",
        decreasing = TRUE
      )
  })

  # Trends per species ------------------------------------------------------
  output$obsts <- renderPlotly({
    dts <- sub_ts()
    plot_ly(
      dts,
      x = ~year,
      y = ~nobs,
      type = "scatter",
      mode = "lines+markers"
    ) |>
      layout(
        xaxis = list(title = 'Year'),
        yaxis = list(title = 'Number of observations')
      )
  })

  output$grdts <- renderPlotly({
    dts <- sub_ts()
    plot_ly(
      dts,
      x = ~year,
      y = ~ngrd,
      type = "scatter",
      mode = "lines+markers"
    ) |>
      layout(
        xaxis = list(title = 'Year'),
        yaxis = list(title = 'Number of grid cells')
      )
  })

  # Google form ------------------------------------------------------------
  output$googleForm <- renderUI({
    tags$iframe(
      id = "googleform",
      src = googleform_embed_link,
      width = 800,
      height = 832,
      frameborder = 0,
      marginheight = 0
    )
  })
}
