# file paths and names
glomerulus_files <-
  list.files("sandbox/glomeruli", pattern = "\\.txt", full.names = TRUE)
glomerulus_files |>
  basename() |> gsub(pattern = "\\-.*$", replacement = "") |>
  make.unique(sep = "_") |>
  print() -> glomerulus_names
# environment of edgelists
glomerulus_files |>
  setNames(nm = glomerulus_names) |>
  lapply(readLines) |>
  lapply(gsub, pattern = "A", replacement = "0") |>
  lapply(gsub, pattern = "E", replacement = "Inf") |>
  lapply(strsplit, " ") |>
  lapply(lapply, as.integer) |>
  lapply(do.call, what = rbind) |>
  lapply(function(x) { x[is.na(x)] <- max(x, na.rm = TRUE) + 1L; x }) |>
  lapply(`+`, 1L) |>
  as.environment() -> glomerulus_edgelists
# '.rda' file of edgelists
save(
  list = names(glomerulus_edgelists),
  envir = glomerulus_edgelists,
  file = here::here("data/glomeruli.rda")
)
