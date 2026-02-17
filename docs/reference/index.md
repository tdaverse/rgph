# Package index

## ‘rgph’ package

Compute critical point pairings and persistent homology for Reeb graphs

- [`rgph-package`](rgph.md) [`rgph`](rgph.md) : rgph: Pair Critical
  Points and Compute Persistent Homology of Reeb Graphs

## Data sets

Example Reeb graphs used to illustrate package tools

- [`david`](reeb_graph_examples.md) [`buddha`](reeb_graph_examples.md)
  [`topology`](reeb_graph_examples.md)
  [`flower`](reeb_graph_examples.md) : Mesh-Derived Reeb Graphs

## Class and coercers

An S3 class for Reeb graphs and converters with other graph classes

- [`reeb_graph()`](reeb_graph.md)
  [`print(`*`<reeb_graph>`*`)`](reeb_graph.md)
  [`format(`*`<reeb_graph>`*`)`](reeb_graph.md)
  [`read_reeb_graph()`](reeb_graph.md) : An S3 class and constructors
  for Reeb graphs

- [`as_reeb_graph()`](as_reeb_graph.md)
  [`as_igraph()`](as_reeb_graph.md) [`as_network()`](as_reeb_graph.md) :

  Coerce objects to class `reeb_graph`

## Statistical summaries

Critical point pairings and persistent homology

- [`reeb_graph_pairs()`](reeb_graph_pairs.md)
  [`as.data.frame(`*`<reeb_graph_pairs>`*`)`](reeb_graph_pairs.md)
  [`print(`*`<reeb_graph_pairs>`*`)`](reeb_graph_pairs.md)
  [`format(`*`<reeb_graph_pairs>`*`)`](reeb_graph_pairs.md) : Pair Reeb
  Graph Critical Points via Java
- [`reeb_graph_persistence()`](reeb_graph_persistence.md) : Compute
  Extended Persistent Homology of a Reeb Graph
