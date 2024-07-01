source("package_requirements.R")

# Import MAPLE phylogeny
maple_tree <- read.tree("output_tree.tree")
maple_tree$node.label <- NULL

# Import tip locations
tips <- meta_seqs[meta_seqs$id %in% seq_selection,]
tip_locs <- tips[match(maple_tree$tip.label, tips$id),] |>
  select(collection_location) |> pull() |> as.factor()

# Use marginal ML ancestral state reconstruction to annotate tree nodes
ace(tip_locs, maple_tree, type = "discrete", marginal = TRUE)

