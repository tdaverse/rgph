# check that both methods return the correct pairs on the running example

f <- system.file("extdata", "running_example.txt", package = "rgp")
x <- read_reeb_graph(f)
# critical point pairs
p <- reeb_graph_pairs(x, method = "single")
p_ <- p[order(p$lo_index, -p$hi_index), ]
expect_equal(
  unname(as.matrix(p_[, c("lo_index", "hi_index")])),
  cbind(
    # pairs in height (value) order
    c( 0,  1,  3,  4,  5,  7,  8, 13),
    c(15,  2, 11,  6,  9, 10, 12, 14)
  ) + 1
)
# persistent pairs
ph <- reeb_graph_persistence(x, method = "single")
ph_ <- do.call(rbind, ph$pairs)
ph_ <- ph_[order(ph_[, 1]), ]
expect_equal(
  ph_,
  cbind(
    # persistence diagram in birth order
    c( 0,  1,  4,  7,  9, 11, 12, 14),
    c(15,  2,  6, 10,  5,  3,  8, 13)
  )
)
