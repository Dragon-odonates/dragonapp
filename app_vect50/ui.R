page_navbar(
       title = "Dragon shiny app - draft",
       bg = "#2D89C8",
       nav_panel(
              title = "Output",
              layout_sidebar(
                     sidebar = sidebar(
                            selectInput(
                                   "spe",
                                   "Species:",
                                   choices = sp_choices,
                                   selected = sp_choices[1]
                            ),
                            sliderInput(
                                   "yrs",
                                   "Years:",
                                   min = yr_range[1],
                                   max = yr_range[2],
                                   step = 1,
                                   value = yr_range
                            )
                     ),
                     tabsetPanel(
                            tabPanel(
                                   "N Years",
                                   withSpinner(
                                          leafletOutput('mapyrs'),
                                          type = 4
                                   )
                            ),
                            tabPanel(
                                   "N Observations",
                                   withSpinner(
                                          leaflet::leafletOutput('mapobs'),
                                          type = 4
                                   )
                            )
                     ),
                     tabsetPanel(
                            tabPanel(
                                   "N Grid cells",
                                   plotly::plotlyOutput('grdts')
                            ),
                            tabPanel(
                                   "N Observations",
                                   plotly::plotlyOutput('obsts')
                            )
                     )
              )
       ),
       nav_panel(
              title = "Feedback",
              htmlOutput("googleForm")
       )
)
