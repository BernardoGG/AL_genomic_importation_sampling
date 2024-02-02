library(hierfstat)
library(ape)
library(ade4)
library(tidyverse)
library(reshape2)
library(lubridate)
library(data.table)
library(fuzzyjoin)

### Read subsampled sequences and metadata of all simulated cases ####
#meta <- "simulation_seq_intensity_0.1/simulated_epidemic_seqint_0.1_metadata.csv"
fasta <- "simulation_seq_intensity_0.1/simulated_epidemic_seqint_0.1_sequences.fasta"
meta_full <- "simulation_seq_intensity_0.1/cleaned_metadata_full_set.txt"

# Metadata files
#meta_seqs <- read.csv(meta, sep = ",")
meta_all <- read.csv(meta_full, sep = ",") %>%
  select(c(4,8,7,6)) %>%
  rename("id" = "label", "date" = "Date", "collection_location" = "deme",
         "infection_location" = "type") %>%
  mutate(travel_history = recode(collection_location, 'Deme_2' = "no_travel",
                                 'Deme_1' = "NA", "Imports" = "travel")) %>%
  mutate(collection_location = recode(collection_location, 'Deme_2' = "domestic",
                                      'Deme_1' = "intl_source",
                                      "Imports" = "domestic")) %>%
  mutate(id = str_replace(id, "leaf_", "seq_")) %>%
  mutate(infection_location = recode(infection_location, 'I{1' = "domestic",
                                     'I{0' = "intl_source",
                                     'Im{0' = 'intl_source')) %>%
  mutate(date = ymd(date))

# Genetic sequences file
gendist_seqs <- read.FASTA(fasta, type = "DNA")
names(gendist_seqs) <- sub("\\|.*", "", names(gendist_seqs))

# Match metadata of sub-sampled sequences
meta_seqs <- meta_all %>% filter(id %in% names(gendist_seqs))


### Create data frame for sequence pool to be sampled from
# (i.e., collection location = international source)
meta_sampling_pool <- meta_seqs |>
  filter(collection_location == "intl_source") |>
  select(-travel_history, -infection_location)

# Create data frame for new weekly cases at the source
epiweek_min <- floor_date(meta_all$date, "week") |> min()
epiweek_max <- floor_date(meta_all$date, "week") |> max()

source_cases <- meta_all |>
  filter(collection_location == "intl_source") |>
  select(-travel_history, -infection_location) |>
  mutate(epiweek_start = floor_date(date, "week")) |>
  group_by(epiweek_start) |>
  summarise(new_cases = n()) |>
  full_join(data.frame(epiweek_start = seq(from = epiweek_min, to = epiweek_max,
                        by = "week")), by = "epiweek_start") |>
  as.data.frame() |>
  arrange(epiweek_start) |>
  mutate(epiweek_end = epiweek_start + 6)

# Add a column to sampling pool data set specifying 'incidence' at collection
# time; in this case, raw new cases
meta_sampling_pool <- meta_sampling_pool |>
  fuzzy_left_join(source_cases, by = c("date" = "epiweek_start",
                                       "date" = "epiweek_end"),
                  match_fun = list(`>=`, `<=`)) |>
  select(-epiweek_start, -epiweek_end) |>
  mutate(new_cases = ifelse(is.na(new_cases), 0, new_cases))

# Add a column specifying migration rate; following simulation parameters, the 
# rate is 0 during the first 30 days and then rises to a constant rate of 0.01
# per day
meta_sampling_pool$mobility <-
  ifelse(meta_sampling_pool$date <= min(meta_all$date) + 30,
         0, 0.01)

# Create data frame for number of sequences at the source per epiweek
source_seqs <- meta_seqs |>
  filter(collection_location == "intl_source") |>
  select(-travel_history, -infection_location, -collection_location) |>
  mutate(epiweek_start = floor_date(date, "week")) |>
  group_by(epiweek_start) |>
  summarise(sequences = n()) |>
  full_join(data.frame(epiweek_start = seq(from = epiweek_min, to = epiweek_max,
                                           by = "week")), by = "epiweek_start") |>
  as.data.frame() |>
  arrange(epiweek_start) |>
  mutate(epiweek_end = epiweek_start + 6) |>
  mutate(sequences = ifelse(is.na(sequences), 0, sequences))

# Add a column specifying sequencing intensity per day rate
meta_sampling_pool <- meta_sampling_pool |>
  fuzzy_left_join(source_seqs, by = c("date" = "epiweek_start",
                                       "date" = "epiweek_end"),
                  match_fun = list(`>=`, `<=`)) |>
  select(-epiweek_start, -epiweek_end) |>
  mutate(sequencing_intensity = sequences / new_cases) |>
  select(-sequences)

### Create data frame for domestic sequence pool
# (i.e., collection location = domestic)
meta_domestic_pool <- meta_seqs |>
  filter(collection_location == "domestic") |>
  select(-infection_location)

### Save data frames for sampling pool and domestic sequence pool
write.csv(meta_sampling_pool, "epidemic_simulation_data/sampling_pool.csv",
          row.names = FALSE)
write.csv(meta_domestic_pool, "epidemic_simulation_data/domestic_pool.csv",
          row.names = FALSE)
