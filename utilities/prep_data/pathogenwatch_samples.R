library(tidyverse)

# read all files
# these were manually downloaded from Pathogenwatch Sep 2023
all <- list.files("pathogenwatch_collection", full.names = TRUE) |> 
  lapply(\(x) read_csv(x) |> janitor::clean_names())
names(all) <- list.files("pathogenwatch_collection") |> 
  str_remove(".csv") |> str_remove("vibrio_")

# check column names
lapply(all, \(x) colnames(x)) |> 
  unlist() |> 
  table() |> 
  as.data.frame() |> 
  arrange(Freq)

# bind all together
all <- bind_rows(all, .id = "clade")

write_csv(all, "pathogenwatch_collection/combined.csv")

# get 5 of each clade (where possible)
all |> 
  drop_na(assembly_accession_ncbi, year, serogroup_phenotype) |> 
  arrange(desc(year)) |> 
  group_by(clade) |> 
  slice(1:5) |> 
  ungroup() |> 
  select(clade, id, displayname, year, 
         serogroup_phenotype, assembly_accession_ncbi, serogroup_phenotype) |> 
  write_csv("pathogenwatch_collection/selected_genomes.csv")
