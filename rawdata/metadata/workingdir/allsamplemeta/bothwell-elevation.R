
verifyelev = fullmeta %>%
    filter(!is.na(latitude), !is.na(longitude), !is.na(elevation)) %>%
    mutate(computed_elev = purrr::map2_dbl(latitude, longitude, elev_one))

getelev

View(verifyelev)
ggplot(verifyelev, aes(elevation, computed_elev)) +
    geom_point(aes(colour=grepl("^CMB|EMW", sample, perl=T))) +
    geom_abline(slope=1) +
    geom_abline(slope=(1000/305)) +
    theme_bw()
ggsave("elevation.png")


x = verifyelev %>%
    mutate(elev_err = (computed_elev / elevation)) %>%
    filter(grepl("^CMB|EMW", sample, perl=T))

x

write_tsv(x, "early_bothwell.tsv")
View(x)

verify


y = fullmeta %>%
    filter(grepl("^CMB|EMW", sample, perl=T)) %>%
    mutate(computed_elev = purrr::map2_dbl(latitude, longitude, elev_one))

verifyelev %>%
    rows_upsert(y, by="sample") %>%
    ggplot(aes(computed_elev, elevation)) +
        geom_point()
