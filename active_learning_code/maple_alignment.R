source("package_requirements.R")

# Specify the name of AL file folder
new_folder <- "AL_loop_files"

# Check if the folder already exists
if (!dir.exists(new_folder)) {
  # Create the folder
  dir.create(new_folder)
  
  # Print a confirmation message
  cat("Folder created:", new_folder, "\n")
} else {
  # Print a message if the folder already exists
  cat("Folder already exists:", new_folder, "\n")
}

# Combine previous sequence set and domestic sequence set
seq_selection <- c(initialisation,
                    meta_seqs$id[meta_seqs$collection_location == "domestic"])

# Subsample genetic sequences
seqs_list <- as.list(gendist_seqs)
ind <- match(seq_selection, names(seqs_list))
write_seqs <- seqs_list[ind]
write_states <- meta_seqs[meta_seqs$id %in% seq_selection,
                          c(1,3)]

# Write output FASTA file
write.FASTA(write_seqs,
          file = "AL_loop_files/sequence_alignment.fasta")

# Write output states file
write.table(write_states,
            file = "AL_loop_files/states_file.csv", sep = ",", row.names = FALSE,
            quote = FALSE, col.names = c("taxa", "location"))
