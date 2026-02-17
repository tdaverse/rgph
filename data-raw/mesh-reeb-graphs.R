
# create data directory
dir.create("data")

# all Reeb graph text files
f <- list.files("data-raw", pattern = "reebgraph_vals.txt", full.names = TRUE)
rg <- lapply(f, rgph::read_reeb_graph)
nm <- vapply(f, \(s) sub("^data-raw/([^_]*)_.*.txt$", "\\1", s), "")
for (i in seq_along(rg)) {
  assign(nm[[i]], rg[[i]])
  rd <- paste0("data/", nm[[i]], ".rda")
  save(list = nm[[i]], file = rd)
  print(rd)
}
