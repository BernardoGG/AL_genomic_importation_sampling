source("package_requirements.R")

#### Functions #################################################################
## Annotate the tree with the JSON annotations
annotate_tree <- function(tree, annotations) {
  # Initialize lists to hold annotations for tips and nodes
  tip_annotations <- vector("list", length(tree$tip.label))
  node_annotations <- vector("list", length(tree$node.label))
  
  # Traverse each tip in the tree
  for (i in 1:length(tree$tip.label)) {
    node_label <- tree$tip.label[i]
    if (node_label %in% names(annotations)) {
      tip_annotations[[i]] <- annotations[[node_label]]$location
    } else {
      tip_annotations[[i]] <- NA  # Use NA for missing annotations
    }
  }
  
  # Traverse each node in the tree
  for (i in 1:length(tree$node.label)) {
    node_label <- tree$node.label[i]
    if (node_label %in% names(annotations)) {
      node_annotations[[i]] <- annotations[[node_label]]$location
    } else {
      node_annotations[[i]] <- NA  # Use NA for missing annotations
    }
  }
  
  # Attach annotations to the tree object
  tree$tip_locations <- tip_annotations
  tree$node_locations <- node_annotations
  
  return(tree)
}

locs <- geo_tree$tip_locations |> unlist() |> unique()

# Find all descendant nodes of a given node
find_descendants <- function(tree, node) {
  descendants <- c()
  children <- tree$edge[tree$edge[,1] == node, 2]
  for (child in children) {
    descendants <- c(descendants, child, find_descendants(tree, child))
  }
  return(descendants)
}

# Check if all descendants are labeled 'domestic'
all_domestic <- function(tree, node, node_labels) {
  descendants <- find_descendants(tree, node)
  return(all(node_labels[descendants] == locs[1]))
}

# Find all 'intl_source' descendants of a given node
find_intl_descendants <- function(tree, node, node_labels) {
  descendants <- find_descendants(tree, node)
  intl_descendants <- descendants[node_labels[descendants] == locs[2]]
  return(intl_descendants)
}

#### Operations ################################################################
## Import MAPLE phylogenetic tree
tree <- read.tree("AL_loop_files/output_tree.tree")

## Import augur tree annotations
annotations <- fromJSON("AL_loop_files/annotated_tree.json") |> pluck('nodes')

## Annotate the tree
geo_tree <- annotate_tree(tree, annotations)

## Identify nidpins
# Extract tip and node labels
geo_labels <- c(geo_tree$tip_locations, geo_tree$node_locations)

# Initialize lists to hold the results
tl_list <- list()
intl_descendants_list <- list()

# Traverse all nodes to find transmission lineages
for (node in (length(geo_tree$tip.label) + 1):(length(geo_tree$tip.label) + geo_tree$Nnode)) {
  if (geo_labels[node] == locs[2] && all_domestic(geo_tree, node, geo_labels)) {
    tl_list <- c(tl_list, list(node))
    intl_descendants_list <- c(intl_descendants_list, list(find_intl_descendants(geo_tree, node, geo_labels)))
  }
}

# Print the results
print("Domestic transmission lineages with no international sequences:")
print(tl_list)

print("Int descendants of the identified clades:")
print(int_descendants_list)

#### Sandbox ###################################################################


# Optional: write the annotated tree to a new Newick file
write.tree(annotated_tree, file = "annotated_tree.tree")

# Plot the annotated tree (optional)
plot(annotated_tree, show.node.label = TRUE)


# Gets loc from name of strain.
#get_loc <- function(string,delimiter,index,reverse=FALSE){
#    if(reverse==TRUE){
#        splitted = strsplit(string,split=delimiter,fixed=T)
#        reved = lapply(splitted,rev)
#        return(lapply(reved,"[[",index))
#    }
#    else{
#    return(lapply(strsplit(string,split=delimiter,fixed=T),"[[",index))
#    }
#}

## This function returns the location of sequence n.
## It expects a data frame with columns 'id' and 'collection_location'.
#get_loc_from_meta <- function(n, metadf){
#    loc <- (metadf %>% filter(id==n))$collection_location
#    return(as.character(loc))
#}

## This function gets the location trait for each sequence in name_array.
## The metadata file must have a 'collection_location' and a 'id' column.
#get_loc_array_meta <- function(name_array, meta){
#    locs <- sapply(name_array, get_loc_from_meta, metadf = meta)
#    return(as.character(locs))
#}