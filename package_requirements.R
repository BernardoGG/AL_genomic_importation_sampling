# Load/install required packages.
required_packages <- c("hierfstat", "ape", "ade4", "tidyverse", "reshape2",
                       "lubridate", "data.table", "jsonlite", "glue", "purrr")
suppressMessages(
  for (package in required_packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package, repos = "http://cran.us.r-project.org")
    }
    library(package, character.only = TRUE)
  }
)
