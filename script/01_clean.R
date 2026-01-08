# clean occ_all.rds
# select time period
# make sure coordinates are in Europe
# create ID
# save as occ_clean_all.rds

library(data.table)

# Load data ---------------------------------------------------------------
df <- readRDS("data/occ_all.rds")
# nrow(df) # 12.442.338
period <- 1990:2024 # time period of interest


# Transform dataset -------------------------------------------------------
# select based on year and full coordinates
df[, Year := year(eventDate)] # data.table syntax should be faster

keep <- !is.na(df$decimalLongitude) &
  !is.na(df$decimalLatitude) &
  df$Year %in% period
df <- df[keep, ]

# remove coordinates that are obviously not in EU
checklong <- df$decimalLongitude > 2000000 & df$decimalLongitude < 7000000
checklat <- df$decimalLatitude > 1000000 & df$decimalLatitude < 6000000
df <- df[checklong & checklat, ]

# add an id for coordinates
df[, coordinatesID := paste(decimalLongitude, decimalLatitude, sep = "_")]

# add dataset ID
df[, dbID := ifelse(is.na(parentDatasetID), datasetID, parentDatasetID)]

# add observation id
df[,
  observationID := paste(
    eventDate,
    dbID,
    recorderID,
    round(decimalLongitude / 10),
    round(decimalLatitude / 10),
    sep = "_"
  )
]

saveRDS(df, "data/occ_clean_all.rds")
