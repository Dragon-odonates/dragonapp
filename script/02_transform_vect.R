library(terra)
library(sf)
library(data.table)
library(here)

count_unique <- function(x) length(unique(x))
# Load data ---------------------------------------------------------------
# from 01_clean.R
df <- readRDS(here("data", "occ_clean_all.rds"))
# nrow(df) # 12 188 091

res <- 10 # 50 or 10

vdf <- terra::vect(
  df,
  geom = c("decimalLongitude", "decimalLatitude"),
  crs = "EPSG:3035"
)

# Load grid ---------------------------------------------------------------

# use EEA grid
grid <- vect(here("data", gsub("XX", res, "grid_XXkm_surf.gpkg")))

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid, vdf)
df$gridID <- id_grid$GRD_ID

# Aggregate ---------------------------------------------------------------
ag <- aggregate(
  df$observationID,
  list(df$species, df$Year, df$gridID),
  FUN = count_unique
)
names(ag) <- c("species", "year", "gridID", "n")
# dim(ag) # 50k: 483797, 10k: 1879976
# apply(ag[, 1:3], 2, count_unique)
# 50k: 120 species, 1224 grid cells
# 10k: 120 species, 19541 grid cells

# remove species with too little grid cell
grid_per_species <- tapply(ag$gridID, ag$species, count_unique)
year_per_species <- tapply(ag$year, ag$species, count_unique)
# table(year_per_species > 10 & grid_per_species > 250/res)
# plot(grid_per_species, year_per_species, log = "x")
# abline(h = 10, v = 250/res)
keep_sp <- names(year_per_species)[year_per_species > 10 & grid_per_species > 5]
ag <- ag[ag$species %in% keep_sp, ]

# remove grid cell with too few information
obs_per_grid <- tapply(ag$n, ag$gridID, sum)
# plot(sort(obs_per_grid), log = "y")
# abline(h = floor(res / 10))
# table(obs_per_grid > floor(res / 10))
keep_grid <- names(obs_per_grid)[obs_per_grid > floor(res / 10)]
ag <- ag[ag$gridID %in% keep_grid, ]
# dim(ag) # 50k: 483485, 10k: 1878451
# apply(ag[, 1:3], 2, count_unique)
# 50k: 105 species, 1151 grid cells
# 10k: 109 species, 18101 grid cells

# Export data -------------------------------------------------------------
saveRDS(ag, gsub("XX", res, "data/occ_XX.rds"))

pts <- centroids(grid)
# keep only relevant grid cell : 1151 points
pts <- pts[pts$GRD_ID %in% ag$gridID]
# keep only relevant column
pts <- pts[, names(pts) == "GRD_ID"]
# project to latlong
pts <- project(pts, "EPSG:4326")

writeVector(
  pts,
  gsub("XX", res, "data/points_XX.gpkg"),
  overwrite = TRUE
)
