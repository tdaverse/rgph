# check that degenerate Reeb graphs are handled correctly as in Tu &al (2019)

for (alg in c("single_pass", "multi_pass")) {

  # regular (non-critical) node
  r <- reeb_graph(c(0,.5,1), c( 1,2, 2,3 ))
  p <- reeb_graph_pairs(r, method = alg)
  expect_equal(p$lo_type, "LEAF_MIN")
  expect_equal(p$hi_type, "LEAF_MAX")
  expect_equal(p$lo_value, 0.)
  expect_equal(p$hi_value, 1.)
  expect_equal(p$lo_index, 1L)
  expect_equal(p$hi_index, 3L)

  # degenerate minimum
  r <- reeb_graph(c(.5,1,1), c( 1,2, 1,3 ))
  p <- reeb_graph_pairs(r, method = alg)
  expect_equal(p$lo_type, c("LEAF_MIN", "UPFORK"))
  expect_equal(p$hi_type, c("LEAF_MAX", "LEAF_MAX"))
  expect_equal(p$lo_value, c(.5, .5))
  expect_equal(p$hi_value, c(1, 1))
  expect_equal(p$lo_index, c(1L, 1L))
  expect_equal(sort(p$hi_index), c(2L, 3L))

  # degenerate maximum
  r <- reeb_graph(c(0,0,.5), c( 1,3, 2,3 ))
  p <- reeb_graph_pairs(r, method = alg)
  expect_equal(p$lo_type, c("LEAF_MIN", "LEAF_MIN"))
  expect_equal(p$hi_type, c("LEAF_MAX", "DOWNFORK"))
  expect_equal(p$lo_value, c(0., 0.))
  expect_equal(p$hi_value, c(.5, .5))
  expect_equal(sort(p$lo_index), c(1L, 2L))
  expect_equal(p$hi_index, c(3L, 3L))

  # double-forks
  r <- reeb_graph(c(0,0,.5,1,1), c( 1,3, 2,3, 3,4, 3,5 ))
  p <- reeb_graph_pairs(r, method = alg)
  p_ <- p[order(p$lo_index, -p$hi_index), ]
  expect_equal(p_$lo_type, c("LEAF_MIN", "LEAF_MIN", "UPFORK"))
  expect_equal(p_$hi_type, c("LEAF_MAX", "DOWNFORK", "LEAF_MAX"))
  expect_equal(p_$lo_value, c(0., 0., .5))
  expect_equal(p_$hi_value, c(1., .5, 1.))
  expect_equal(p_$lo_index, c(1L, 2L, 3L))
  expect_equal(p_$hi_index, c(5L, 3L, 4L))

  # complex forks
  r <- reeb_graph(c(0,0,0,.5,1), c( 1,4, 2,4, 3,4, 4,5 ))
  p <- reeb_graph_pairs(r, method = alg)
  p_ <- p[order(p$lo_index, -p$hi_index), ]
  expect_equal(p_$lo_type, c("LEAF_MIN", "LEAF_MIN", "LEAF_MIN"))
  expect_equal(p_$hi_type, c("LEAF_MAX", "DOWNFORK", "DOWNFORK"))
  expect_equal(p_$lo_value, c(0., 0., 0.))
  expect_equal(p_$hi_value, c(1., .5, .5))
  expect_equal(p_$lo_index, c(1L, 2L, 3L))
  expect_equal(p_$hi_index, c(5L, 4L, 4L))

  # more complex forks
  r <- reeb_graph(c(0,0,0,.5,1,1), c( 1,4, 2,4, 3,4, 4,5, 4,6 ))
  p <- reeb_graph_pairs(r, method = alg)
  p_ <- p[order(p$lo_index, -p$hi_index), ]
  expect_equal(p_$lo_type, c("LEAF_MIN", "LEAF_MIN", "LEAF_MIN", "UPFORK"))
  expect_equal(p_$hi_type, c("LEAF_MAX", "DOWNFORK", "DOWNFORK", "LEAF_MAX"))
  expect_equal(p_$lo_value, c(0., 0., 0., .5))
  expect_equal(p_$hi_value, c(1., .5, .5, 1.))
  expect_equal(p_$lo_index, c(1L, 2L, 3L, 4L))
  expect_equal(p_$hi_index, c(6L, 4L, 4L, 5L))

  # disconnected graph
  r <- reeb_graph(c(0,1,0,.3,.7,1), c( 1,2, 3,5, 4,5, 5,6 ))
  p <- reeb_graph_pairs(r, method = alg)
  p_ <- p[order(p$lo_index, -p$hi_index), ]
  expect_equal(p_$lo_type, c("LEAF_MIN", "LEAF_MIN", "LEAF_MIN"))
  expect_equal(p_$hi_type, c("LEAF_MAX", "LEAF_MAX", "DOWNFORK"))
  expect_equal(p_$lo_value, c(0., 0., .3), tolerance = 1e-07)
  expect_equal(p_$hi_value, c(1., 1., .7), tolerance = 1e-07)
  expect_equal(p_$lo_index, c(1L, 3L, 4L))
  expect_equal(p_$hi_index, c(2L, 6L, 5L))
  # computed separately
  r1 <- reeb_graph(c(0,1), c( 1,2 ))
  r2 <- reeb_graph(c(0,.3,.7,1), c( 1,3, 2,3, 3,4 ))
  p1 <- reeb_graph_pairs(r1, method = alg)
  p2 <- reeb_graph_pairs(r2, method = alg)
  p2[, c("lo_index", "hi_index")] <-
    p2[, c("lo_index", "hi_index")] + 2L
  p12 <- rbind(p1, p2)
  p12_ <- p12[order(p12$lo_index, -p12$hi_index), ]
  expect_equal(p_, p12_, check.attributes = FALSE)

  # adjacent nodes at equal height
  r <- reeb_graph(c(0,.5,.5,1), c( 1,2, 1,3, 2,3, 2,4, 3,4 ))
  p <- reeb_graph_pairs(r, method = alg)
  p_ <- p[order(p$lo_index, -p$hi_index), ]
  expect_equal(p_$lo_type, c("LEAF_MIN", "UPFORK", "UPFORK"))
  expect_equal(p_$hi_type, c("LEAF_MAX", "DOWNFORK", "DOWNFORK"))
  expect_equal(p_$lo_value, c(0., 0., .5))
  expect_equal(p_$hi_value, c(1., .5, 1.))
  expect_equal(p_$lo_index, c(1L, 1L, 2L))
  expect_equal(p_$hi_index, c(4L, 3L, 4L))

}

# test additional degenerate examples

r <- reeb_graph(c(0,1,2,3), c( 1,2, 1,3, 2,3, 3,4 ))
p <- reeb_graph_pairs(r)
expect_equal(p$lo_value, c(0, 0))
expect_equal(sort(p$hi_value), c(2, 3))

r <- reeb_graph(c(0,1,2,3), c( 1,2, 1,3, 1,4, 2,3 ))
p <- reeb_graph_pairs(r)
expect_equal(p$lo_value, c(0, 0, 0))
expect_equal(sort(p$hi_value), c(2, 2, 3))

r <- reeb_graph(c(0,1,2,3), c( 1,2, 1,3, 1,4, 2,3, 3,4 ))
p <- reeb_graph_pairs(r)
expect_equal(p$lo_value, c(0, 0, 0))
expect_equal(sort(p$hi_value), c(2, 3, 3))
