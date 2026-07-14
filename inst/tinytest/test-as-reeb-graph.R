# coercers to Reeb graphs require a complete numeric vertex attribute

if (rlang::is_installed("igraph")) {
  g <- igraph::make_graph(c( 1,2, 2,3 ))
  igraph::vertex_attr(g, "nonnumeric") <- LETTERS[1:3]
  igraph::vertex_attr(g, "incomplete") <- c(3, NA_real_, 2)
  expect_error(as_reeb_graph(g, values = "nonnumeric"), pattern = "numeric")
  expect_error(as_reeb_graph(g, values = "incomplete"),
               pattern = "complete|finite")
}

if (rlang::is_installed("network")) {
  net <- network::network(rbind( c(1,2), c(2,3) ), matrix.type = "edgelist")
  network::set.vertex.attribute(net, "nonnumeric", LETTERS[1:3])
  network::set.vertex.attribute(net, "incomplete", c(3, NA_real_, 2))
  expect_error(as_reeb_graph(net, values = "nonnumeric"), pattern = "numeric")
  expect_error(as_reeb_graph(net, values = "incomplete"),
               pattern = "complete|finite")
}

# prohibited types trigger termination

if (rlang::is_installed("network")) {
  net <- network::network(rbind( c(1,3), c(2,3) ), matrix.type = "edgelist",
                          bipartite = 2)
  network::set.vertex.attribute(net, "valid", c(3, 1, 2))
  expect_error(as_reeb_graph(net, values = "valid"), pattern = "bipartite")

  net <- network::network(rbind( c(1,2), c(2,3) ), matrix.type = "edgelist",
                          hyper = TRUE)
  network::set.vertex.attribute(net, "valid", c(3, 1, 2))
  expect_error(as_reeb_graph(net, values = "valid"), pattern = "hyper")
}

# coercers to Reeb graphs work


if (rlang::is_installed("igraph")) {
  g <- igraph::make_graph(c( 1,3, 2,3, 2,4, 3,5, 4,5, 5,6 ))
  igraph::vertex_attr(g, "test") <- seq(igraph::vcount(g)) + .5
  expect_silent(rg <- as_reeb_graph(g, values = "test"))
  expect_equal(rg$values, igraph::vertex_attr(g, "test"))
  expect_equal(rg$edgelist, igraph::as_edgelist(g))
}

if (rlang::is_installed("network")) {
  net <-
    network::network(rbind( c(1,3), c(2,3), c(3,4), c(2,4), c(4,5)) )
  network::set.vertex.attribute(
    net, "test",
    seq(network::network.size(net)) + .5
  )
  expect_silent(rg <- as_reeb_graph(net, values = "test"))
  expect_equal(rg$values, network::get.vertex.attribute(net, "test"))
  expect_equal(
    rg$edgelist, as.matrix(net, matrix.type = "edgelist"),
    check.attributes = FALSE
  )
}

# coercers from Reeb graphs work

ht <- c(3, 1, 2)
names(ht) <- letters[1:3]
rg <- reeb_graph(values = ht, edgelist = c( 1,2, 2,3 ))

if (rlang::is_installed("igraph")) {
  g <- as_igraph(rg, values = "height")
  expect_true(all( igraph::as_edgelist(g, names = FALSE) == rg$edgelist ))
  expect_false(is.null(igraph::vertex_attr(g, "height")))
  expect_identical(igraph::vertex_attr(g, "height"), unname(ht))
  expect_identical(igraph::vertex_attr(g, "name"), names(ht))
}

# `as_igraph()` does not set a "name" attribute when values are unnamed

if (rlang::is_installed("igraph")) {
  rg_named <- reeb_graph(values = ht, edgelist = c( 1,2, 2,3 ))
  g_named <- as_igraph(rg_named, values = "height")
  expect_equal(igraph::vertex_attr(g_named, "name"), names(ht))

  rg_unnamed <- reeb_graph(values = unname(ht), edgelist = c( 1,2, 2,3 ))
  g_unnamed <- as_igraph(rg_unnamed, values = "height")
  expect_null(igraph::vertex_attr(g_unnamed, "name"))
}

if (rlang::is_installed("network")) {
  net <- as_network(rg, values = "height")
  expect_true(all( as.matrix(net, matrix.type = "edgelist") == rg$edgelist ))
  expect_false(is.null(network::get.vertex.attribute(net, "height")))
  expect_identical(network::get.vertex.attribute(net, "height"), unname(ht))
  expect_identical(network::get.vertex.attribute(net, "vertex.names"), names(ht))
}
