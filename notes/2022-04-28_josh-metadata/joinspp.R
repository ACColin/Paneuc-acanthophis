#' # Join Dean's taxonomy to metadata
#'
#' For Josh's work. We need to merge AC's metadata with the NE herbarium data to add some rows to the central metadata table, then select *ALL* Maidenaria for Josh to analyse.

library(readxl)
library(tidyverse)

#' bvz_orig_meta is a copy of the `rawdata/metadata/sample-metadata.tsv` *before* we do all this shit, so that we can rerun this script if we need to.
bvz_orig_meta = read_tsv("data/sample-metadata.tsv")
tax  = read_csv("https://github.com/borevitzlab/cca-eucs/raw/master/metadata/originals/DNTaxonomyCleaned.csv")

#' # Join new samples to create full metadata
#'
#' Here we join data from AC's plate layout with the collection metadata from the UNE herbarium so we can add it to our sample spreadsheet.

ne = read_csv("data/Specimens search result 28Apr2022 17_22.csv") %>%
  janitor::clean_names()

ac_plate = read_xlsx("data/Plate layouts WGS 2020-10-02_sent (1).xlsx", "Combined")%>%
  janitor::clean_names()

#' The IDs we have are like JJBXXXX, and the table has it as J.J. Bruhl, XXXX, so we need to map the names to the simple initials, so we can then paste them together to form the collector IDs

collectors = data.frame(name=c("J.J. Bruhl", "D.D. Andrew"), initial=c("JJB", "DDA"))
ne_join = left_join(ne, collectors, by=c("collector_name"="name")) %>%
  filter(!is.na(initial)) %>%
  mutate(collector_id = paste0(initial, collector_number))

#' Join AC's plate to the NE data
ac_plate_meta = ac_plate %>%
  filter(sample_name != "") %>%
  mutate(collector_site_id = sub("[a-z]+$", "", sample_name)) %>%  # remove the tree/site sub-id, as the NE data has just the site id
  left_join(ne_join, by=c("collector_site_id"="collector_id"))

#' Did we find matches for all the samples in AC's plate within the NE herbarium? (should all be TRUE)

table(!is.na(ac_plate_meta$collector_number))

#' Here we map the columns from the UNE herbarium metadata to the bvz metadata sheet.

na_str = function(x) ifelse(is.na(x), "", x)
ac_bvz = ac_plate_meta %>%
  transmute(sample=sample_name,
            species = species.x,
            date = collection_date,
            parsed_date = lubridate::dmy(date),
            latitude = latitude,
            longitude = longitude,
            elevation = altitude,
            datum = datum,
            location = locality_description,
            collectors = paste(collector_name, na_str(secondary_collectors)) %>%
                    sub("^ +", "", .) %>%
                    sub("  ", " ", .) %>%
                    sub(" +$", "", .),
            samplename = accession_number,
            notes = paste(na_str(topography), na_str(substrate), na_str(vegetation), na_str(plant_description)) %>%
                    sub("^ +", "", .) %>%
                    sub("  ", " ", .) %>%
                    sub(" +$", "", .)
  )


bvzac = bind_rows(bvz_orig_meta, ac_bvz)
str(bvzac)

# NB: this updates the metadata in git, make sure you git add it above.
write_tsv(bvzac, "../../rawdata/metadata/sample-metadata.tsv", na="")


#' ## Select Maidenaria
#' 
#' We then want to take the whole metadata including historical bvz/andrew lab stuff, and pull all Maidenaria samples out so Josh has an inclusive sample list to work with.

#'  First, join Dean's taxonomy to the new metadata

joined = left_join(bvzac, tax, by=c("species"="Binomial"))


#' Select maidenaria

mad = joined %>%
  filter(Section == "Maidenaria")

#' Form and write the sample list

all_josh_samples = mad %>%
  pull(sample) %>%
  unique()

writeLines(all_josh_samples, "all_josh_samples.txt")
