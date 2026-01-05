# check that both methods return the correct pairs on the running example

f <- system.file("extdata", "running_example.txt", package = "rgp")
x <- read_reeb_graph(f)
p <- reeb_graph_pairs(x, method = "single")
p_ <- p[order(p$birth_index, -p$death_index), ]
expect_equal(
  unname(as.matrix(p_[, 1:2])),
  cbind(
    # pairs in height (value) order
    c( 0,  1,  3,  4,  5,  7,  8, 13),
    c(15,  2, 11,  6,  9, 10, 12, 14)
    # # persistence diagram
    # c( 0, 11, 13,  9, 12,  7,  4,  1),
    # c(15,  3, 14,  5,  8, 10,  6,  2)
  )
)
