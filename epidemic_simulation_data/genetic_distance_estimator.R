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
fasta <- "simulated_epidemic_seqint_0.1_sequences.fasta"
meta_full <- "cleaned_metadata_full_set.txt"

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

# Step 6. Reformat matrix into data frame format
gdist_seqs_dm <- melt(as.matrix(gdist_seqs), varnames = c("seq_1", "seq_2")) |>
  rename("dist" = "value")

# Step 7. Write genetic distance RData objects
save(gendist_seqs, file = "genetic_distance_matrix.RData")
save(gdist_seqs_dm, file = "genetic_distance_matrix_longform.RData")
