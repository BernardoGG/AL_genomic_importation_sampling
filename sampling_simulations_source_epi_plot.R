library(tidyverse)
library(lubridate)

x <- read.csv("epidemic_simulation_data/source_epi_trends.csv") |>
  select(sequencing_intensity) |> max()
y <- read.csv("epidemic_simulation_data/source_epi_trends.csv") |>
  select(new_cases) |> max()

read.csv("epidemic_simulation_data/source_epi_trends.csv") |>
  mutate(epiweek_start = ymd(epiweek_start)) |>
  ggplot() +
  geom_line(aes(x = epiweek_start, y = new_cases)) +
  geom_line(aes(x = epiweek_start, y = sequencing_intensity * 20000),
            color = "darkred") +
  scale_y_continuous(sec.axis = sec_axis(~ . * x / y,
                     name = "Proportion of cases that were sequenced")) +
  labs(x = "", y = "Weekly new cases",
       title = "Epidemiological trends at source location") +
  theme_minimal() +
  theme(axis.text.y.right = element_text(color = "darkred"),
        axis.title.y.right = element_text(color = "darkred"))

ggsave("epidemic_simulation_data/plots/source_epi_trends.png", height = 5,
       width = 7, dpi = 300, units = "in", bg = "white")

rm(x, y)
