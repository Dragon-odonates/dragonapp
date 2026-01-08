fluidPage(
       # Application title
       titlePanel("Exploration : shiny 10km vector"),

       sidebarLayout(
              # Sidebar with a slider input
              sidebarPanel(
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
                     ),
              ),

              mainPanel(
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
                                          leafletOutput('mapobs'),
                                          type = 4
                                   )
                            )
                     ),
                     tabsetPanel(
                            tabPanel("N Grid cells", plotlyOutput('grdts')),
                            tabPanel("N Observations", plotlyOutput('obsts'))
                     )
              )
       )
)
