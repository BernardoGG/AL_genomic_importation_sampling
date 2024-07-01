source("package_requirements.R")
source("init_df.R")

# Extract the features of interest - collection location and travel history
collection_location <- meta_seqs$collection_location
travel_history <- meta_seqs$travel_history

# Identify indices for collection location features
travel_yes_indices <- which(travel_history == "travel")
intl_indices <- which(collection_location == "intl_source")

# Initialize a vector to identify international items which are closest to
# individual domestic items with travel history
closest_international_to_travelhist <- integer(length(domestic_indices))

# Initialize a vector to keep track of international items that have already been 
# selected as closest to a domestic item with travel history
already_selected <- rep(FALSE, length(intl_indices))

# Iterate over each domestic item
for (i in seq_along(travel_yes_indices)) {
  idx <- travel_yes_indices[i]
  distances_to_intl <- gdist_seqs_dm[idx, intl_indices]
  
  # Exclude international items that have already been selected as nearest to a domestic item
  distances_to_intl[already_selected] <- Inf
  
  # Find the index of the closest international item
  closest_international_index <- intl_indices[which.min(distances_to_intl)]
  
  # Store the index of the nearest international item for domestic item i
  closest_international_to_travelhist[i] <- closest_international_index
  
  # Mark the selected international item as already selected
  already_selected[closest_international_index - min(intl_indices) + 1] <- TRUE
}

# Data frame with nearest neighbors
initialisation_df <- meta_seqs[closest_international_to_travelhist, ]

# List of initialisation sequence set
initialisation <- initialisation_df$id
