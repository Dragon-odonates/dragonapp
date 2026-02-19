# dragonapp

Shiny app for exploring [Dragon](https://www.fondationbiodiversite.fr/en/the-frb-in-action/programs-and-projects/le-cesab/funbiodiv/) occupancy model. You can run the shinyApp locally, or use it [online](https://rfrelat-cesab.shinyapps.io/dragon-spatiotemp/).


## Run the shiny-app locally

First, you need to install this R-package with the following step:

```r
## Install < remotes > package (if not already installed) ----
if (!requireNamespace(c("remotes"), quietly = TRUE)) {
  install.packages(c("remotes"))
}

## Install < dragonapp > from GitHub ----
remotes::install_github("Dragon-odonates/dragonapp")
```

Then you can run the Shiny app locally with the function `runShiny()`:  

```r
## load < dragonapp> package
library(dragonapp)

# run the Shiny app locally
runShiny()
```



## Add or update occupancy data  

#### 1. Add the occupancy data into the shiny app

```r
# Select the folder with raw output of occupancy model
folder <- here::here("data", "psi_50k2S")
# Add a name for your dataset (if the dataset is already existing, it will be overwrite)
name <- "psi_50k2S" 

# Transform the raw data to dataset readable to shiny app
# The output is saved in the app repository (= you must be able to write on it)
add_shiny_data(folder, name, overwrite = TRUE)
```

#### 2. Run the shiny app

```r
# run the Shiny app locally
runShiny()
```

#### 3. (Optional) deploy the shiny app to shinyapps.io

*This feature has not been tested yet*
```r
app_path <- system.file("app", package = "dragonapp")
# deploy the shinyapp to online server
rsconnect::deployApp(
    appDir = app_path,
    appFiles = rsconnect::listDeploymentFiles(app_path),
    appName = "Dragon occupancy output",
    appTitle = "Dragon Species distribution"
)
```