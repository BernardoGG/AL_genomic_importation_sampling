source("package_requirements.R")
source("init_df.R")

# Extract the feature of interest - collection location
collection_location <- meta_seqs$collection_location

# Identify indices for collection location features
domestic_indices <- which(collection_location == "domestic")
intl_indices <- which(collection_location == "intl_source")

# Initialize a vector to identify international items which are closest to
# individual domestic items
closest_international_to_domestic <- integer(length(domestic_indices))

# Initialize a vector to keep track of international items that have already been 
# selected as closest to a domestic item
already_selected <- rep(FALSE, length(intl_indices))

# Iterate over each domestic item
for (i in seq_along(domestic_indices)) {
  idx <- domestic_indices[i]
  distances_to_intl <- gdist_seqs_dm[idx, intl_indices]

  # Exclude international items that have already been selected as nearest to a domestic item
  distances_to_intl[already_selected] <- Inf
    
  # Find the index of the closest international item
  closest_international_index <- intl_indices[which.min(distances_to_intl)]
    
  # Store the index of the nearest international item for domestic item i
  closest_international_to_domestic[i] <- closest_international_index
  
  # Mark the selected international item as already selected
  already_selected[closest_international_index - min(intl_indices) + 1] <- TRUE
}

# Data frame with nearest neighbors
initialisation_df <- meta_seqs[closest_international_to_domestic, ]

# List of initialisation sequence set
initialisation <- initialisation_df$id
