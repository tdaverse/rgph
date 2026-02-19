# Pair Reeb Graph Critical Points via Java

This function calls one of two methods, merge-pair and
propagate-and-pair, to pair the critical points of a Reeb graph.

## Usage

``` r
reeb_graph_pairs(
  x,
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  ...
)

# Default S3 method
reeb_graph_pairs(
  x,
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  ...
)

# S3 method for class 'igraph'
reeb_graph_pairs(
  x,
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  values = NULL,
  ...
)

# S3 method for class 'network'
reeb_graph_pairs(
  x,
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  values = NULL,
  ...
)

# S3 method for class 'reeb_graph'
reeb_graph_pairs(
  x,
  sublevel = TRUE,
  method = c("single_pass", "multi_pass"),
  ...
)

# S3 method for class 'reeb_graph_pairs'
as.data.frame(x, ...)

# S3 method for class 'reeb_graph_pairs'
print(x, ..., n = NULL, minlength = 12L)

# S3 method for class 'reeb_graph_pairs'
format(x, ..., n = NULL, minlength = 12L)
```

## Arguments

- x:

  A [`reeb_graph`](reeb_graph.md) object.

- sublevel:

  Logical; whether to use the sublevel set filtration (`TRUE`, the
  default) or else the superlevel set filtration (via reversing
  `x[["values"]]` before paring critical points.

- method:

  Character; the pairing method to use. Matched to `"single_pass"` (the
  default) or `"multi_pass"`.

- ...:

  Additional arguments passed to methods.

- values:

  For coercion *to* class `reeb_graph`, a character value; the node
  attribute to use as the Reeb graph value function. If `NULL` (the
  default), the first numeric node attribute is used. For coercion
  *from* class `reeb_graph`, a character value; the name of the node
  attribute in which to store the Reeb graph value function.

- n:

  Integer number of critical pairs to print.

- minlength:

  Minimum name abbreviation length; passed to
  [`base::abbreviate()`](https://rdrr.io/r/base/abbreviate.html).

## Value

A list of subclass reeb_graph_pairs containing 4 2-column matrices
characterizing the low- and high-valued critical points of each pair:

- `type`:

  Character; the type of critical point, one of `LEAF_MIN`, `LEAF_MAX`,
  `UPFORK`, and `DOWNFORK`.

- `value`:

  Double; the value (stored in `x[["values"]]`) of the critical point.

- `index`:

  Integer; the index (used in `x[["edgelist"]]`) of the critical point.
  Regular points will not appear, while degenerate critical points will
  appear multiple times.

- `order`:

  Integer; the order of the critical point in the pairing. This is based
  on the conditioned Reeb graph constructed internally so will not be
  duplicated.

The data frame also has attributes `"names"` for the node names,
`"method"` for the method used, and `"elapsed_time"` for the elapsed
time.

## Details

The function uses the `rJava` package to call either of two Java methods
from `ReebGraphPairing`. Ensure the Java Virtual Machine (JVM) is
initialized and the required class is available in the class path.

The Propagate-and-Pair algorithm (`"single_pass"`) performs both join
and split merge tree operations along a single sweep through the Reeb
graph. It was shown to be more efficient on most test data, and to scale
better with graph size, than an algorithm (`"multi_pass"`) that pairs
some types along the sublevel filtration and others along the superlevel
filtration (Tu &al, 2019).

The output S3 class is a list of 2-column matrices containing the types,
values, indices, and orders of persistent pairs, with attributes
containing the node names and metadata. The
[`print()`](https://rdrr.io/r/base/print.html) method visually expresses
each pair, increasing from left to right, with nodes formatted as with
[reeb_graph](reeb_graph.md).

The names of the coerced data frame use `lo_` and `hi_` prefixes, in
contrast to the Java source code that uses `birth_` and `death_`. This
is meant to distinguish the pairs and their metadata from [persistent
homology](reeb_graph_persistence.md), which is here reformulated
following Carrière & Oudot (2018).

## References

<https://github.com/USFDataVisualization/ReebGraphPairing/>

Tu J, Hajij M, Rosen P. Propagate and Pair: A Single-Pass Approach to
Critical Point Pairing in Reeb Graphs. In: Bebis G, Boyle R, Parvin B,
&al, eds. *Advances in Visual Computing. Lecture Notes in Computer
Science*. Springer International Publishing; 2019:99–113.
[doi:10.1007/978-3-030-33720-9_8](https://doi.org/10.1007/978-3-030-33720-9_8)

Carrière M & Oudot S (2018) "Structure and Stability of the
One-Dimensional Mapper". *Foundations of Computational Mathematics*
18(6): 1333–1396.
[doi:10.1007/s10208-017-9370-z](https://doi.org/10.1007/s10208-017-9370-z)

## See also

[`reeb_graph_persistence()`](reeb_graph_persistence.md)

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
( ex_cp <- reeb_graph_pairs(ex_rg) )
#> Reeb graph critical pairing (8 pairs):
#>  1 ( 0) •- ... -• 16 (15)
#>  2 ( 1) •- ... >-  3 ( 2)
#>  5 ( 4) •- ... >-  7 ( 6)
#>  8 ( 7) •- ... >- 11 (10)
#>  6 ( 5) -< ... >- 10 ( 9)
#>  4 ( 3) -< ... >- 12 (11)
#>  9 ( 8) -< ... >- 13 (12)
#> 14 (13) -< ... -• 15 (14)
#> 
attr(ex_cp, "method")
#> [1] "single_pass"
attr(ex_cp, "elapsed_time")
#> [1] 0.1093791

reeb_graph_pairs(ex_rg, sublevel = FALSE)
#> Reeb graph critical pairing (8 pairs):
#> 16 (15) •- ... -•  1 ( 0)
#> 15 (14) •- ... >- 14 (13)
#> 11 (10) -< ... -•  8 ( 7)
#> 13 (12) -< ... >-  9 ( 8)
#>  7 ( 6) -< ... -•  5 ( 4)
#> 10 ( 9) -< ... >-  6 ( 5)
#> 12 (11) -< ... >-  4 ( 3)
#>  3 ( 2) -< ... -•  2 ( 1)
#> 

x <- reeb_graph(
  values = c(0, .4, .6, 1),
  edgelist = c( 1,2, 1,3, 2,4, 3,4 )
)
( mp <- reeb_graph_pairs(x) )
#> Reeb graph critical pairing (2 pairs):
#> 1 (0) •- ... -• 4 (1)
#> 1 (0) -< ... >- 4 (1)
#> 
class(mp)
#> [1] "reeb_graph_pairs" "list"            
as.data.frame(mp)
#>    lo_type  hi_type lo_value hi_value lo_index hi_index lo_order hi_order
#> 1 LEAF_MIN LEAF_MAX        0        1        1        4        1        4
#> 2   UPFORK DOWNFORK        0        1        1        4        2        3

names(x$values) <- letters[seq_along(x$values)]
( mp <- reeb_graph_pairs(x) )
#> Reeb graph critical pairing (2 pairs):
#> 1[a] (0) •- ... -• 4[d] (1)
#> 1[a] (0) -< ... >- 4[d] (1)
#> 
as.data.frame(mp)
#>    lo_type  hi_type lo_value hi_value lo_index hi_index lo_order hi_order
#> 1 LEAF_MIN LEAF_MAX        0        1        1        4        1        4
#> 2   UPFORK DOWNFORK        0        1        1        4        2        3
#>   lo_name hi_name
#> 1       a       d
#> 2       a       d

library(network)
data("emon")
mtsi <- emon$Cheyenne
mtsi_reeb <- as_reeb_graph(
  mtsi,
  values = "Command.Rank.Score",
  names = "vertex.names"
)
mtsi_cp <- reeb_graph_pairs(mtsi_reeb, sublevel = FALSE)
print(mtsi_cp, minlength = 20)
#> Reeb graph critical pairing (72 pairs):
#>  8[L.C...C.C] (40) •- ... -• 14[S.W.HAM.R] ( 0)
#>  8[L.C...C.C] (40) -< ... >-  7[Lr.C.S..O] (20)
#>  8[L.C...C.C] (40) -< ... >-  7[Lr.C.S..O] (20)
#> 10[Chynn.P.D] (30) -< ... >-  7[Lr.C.S..O] (20)
#>  8[L.C...C.C] (40) -< ... >-  2[W.S.N.G..] (10)
#>  8[L.C...C.C] (40) -< ... >-  2[W.S.N.G..] (10)
#> 10[Chynn.P.D] (30) -< ... >-  2[W.S.N.G..] (10)
#>  7[Lr.C.S..O] (20) -< ... >-  9[Chynn.F.D] (10)
#>  8[L.C...C.C] (40) -< ... >-  9[Chynn.F.D] (10)
#> 10[Chynn.P.D] (30) -< ... >-  9[Chynn.F.D] (10)
#> 10[Chynn.P.D] (30) -< ... >-  9[Chynn.F.D] (10)
#>  8[L.C...C.C] (40) -< ... >-  9[Chynn.F.D] (10)
#> 
```
