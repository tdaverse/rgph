# An S3 class and constructors for Reeb graphs

This is an S3 class with associated constructors for a data structure to
represent Reeb graphs in R.

## Usage

``` r
reeb_graph(values, edgelist)

# S3 method for class 'reeb_graph'
print(x, ..., n = NULL, minlength = 12L)

# S3 method for class 'reeb_graph'
format(x, ..., n = NULL, minlength = 12L)

read_reeb_graph(file)
```

## Arguments

- values:

  Numeric vector of function values at vertices; may have names, which
  may be duplicated and/or missing.

- edgelist:

  2-column integer matrix of linked vertex pairs.

- x:

  Object of class `reeb_graph`.

- ...:

  Additional arguments passed to
  [`base::format()`](https://rdrr.io/r/base/format.html).

- n:

  Integer number of edges to print.

- minlength:

  Minimum name abbreviation length; passed to
  [`base::abbreviate()`](https://rdrr.io/r/base/abbreviate.html).

- file:

  A plain text file containing Reeb graph data formatted as at
  `ReebGraphPairing`.

## Value

An object of class `"reeb_graph"`, which is a list of two elements:

- `values`: Numeric vector of function values at vertices, optionally
  named.

- `edgelist`: 2-column integer matrix of linked vertex pairs.

## Details

Vertex indices start at zero, for consistency with examples. The
positions of `values` and the integer values in `edgelist` will
correspond to the same vertices; `length(values)` must bound
`max(edgelist)`.

The S3 class is a list of `"values"` and `"edgelist"`. The
[`print()`](https://rdrr.io/r/base/print.html) method prints one edge
per line, with nodes formatted as "`index[name] (value)`"

## References

<https://github.com/USFDataVisualization/ReebGraphPairing/>

## See also

[`as_reeb_graph()`](as_reeb_graph.md)

## Examples

``` r
x <- reeb_graph(
  values = c(a = 0, b = .4, c = .6, d = 1),
  edgelist = rbind( c(1,2), c(1,3), c(2,4), c(3,4))
)
print(x)
#> Reeb graph with 4 vertices and 4 edges on [0,1]:
#> 1[a] (0.0) -- 2[b] (0.4)
#> 1[a] (0.0) -- 3[c] (0.6)
#> 2[b] (0.4) -- 4[d] (1.0)
#> 3[c] (0.6) -- 4[d] (1.0)
#> 

t10 <- system.file("extdata", "10_tree_iterations.txt", package = "rgph")
( y <- read_reeb_graph(t10) )
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

reeb_graph_pairs(x, method = "multi_pass")
#> Reeb graph critical pairing (2 pairs):
#> 1[a] (0) •- ... -• 4[d] (1)
#> 1[a] (0) -< ... >- 4[d] (1)
#> 
reeb_graph_pairs(y, method = "multi_pass")
#> Reeb graph critical pairing (12 pairs):
#>  1 (  0.000000) •- ... -• 41 (152.25645)
#>  1 (  0.000000) -< ... -• 17 ( 48.16463)
#>  3 (  3.295837) -< ... -•  5 (  8.04719)
#>  7 ( 13.621371) -< ... -• 37 (133.60396)
#> 11 ( 26.376848) -< ... -• 12 ( 29.81888)
#> 15 ( 40.620754) -< ... -• 16 ( 44.36142)
#> 19 ( 55.944340) -< ... -• 20 ( 59.91465)
#> 23 ( 72.116364) -< ... -• 25 ( 80.47189)
#> 27 ( 88.987595) -< ... -• 29 ( 97.65158)
#> 31 (106.453606) -< ... -• 33 (115.38475)
#> 35 (124.437180) -< ... -• 36 (129.00668)
#> 39 (142.878906) -< ... -• 40 (147.55518)
#> 
```
