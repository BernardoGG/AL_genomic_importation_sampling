library(hierfstat)
library(ape)
library(ade4)
library(tidyverse)
library(reshape2)
library(lubridate)
library(data.table)
library(fuzzyjoin)

## Read subsampled sequences and metadata of all simulated cases ####
#meta <- "simulation_seq_intensity_0.1/simulated_epidemic_seqint_0.1_metadata.csv"
fasta <- "simulation_seq_intensity_0.1/simulated_epidemic_seqint_0.1_sequences.fasta"
meta_full <- "cleaned_metadata_2.txt"

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

# Create data frame for sequence pool to be sampled from
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






## Estimate pairwise genetic distance, record time spent running operation ####
# Raw genetic distances
start.time <- Sys.time()
gdist_seqs <- dist.dna(gendist_seqs)
end.time <- Sys.time()
time.taken <- round(end.time - start.time, 2)
time.taken

# Reformat into data frame format
gdist_seqs_dm <- melt(as.matrix(gdist_seqs), varnames = c("seq_1", "seq_2")) |>
  rename("dist" = "value")

# Create data frame with numbers of cases per location over time
epi_trends_df <- meta_all |> group_by(infection_location, date) |> count()

# Create data frame with numbers of importations over time
importations_df <- meta_all |> filter(travel_history == "travel") |>
  group_by(date) |> count()

ggplot() +
  geom_line(data = epi_trends_df,
            aes(x = date, y = n, group = infection_location, color = infection_location))

## Write genetic distance RData objects and read again (if required)
save(gendist_seqs, file = "genetic_distance_matrix.RData")
save(gdist_seqs_dm, file = "genetic_distance_matrix_longform.RData")

gdist_seqs_dm <- readRDS("genetic_distance_matrix_longform.RData")



min(gdist_seqs_dm$dist)
unique(gdist_seqs_dm$seq_1)



## TODO
## Minimum non-UK seq for each UK seq with travel history
## 


## Sandbox ####
hist(pidist_seqs_dm$dist[pidist_seqs_dm$seq_1 == pidist_seqs_dm$seq_1[1]])
hist(pidist_seqs_dm$dist[pidist_seqs_dm$seq_1 == pidist_seqs_dm$seq_1[2]])
hist(pidist_seqs_dm$dist[pidist_seqs_dm$seq_1 == pidist_seqs_dm$seq_1[1000]])

pidist_seqs_1 <- dist.dna(gendist_seqs[301:400])
temp <- as.data.frame(as.matrix(pidist_seqs_1))
table.paint(temp, cleg = 0, clabel.row = 0.5, clabel.col = 0.5)

ggplot(meta_seqs) +
  geom_histogram(aes(x = date, fill = travel_history), bins = 42) +
  theme_minimal()
