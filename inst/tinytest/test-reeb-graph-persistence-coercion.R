# check that persistence handles objects of other classes
# (note that the example Reeb graph includes a multiedge)

f <- system.file("extdata", "running_example.txt", package = "rgph")
x <- read_reeb_graph(f)
x_ph <- reeb_graph_persistence(x)

# igraph
if (rlang::is_installed("igraph")) {
  g <- as_igraph(x, values = "height")
  g_ph <- reeb_graph_persistence(g, values = "height")
  expect_equivalent(x_ph, g_ph)
}

# network
if (rlang::is_installed("network")) {
  net <- as_network(x, values = "height")
  net_ph <- reeb_graph_persistence(net, values = "height")
  expect_equivalent(x_ph, net_ph)
}
