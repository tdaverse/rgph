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

# coercers from Reeb graphs work

rg <- reeb_graph(values = c(3, 1, 2), edgelist = c( 1,2, 2,3 ))

if (rlang::is_installed("igraph")) {
  g <- as_igraph(rg, values = "height")
  expect_true(all( igraph::as_edgelist(g) == rg$edgelist ))
  expect_false(is.null(igraph::vertex_attr(g, "height")))
  expect_true(all( igraph::vertex_attr(g, "height") == c(3, 1, 2) ))
}

if (rlang::is_installed("network")) {
  net <- as_network(rg, values = "height")
  expect_true(all( as.matrix(net, matrix.type = "edgelist") == rg$edgelist ))
  expect_false(is.null(network::get.vertex.attribute(net, "height")))
  expect_true(all( network::get.vertex.attribute(net, "height") == c(3, 1, 2) ))
}
