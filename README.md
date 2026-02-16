
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgph

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Reeb graphs arise as low-dimensional quotients of higher-dimensional
topological spaces, with topological structure that is informative but
quicker and easier to compute. **rgph** provides an S3 class and
constructors for Reeb graphs, bindings to the
[`ReebGraphPairing`](https://github.com/USFDataVisualization/ReebGraphPairing)
Java library for pairing their critical points, post-processing
conversion to extended persistent homology, and methods to accommodate
`igraph` and `network` objects and streamline the process.

## Installation

You can install the development version of **rgph** from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("tdaverse/rgph")
```

## Example

``` r
library(rgph)
#> Loading required package: rJava
#> Loading required package: phutil
```

The running example from [Tu &al
(2019)](http://doi.org/10.1007/978-3-030-33720-9_8) can be read in from
an installed data file:

``` r
ex_file <- system.file("extdata/running_example.txt", package = "rgph")
( ex_reeb <- read_reeb_graph(ex_file) )
#> Reeb graph with 16 vertices and 18 edges on [0,15]:
#>  1 ( 0) --  3 ( 2)
#>  2 ( 1) --  3 ( 2)
#>  3 ( 2) --  4 ( 3)
#>  4 ( 3) --  6 ( 5)
#>  4 ( 3) --  7 ( 6)
#>  5 ( 4) --  7 ( 6)
#>  6 ( 5) -- 10 ( 9)
#>  6 ( 5) -- 10 ( 9)
#>  7 ( 6) -- 12 (11)
#>  8 ( 7) --  9 ( 8)
#>  9 ( 8) -- 12 (11)
#>  9 ( 8) -- 11 (10)
#> ...
```

While no `plot` method is provided yet, a layered layout from **igraph**
is helpful:

``` r
ex_igraph <- as_igraph(ex_reeb, values = "height")
ex_layout <- igraph::layout_with_sugiyama(
  ex_igraph,
  layers = igraph::vertex_attr(ex_igraph, "height")
)
plot(ex_igraph, layout = ex_layout)
```

<img src="man/figures/README-plot example-1.png" alt="" width="60%" />

Two methods, a generally slower multi-pass algorithm and a more
intricate single-pass algorithm, are provided to pair critical points:

``` r
( ex_pairs <- reeb_graph_pairs(ex_reeb, method = "single") )
#> Reeb graph critical pairing (8 pairs):
#>  1 ( 0) •- ... -• 16 (15)
#>  2 ( 1) •- ... >-  3 ( 2)
#>  5 ( 4) •- ... >-  7 ( 6)
#>  8 ( 7) •- ... >- 11 (10)
#>  6 ( 5) -< ... >- 10 ( 9)
#>  4 ( 3) -< ... >- 12 (11)
#>  9 ( 8) -< ... >- 13 (12)
#> 14 (13) -< ... -• 15 (14)
```

(Each end of a pairing is either a local extremum or a fork, as
indicated by a bullet or an inequality, respectively.)

This output can be converted to extended persistence diagrams using the
**phutil** `persistence` class and plotted using the **TDA** method:

``` r
( ex_ph <- reeb_graph_persistence(ex_pairs, scale = "index") )
#> 
#> ── Persistence Data ────────────────────────────────────────────────────────────
#> ℹ There are 4 and 4 pairs in dimensions 0 and 1 respectively.
#> ℹ Computed from a Extended Reeb (Sublevel) filtration using `rgph::reeb_graph_persistence()`.
#> ℹ With the following parameters: method = 'single_pass' and scale = 'index'.
TDA::plot.diagram(as.data.frame(ex_ph), asp = 1)
```

<img src="man/figures/README-persist example-1.png" alt="" width="60%" />
