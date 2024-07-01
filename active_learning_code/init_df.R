source("package_requirements.R")

# Create data frame that matches genetic distance matrix item order
meta_seqs <- meta_all |> filter(id %in% names(gendist_seqs))
meta_seqs <- meta_seqs[match(rownames(gdist_seqs_dm), meta_seqs$id),]
rownames(meta_seqs) <- NULL