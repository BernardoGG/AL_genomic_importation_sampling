## Main code
# Step 1. Load/install required packages.
required_packages <- c("hierfstat", "ape", "ade4", "tidyverse", "reshape2",
                       "lubridate", "data.table")
suppressMessages(
  for (package in required_packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package, repos = "http://cran.us.r-project.org")
    }
    library(package, character.only = TRUE)
  }
)

# Step 2. Find files with genetic sequences and metadata
fasta <- "epidemic_simulation_data/simulated_epidemic_seqint_0.1_sequences.fasta"
meta_full <- "epidemic_simulation_data/cleaned_metadata_full_set.txt"

# Step 3. Import genetic sequences
gendist_seqs <- read.FASTA(fasta, type = "DNA")
names(gendist_seqs) <- sub("\\|.*", "", names(gendist_seqs))

# Step 4. Generate data frame for metadata of genetic sequences
meta_all <- read.csv(meta_full, sep = ",") |>
  select(c(4,8,7,6)) |>
  rename("id" = "label", "date" = "Date", "collection_location" = "deme",
         "infection_location" = "type") |>
  mutate(travel_history = recode(collection_location, 'Deme_2' = "no_travel",
                                 'Deme_1' = "NA", "Imports" = "travel")) |>
  mutate(collection_location = recode(collection_location, 'Deme_2' = "domestic",
                                      'Deme_1' = "intl_source",
                                      "Imports" = "domestic")) |>
  mutate(id = str_replace(id, "leaf_", "seq_")) |>
  mutate(infection_location = recode(infection_location, 'I{1' = "domestic",
                                     'I{0' = "intl_source",
                                     'Im{0' = 'intl_source')) |>
  mutate(date = ymd(date))

meta_seqs <- meta_all |> filter(id %in% names(gendist_seqs))

# Step 5. Estimate large pairwise genetic distance matrix
# Operation might take a few hours
gdist_seqs <- dist.dna(gendist_seqs)

# Step 6. Reformat as matrix object
gdist_seqs_dm <- as.matrix(gdist_seqs)

# Step 7. Reformat matrix into data frame format
gdist_seqs_dm_long <- melt(as.matrix(gdist_seqs), varnames = c("seq_1", "seq_2")) |>
  rename("dist" = "value")

# Step 8. Write genetic distance RData objects
# Step 8a. Genetic distance matrix ID list
gdist_names <- names(gendist_seqs) |> as.data.frame()
write.table(gdist_names,
          "epidemic_simulation_data/genetic_distance_matrices/genetic_distance_matrix_names.txt",
          sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)

# Step 8b. Genetic distance matrices
save(gendist_seqs, file =
       "epidemic_simulation_data/genetic_distance_matrices/genetic_distance_matrix_dnabin.RData")
save(gdist_seqs_dm, file =
       "epidemic_simulation_data/genetic_distance_matrices/genetic_distance_matrix.RData")
save(gdist_seqs_dm_long, file =
       "epidemic_simulation_data/genetic_distance_matrices/genetic_distance_matrix_longform.RData")
