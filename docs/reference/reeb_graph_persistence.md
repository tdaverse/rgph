# Compute Extended Persistent Homology of a Reeb Graph

This function obtains extended persistent homology of a Reeb graph by
way of pairing critical points.

## Usage

``` r
reeb_graph_persistence(x, scale = c("value", "index", "order"), ...)

# Default S3 method
reeb_graph_persistence(x, scale = c("value", "index", "order"), ...)

# S3 method for class 'igraph'
reeb_graph_persistence(
  x,
  scale = c("value", "index", "order"),
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  values = NULL,
  ...
)

# S3 method for class 'network'
reeb_graph_persistence(
  x,
  scale = c("value", "index", "order"),
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  values = NULL,
  ...
)

# S3 method for class 'reeb_graph'
reeb_graph_persistence(
  x,
  scale = c("value", "index", "order"),
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  ...
)

# S3 method for class 'reeb_graph_pairs'
reeb_graph_persistence(x, scale = c("value", "index", "order"), ...)
```

## Arguments

- x:

  A [`reeb_graph`](reeb_graph.md) or
  [`reeb_graph_pairs`](reeb_graph_pairs.md) object, or an object that
  can be [coerced to class "reeb_graph"](as_reeb_graph.md).

- scale:

  Character; the scale parameter used by the persistent pairs. Matched
  to `"value"` (the default), `"index"`, or `"order"`.

- ...:

  Additional arguments passed to methods.

- sublevel:

  Logical; whether to use the sublevel set filtration (`TRUE`, the
  default) or else the superlevel set filtration (via reversing
  `x[["values"]]` before paring critical points.

- method:

  Character; the pairing method to use. Matched to `"single_pass"` (the
  default) or `"multi_pass"`.

- values:

  For coercion *to* class `reeb_graph`, a character value; the node
  attribute to use as the Reeb graph value function. If `NULL` (the
  default), the first numeric node attribute is used. For coercion
  *from* class `reeb_graph`, a character value; the name of the node
  attribute in which to store the Reeb graph value function.

## Value

A
[phutil::persistence](https://tdaverse.github.io/phutil/reference/persistence.html)
object.

## Details

The types, values, and indices of critical pairs are obtained by
[`reeb_graph_pairs()`](reeb_graph_pairs.md). `reeb_graph_persistence()`
calls this function internally with the prescribed `method`, then
restructures the values or indices as
[phutil::persistence](https://tdaverse.github.io/phutil/reference/persistence.html)
data.

This function may be deprecated once a `reeb_graph_pairs` method is
written for
[`phutil::as_persistence()`](https://tdaverse.github.io/phutil/reference/persistence.html).

## See also

[`reeb_graph_pairs()`](reeb_graph_pairs.md)

## Examples

``` r
ex_sf <- system.file("extdata", "running_example.txt", package = "rgph")
( ex_rg <- read_reeb_graph(ex_sf) )
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
( ex_ph <- reeb_graph_persistence(ex_rg) )
#> 
#> ── Persistence Data ────────────────────────────────────────────────────────────
#> ℹ There are 4 and 4 pairs in dimensions 0 and 1 respectively.
#> ℹ Computed from a Extended Reeb (Sublevel) filtration using `rgph::reeb_graph_persistence()`.
#> ℹ With the following parameters: method = 'single_pass' and scale = 'value'.
phutil::get_pairs(ex_ph, dimension = 0)
#>      [,1] [,2]
#> [1,]    1    2
#> [2,]    4    6
#> [3,]    7   10
#> [4,]    0   15
phutil::get_pairs(ex_ph, dimension = 1)
#>      [,1] [,2]
#> [1,]   14   13
#> [2,]    9    5
#> [3,]   11    3
#> [4,]   12    8

t10_f <- system.file("extdata", "10_tree_iterations.txt", package = "rgph")
( t10 <- read_reeb_graph(t10_f) )
#> Reeb graph with 41 vertices and 40 edges on [0,152.2565]:
#>  1 ( 0.000000) --  2 ( 1.386294)
#>  1 ( 0.000000) -- 14 (36.946803)
#>  2 ( 1.386294) --  3 ( 3.295837)
#>  3 ( 3.295837) --  4 ( 5.545177)
#>  3 ( 3.295837) --  5 ( 8.047190)
#>  4 ( 5.545177) --  6 (10.750557)
#>  6 (10.750557) --  7 (13.621371)
#>  7 (13.621371) --  9 (19.775021)
#>  7 (13.621371) --  8 (16.635532)
#>  8 (16.635532) -- 18 (52.026692)
#>  9 (19.775021) -- 10 (23.025851)
#> 10 (23.025851) -- 11 (26.376848)
#> ...
( t10_ph <- reeb_graph_persistence(t10) )
#> 
#> ── Persistence Data ────────────────────────────────────────────────────────────
#> ℹ There are 1 and 11 pairs in dimensions 0 and 1 respectively.
#> ℹ Computed from a Extended Reeb (Sublevel) filtration using `rgph::reeb_graph_persistence()`.
#> ℹ With the following parameters: method = 'single_pass' and scale = 'value'.
phutil::get_pairs(t10_ph, dimension = 0)
#>      [,1]     [,2]
#> [1,]    0 152.2565
( t10_ph <- reeb_graph_persistence(t10, scale = "index") )
#> 
#> ── Persistence Data ────────────────────────────────────────────────────────────
#> ℹ There are 1 and 11 pairs in dimensions 0 and 1 respectively.
#> ℹ Computed from a Extended Reeb (Sublevel) filtration using `rgph::reeb_graph_persistence()`.
#> ℹ With the following parameters: method = 'single_pass' and scale = 'index'.
phutil::get_pairs(t10_ph, dimension = 0)
#>      [,1] [,2]
#> [1,]    1   41
( t10_ph <- reeb_graph_persistence(t10, scale = "order") )
#> 
#> ── Persistence Data ────────────────────────────────────────────────────────────
#> ℹ There are 1 and 11 pairs in dimensions 0 and 1 respectively.
#> ℹ Computed from a Extended Reeb (Sublevel) filtration using `rgph::reeb_graph_persistence()`.
#> ℹ With the following parameters: method = 'single_pass' and scale = 'order'.
phutil::get_pairs(t10_ph, dimension = 0)
#>      [,1] [,2]
#> [1,]    1   24
```
