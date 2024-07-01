source("package_requirements.R")
source("active_learning_code/init_df.R")

# Extract the feature of interest - collection location
collection_location <- meta_seqs$collection_location

# Identify indices for collection location features
domestic_indices <- which(collection_location == "domestic")
intl_indices <- which(collection_location == "intl_source")

# Initialize a vector to keep track of whether each international item is closer
# to domestic items rather than other international items
closer_to_domestic_than_international <- logical(length(intl_indices))

# Loop over each international index to evaluate distances
for (i in seq_along(intl_indices)) {
  idx <- intl_indices[i]
  distances_to_domestic <- gdist_seqs_dm[idx, domestic_indices]
  distances_to_intl <- gdist_seqs_dm[idx, intl_indices]
  
  # Remove self-distance for international sequences
  distances_to_intl <- distances_to_intl[distances_to_intl != 0]
  
  # Compare minimum distances
  closer_to_domestic_than_international[i] <-
    min(distances_to_domestic, na.rm = TRUE) < min(distances_to_intl, na.rm = TRUE)
}

# Get the indices of international items that are closer to domestic items than
# to other international items
initialisation_indices <- intl_indices[closer_to_domestic_than_international]

# Data frame with nearest neighbors
initialisation_df <- meta_seqs[initialisation_indices, ]

# List of initialisation sequence set
initialisation <- initialisation_df$id
