
# Exploration of interactive dashboards in R with large spatio-temporal dataset

Large spatio-temporal datasets are a challenge for creating light dashboards with interactive maps in R.   
Here is an exploration of different options to display the spatial distribution per species and per year.  


## Traditional Shiny app
The easiest way to create a dashboard in R is use Shiny. The main disadvantage is that it needs to be hosted on a shiny server, which is harder to integrate on a normal website. Another problem is that the (free version of) shinyapps.io server is limited.  


#### 50km grid
Dataset is relatively light with each line being a unique combination of `species` (N=105) x `year` (N=35) x `gridID` (N=1151). The dataset is made of 483.662 rows, and the file saved as `.rds` weight 1.9Mb. The definition of the grid is a geopackage file of 250kb. The app can be found here: 
<https://rfrelat-cesab.shinyapps.io/dragon-vect50/> (1Mb bundle)


``` r
shiny::runApp("app_vect50")
```

``` r
fileapp <- c(
  "data/occ_50.rds",
  "data/points_50.gpkg",
  "global.R",
  "server.R",
  "ui.R"
)
rsconnect::deployApp(
  appDir = "app_vect50",
  appFiles = fileapp,
  appName = "dragon-vect50",
  appTitle = "Dragon Species distribution"
)
# 1Mb bundle
```

#### 10km grid

Dataset is heavier with 18101 different `gridID` (N=18101), and 1.878.451 rows (`.rds` file weight 7.5Mb). The definition of the grid is a geopackage file of 2.5Mb. The app can be found here: <https://rfrelat-cesab.shinyapps.io/dragon-vect10/> (10km grid, 4Mb bundle)

``` r
shiny::runApp(here("app_vect10"))

rsconnect::deployApp(
  appDir = "app_vect10",
  appFiles = list.files("app_vect10", recursive = TRUE),
  appName = "dragon-vect10",
  appTitle = "Dragon Species distribution"
)
# 4Mb bundle
```





**Advantages:**  

- easy to build and improve
- runs quite fast with a 50km resolution, slower with 10km


**Disadvantages:**

- need to be hosted on a R-shiny server
- free option are limited in size so resolution is limited (10km resolution is slow on free hosting platforms)


## shinylive option

Recently, it was made possible to deploy shiny apps on normal webpages with the packages `webr` and `shinylive`. More information at <https://posit-dev.github.io/r-shinylive/>.

``` r
# export vect50
shinylive::export("app_vect50", "docs", subdir = "vect50")
# site/app.json (2.81M bytes)

# export vect10
shinylive::export("app_vect10", "docs", subdir = "vect10")
# site/vect10/app.json (11.6M bytes)

# then check them out:
httpuv::runStaticServer("docs/")
# then add
# http://127.0.0.1:7446/vect10/
# http://127.0.0.1:7446/vect50/
```

The app with the 50km grid can be found here (3Mb)
<https://dragon-odonates.github.io/dragonapp/vect50> 


The app with the 10km grid can be found here (13Mb)
<https://dragon-odonates.github.io/dragonapp/vect10>  



## Abandoned options

### Crosstalk option
More info: <https://rstudio.github.io/crosstalk/>
See also: <https://plotly-r.com/client-side-linking>

Advantage:
- simple html to load, so it can be hosted on any website (e.g. github pages)
- dataset are somehow also loaded by users

Disadvantage:
- limited in the interaction, no mathematical operation can be made in dataset so everything has to be pre-computed

```{r}
#| eval: false
quarto::quarto_render(
  here::here("crosstalk", "all_species_dash.qmd"),
)
```

## Multiple html page, one per species

We could also create (automatically with quarto) one html page per species. It would be mutliple static webpages with interactive maps, but html are heavy (10Mb per species on average)
```{r}
#| eval: false
# test with one species
quarto::quarto_render(
  here::here("crosstalk", "single_species_dash.qmd"),
  execute_params = list(species = "Aeshna subarctica"),
)

# run over all species
points <- readRDS(here::here("data", "derived-data", "cells_10000.rds"))

splist <- sort(unique(points$species))

for (i in splist) {
  outfile <- paste0("dist-", gsub(" ", "-", i), ".html")
  # render quarto for species i
  quarto::quarto_render(
    here::here("analyses", "single_species_dash.qmd"),
    execute_params = list(species = i),
  )
  # move file
  copycheck <- file.copy(
    from = here::here("analyses", "species_dash.html"),
    to = here::here("docs", outfile),
    copy.mode = FALSE,
    overwrite = TRUE
  )
  if (copycheck) {
    file.remove(here::here("analyses", "species_dash.html"))
  } else {
    warnings(paste0("errors while copying file for species", i))
  }
}
```


## Examples and options to be tested

#### European Breeding Bird Atlas 2
<https://ebba2.info/maps/>  
> extent: Europe  
> spatial: 50km distribution map  
> temporal: no time series  
> what: distribution map per species + community indices
> technology: javascript, maptile?

#### Live EBP Viewer
<https://eurobirdportal.org/>  
> extent: Europe 
> spatial : 50km for observation, 10km for breeding
> temporal: weekly from 2024 to 2025
> what: comparison of species distribution maps and seasonal trends
> technology: https://carto.com/ (paid option)

#### Noisemap
<https://data.noise-planet.org/map_noisecapture/noisecapture_party.html#18/48.86530/2.34699/HBM2022>
> technology: leaflet + orbisGIS? or shiny?
<https://github.com/Universite-Gustave-Eiffel/NoiseCapture/tree/master>
<https://github.com/Universite-Gustave-Eiffel/NoiseModelling>

#### Geopal
<https://carto.geopal.org/1/carte_regionale.map>

#### gridviz
<https://github.com/eurostat/gridviz>

#### Global mapper
<https://www.bluemarblegeo.com/global-mapper/>

#### Google Earth Engine
maybe the most commun way to visualize large and heavy spatial data; need to make data public

## Forms and feedback gathering
https://daattali.com/shiny/mimic-google-form/
https://github.com/daattali/shiny-server/blob/master/mimic-google-form/app.R
https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
https://github.com/daattali/UBC-STAT545/tree/master/shiny-apps/request-basic-info