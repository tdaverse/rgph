# check that both methods return the correct pairs on the running example

f <- system.file("extdata", "running_example.txt", package = "rgph")
x <- read_reeb_graph(f)
# critical point pairs
p <- reeb_graph_pairs(x, method = "single")
expect_equal(
  unname(p$index[order(p$index[, 1], -p$index[, 2]), ]),
  cbind(
    # pairs in height (value) order
    c( 0,  1,  3,  4,  5,  7,  8, 13),
    c(15,  2, 11,  6,  9, 10, 12, 14)
  ) + 1
)
# persistent pairs
ph <- reeb_graph_persistence(x, method = "single")
expect_equal(
  lapply(ph$pairs, function(x) x[order(x[, 1]), ]),
  # persistence diagrams in birth order
  list(
    cbind(
      c( 0,  1,  4,  7),
      c(15,  2,  6, 10)
    ),
    cbind(
      c( 9, 11, 12, 14),
      c( 5,  3,  8, 13)
    )
  )
)
