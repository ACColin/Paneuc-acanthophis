library(tidyverse)
library(lubridate)

lr2s = read_tsv("../../runlib2sample.tsv")

allsamples =  lr2s %>%
    select(sample) %>%
    unique()

oldmeta = read_csv("sample-metadata.csv", col_types=cols(Date=col_character())) %>%
    rename(sample=SampleID) %>%
    rename_with(tolower) %>%
    mutate(notes="", collectors="", seed=as.character(NA)) %>%
    filter(sample!="Eucalyptus_melliodora")  # this is a spurious sample, actually named EmelCSIRO

allsamp_oldmeta = allsamples %>%
    left_join(oldmeta, by="sample")

complete = allsamp_oldmeta %>%
    filter(!is.na(species), !is.na(latitude), !is.na(longitude))

absent = allsamp_oldmeta %>%
    filter(is.na(species), is.na(latitude), is.na(longitude))

incomplete = allsamp_oldmeta %>%
    filter(!sample %in% complete$sample, !sample %in% absent$sample) %>%
    arrange(sample)


# Gundagai hybrids
gundh = read_tsv("../gundh/meta.tsv", col_types=cols(date=col_character())) %>%
    filter(!is.na(sample)) %>%
    mutate(sample=sub("GUND_H_0", "Gund", sample),     
           location="Leonard's Road, Coolac (private property)",
           datum="WGS84") %>%
    select(-photo, latitude=lat, longitude=long) %>%
    filter(sample %in% lr2s$sample)
gundh

# RA lines
ra = tribble(
~sample, ~species, ~location,  ~latitude, ~longitude, ~collectors, ~datum,
"RA1006", "Eucalyptus albens", "The Pinnacle, Bundarra Rd.", -30.4821, 151.4628, "Rose Andrew", "WGS84",
"RA1007", "Eucalyptus albens", "The Pinnacle, Bundarra Rd.", -30.4824, 151.4631, "Rose Andrew", "WGS84",
"NE10467", "Eucalyptus porosa", "8 km S of Kangaroo Flat Stn, W of Lake Gairdner.", -31.3333, 135.65, NA, "WGS84",
"NE25923", "Eucalyptus woollsiana", "19 km E of Mitchell.", -26.5333, 148.1333,  NA, "WGS84",
"NE25953", "Eucalyptus porosa", "40 km E of Streaky Bay.", -32.75, 134.6,  NA, "WGS84",
"NE35955", "Eucalyptus porosa", "Coonalpyn.", -35.7, 139.85, NA, "WGS84",
"NE35959", "Eucalyptus porosa", "16 km W of Murray Bridge.", -35.1167,  139.0667,  NA, "WGS84",
"NE36811", "Eucalyptus odorata", "Hall Creek Rd, c. 3 km W of Wilson Hill.", -35.5333, 138.5667,  NA, "WGS84",
"NE37169", "Eucalyptus odorata", "Lower Alligator Creek, branch of Mambray Creek.", -32.7833, 138.0667, NA, "WGS84",
"NE37647", "Eucalyptus woollsiana", "10 km S of Narrabri.", -30.4, 149.1833,  NA, "WGS84",
"NE4583", "Eucalyptus woollsiana", "14 km W of Gilgandra.", -31.6667, 148.5, NA, "WGS84",
"NE67754",  "Eucalyptus odorata", "Sandland Road.", -34.6667, 138.8, NA, "WGS84",
"NE90535", "Eucalyptus woollsiana", "State Forest 341 Bringalily, north eastern portion, 22 km NNE of Inglewood.",  -28.2333, 151.1667, NA, "WGS84",
)

# Helen's samples

hbmeta = read_tsv("../helen/HMB_WGS_metadata_all420.txt") %>%
    mutate(notes=paste(Comments, Trip_comments, sep="; "),
           notes=ifelse(notes == "NA; NA", "", notes),
           notes=sub("^NA; ", "", notes),
           notes=sub("; NA$", "", notes)) %>%
    rename_with(tolower) %>%
    select(sample=sampleid, species, latitude, longitude, elevation=altitude_m, datum, date, seed, collectors, notes)

hbonly = hbmeta %>%
    filter(grepl("^(NSW|GOL|EMW|CMB)", sample, perl=T))



# LBcollector

lbcoll = allsamp_oldmeta %>%
    filter(grepl('^LBM', sample)) %>%
    transmute(sample, collectors="Linda Broadhurst")

# gh samples spp metadata
ghsamp = tribble(
    ~sample, ~species,                               ~notes, ~samplename, ~datum,
    "GH1",         NA, "Unknown sample from UNE Greenhouse",          NA,     NA,
    "GH2",         NA, "Unknown sample from UNE Greenhouse",          NA,     NA
)


# CCA reps
ccameta = read_csv("CCATreesCombinedMetadata.csv",
                   col_types=cols(FieldComments=col_character(), Date=col_character()))

cca = allsamp_oldmeta %>%
    filter(grepl("^CCA", sample)) %>%
    filter(is.na(species)) %>%
    transmute(sample, cca_sample=sub("[-_]rep[12]", "", sample)) %>%
    left_join(ccameta, by=c("cca_sample"="FieldID")) %>%
    transmute(sample, species=CurrentName, notes=Description, date=Date, location=Location,
              latitude=Latitude, longitude=Longitude, datum="WGS84")

#HB reps

hbrep = allsamp_oldmeta %>%
    filter(grepl("NSW.*_[12]", sample), is.na(species)) %>%
    transmute(sample, sample_norep=sub("_[12]$", "", sample)) %>%
    left_join(hbonly, by=c("sample_norep"="sample")) %>%
    select(-sample_norep)



#J418f
# Just loot the metadata from another j418 sample
j418f = allsamp_oldmeta  %>%
    filter(sample=="J418b") %>%
    mutate(sample="J418f", samplename="J418f")

# EmelCSIRO

emelcsiro = tribble(
    ~sample,                    ~species, ~location, ~latitude, ~longitude, ~datum, ~collectors, ~notes,
    "EmelCSIRO", "Eucalyptus melliodora", "CSIRO/ANU Gate near Burton & Garran Hall, ANU Acton Campus", 
                 -35.2753382,149.1153358, "WGS84", "Ash Jones & Kevin Murray", "Old remnant Emel at gate between CSIRO main building and carpark between Bruce/B&G halls across daley road from Gould building"
)
                    

# CCA collector

ccacollector = allsamp_oldmeta %>%
    filter(grepl("^CCA", sample)) %>%
    transmute(sample, collectors = "Dean Nicolle")


# Early HB collection elevation fix
# Helen seemed to divide elevations through by 3.2 (feet per meter) erroneously.

hbelev = allsamp_oldmeta %>%
    filter(grepl("^CMB|EMW", sample, perl=T)) %>%
    select(sample, elevation) %>%
    mutate(elevation=elevation * (1000/305))  # 305mm per foot

hbelev




# merge
fullmeta = allsamp_oldmeta %>% 
    rows_upsert(hbonly, by="sample") %>%
    rows_update(hbelev, by="sample") %>%
    rows_update(hbrep, by="sample") %>%
    rows_update(gundh, by="sample") %>%
    rows_update(ra, by="sample") %>%
    rows_update(lbcoll, by="sample") %>%
    rows_update(ghsamp, by="sample") %>%
    rows_update(j418f, by="sample") %>%
    rows_update(cca, by="sample") %>%
    rows_update(ccacollector, by="sample") %>%
    rows_update(emelcsiro, by="sample") %>%
    filter(!grepl("^NCT", sample)) %>%
    filter(!grepl("^Acacia", sample)) %>%
    filter(!grepl("^Oryza", sample)) %>%
    mutate(datum=ifelse(is.na(latitude) | is.na(longitude), NA, datum)) %>%
    mutate(samplename = ifelse(sample == samplename, NA, samplename)) %>%
    mutate(across(where(is.character),
           function(chr) ifelse(chr == "" | chr == "NA" | chr == " ", NA, chr))) %>%
    mutate(parsed_date = ifelse(is.na(date), NA,
                         ifelse(grepl("[AP]M$", date), dmy_hms(date, tz="Australia/Canberra"),
                         ifelse(grepl("Z$", date), ymd_hms(date),
                                ymd_hms(paste0(date, "12:00:00 PM"), tz="Australia/Canberra"))))) %>%
    mutate(parsed_date = with_tz(as_datetime(parsed_date), "Australia/Canberra")) %>%
    select(sample, species, date, parsed_date, latitude, longitude, elevation, datum, location, collectors,
           samplename, population, seed, notes)


# Look up missing elevations

elev_one = function(lat, long) {
    if (is.na(lat) || is.na(long))  return (NA)
    url = sprintf("http://api.geonames.org/astergdem?lat=%f&lng=%f&username=kdm9", lat, long)
    resp = httr::GET(url)
    if (httr::http_error(resp)) {
        return (NA)
    } else {
        return (as.double(httr::content(resp, as="text")))
    }
}


computedelev = fullmeta %>%
    filter(!is.na(latitude), !is.na(longitude), is.na(elevation)) %>%
    mutate(elevation = purrr::map2_dbl(latitude, longitude, elev_one),
           notes=ifelse(is.na(notes), "elevation computed from api.geonames.org/astergdem", paste0(notes, "; elevation computed from api.geonames.org/astergdem"))) %>%
    select(sample, elevation, notes)


View(computedelev)

fullmeta %>%
    rows_update(computedelev, by="sample")

str(fullmeta)
write_tsv(fullmeta, "../../sample-metadata.tsv", na="")
