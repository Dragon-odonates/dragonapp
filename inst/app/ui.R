fluidPage(
       # run bslib::bs_theme_preview() to customize
       # theme = bs_theme(preset = "cosmo"),

       # Application title
       titlePanel("Distribution of odonates across Europe. DRAGON, FRB-CESAB"),
       tabsetPanel(
              id = 'main',
              tabPanel(
                     "Distribution",
                     fluidRow(
                            column(
                                   4,
                                   uiOutput('inSpe'),
                                   br()
                            ),
                            column(
                                   4,
                                   selectInput(
                                          "map",
                                          "Map:",
                                          choices = map_choices,
                                          selected = map_choices[1],
                                          multiple = FALSE
                                   )
                            ),
                            column(
                                   4,
                                   conditionalPanel(
                                          'input.map === "dynamic"',
                                          uiOutput('inYear')
                                   )
                            )
                     ),
                     fluidRow(
                            column(
                                   6,
                                   selectInput(
                                          "set",
                                          "Dataset:",
                                          choices = data_choices,
                                          selected = data_choices[1],
                                          multiple = FALSE
                                   ),
                                   card(
                                          plotly::plotlyOutput(
                                                 'psits',
                                                 height = "600px"
                                          ),
                                          full_screen = TRUE
                                   )
                            ),
                            column(
                                   6,
                                   card(
                                          shinycssloaders::withSpinner(
                                                 leafgl::leafglOutput(
                                                        'mapdistri',
                                                        height = "600px"
                                                 ),
                                                 type = 4
                                          ),
                                          full_screen = TRUE
                                   )
                            )
                     )
              ),
              tabPanel(
                     title = "About",
                     htmltools::includeMarkdown("about.md"),
              ),
       )
)
