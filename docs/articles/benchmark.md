# Runtime Comparison of Critical Point Pairing Algorithms

This vignette compares the runtimes and memory allocations of the
multi-pass and single-pass algorithms for pairing critical points.
Several tidyverse packages are used to post-process the benchmark
results:

``` r
library(rgph)
library(dplyr)
library(tidyr)
#> Warning: package 'tidyr' was built under R version 4.5.2
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 4.5.2
```

## The running example

To illustrate, compare the results of the two algorithms on the running
example from Tu &al (2018):

``` r
ex_file <- system.file("extdata", "running_example.txt", package = "rgph")
ex_reeb <- read_reeb_graph(ex_file)
( ex_multi <- reeb_graph_pairs(ex_reeb, method = "multi_pass") )
#> Reeb graph critical pairing (8 pairs):
#>  1 ( 0) •- ... -• 16 (15)
#>  2 ( 1) •- ... >-  3 ( 2)
#>  5 ( 4) •- ... >-  7 ( 6)
#>  8 ( 7) •- ... >- 11 (10)
#>  6 ( 5) -< ... >- 10 ( 9)
#>  4 ( 3) -< ... >- 12 (11)
#>  9 ( 8) -< ... >- 13 (12)
#> 14 (13) -< ... -• 15 (14)
( ex_single <- reeb_graph_pairs(ex_reeb, method = "single_pass") )
#> Reeb graph critical pairing (8 pairs):
#>  1 ( 0) •- ... -• 16 (15)
#>  2 ( 1) •- ... >-  3 ( 2)
#>  5 ( 4) •- ... >-  7 ( 6)
#>  8 ( 7) •- ... >- 11 (10)
#>  6 ( 5) -< ... >- 10 ( 9)
#>  4 ( 3) -< ... >- 12 (11)
#>  9 ( 8) -< ... >- 13 (12)
#> 14 (13) -< ... -• 15 (14)
all.equal(ex_multi, ex_single)
#> [1] "Attributes: < Component \"elapsed_time\": Mean relative difference: 0.6666217 >"
#> [2] "Attributes: < Component \"method\": 1 string mismatch >"
```

We expect the resulting data frames to be equivalent, but the output
contains the attributes `method` and `elapsed_time` that we expect to be
different. If we ignore attributes, then we find the results to agree:

``` r
all.equal(ex_multi, ex_single, check.attributes = FALSE)
#> [1] TRUE
```

For this reason, we omit the default check in the benchmarking run:

``` r
bench::mark(
  multi = reeb_graph_pairs(ex_reeb, method = "multi_pass"),
  single = reeb_graph_pairs(ex_reeb, method = "single_pass"),
  check = FALSE
)
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 multi         278µs    295µs     3173.    1.24KB     12.6
#> 2 single        255µs    276µs     3515.    1.24KB     14.7
```

The R bindings are equivalent; while total runtimes will be higher than
when comparing the Java programs directly, the differences between them
should be the same. Indeed, the allocated memory is exactly the same.
However, the single-pass algorithm—Propagate and Pair—is a marginal
improvement over the multiple-pass merge pairing algorithm.

## A more complex case

The exported object `flower` is a `reeb_graph` constructed from the
flower mesh, one of 12 from the `AIM@SHAPE` collection used by Tu &al to
benchmark algorithms. Among them, it contains the most critical points,
so it will better illustrate the difference between the algorithms in
computationally intensive settings.

``` r
# print only a few edges for illustration
print(flower, n = 4)
#> Reeb graph with 325 vertices and 388 edges on [0,10]:
#>  65 (0.000000) -- 283 (1.237770)
#> 283 (1.237770) --  73 (2.475540)
#>  73 (2.475540) -- 240 (3.026665)
#> 240 (3.026665) --  64 (3.577791)
#> ...
```

However, this Reeb graph contains isolated vertices, which contribute no
positive-persistent features to the output but must be dropped before
calculation, lest they seize up the algorithms:

``` r
# print only a few pairs for illustration
print(reeb_graph_pairs(flower, method = "multi_pass"), n = 4)
#> Note: 87 isolated vertices were dropped.
#> Reeb graph critical pairing (200 pairs):
#>  65 (0.000000) •- ... -• 66 (10.000000)
#>  73 (2.475540) -< ... >- 64 ( 3.577791)
#> 188 (3.776078) -< ... >- 48 ( 3.824975)
#> 144 (3.812326) -< ... >- 94 ( 3.872892)
```

So that the benchmark results are more reflective of the algorithms’
requirements, we manually drop these points first:

``` r
flower <- rgph:::drop_reeb_graph_points(flower)
#> Note: 87 isolated vertices were dropped.
bench::mark(
  multi = reeb_graph_pairs(flower, method = "multi_pass"),
  single = reeb_graph_pairs(flower, method = "single_pass"),
  check = FALSE
)
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 multi        4.75ms   4.97ms     196.     52.8KB     2.02
#> 2 single       12.9ms  13.47ms      67.9    52.8KB     0
```

For this Reeb graph, Propagate and Pair outperforms the multi-pass
algorithm by roughly a factor of 3.

## How performance and improvement scale

Finally, we compare how both algorithms scale. Vertex and edge data are
provided for three random merge tree Reeb graphs on an exponential size
scale. These are converted to split trees by negating the vertex values
and benchmarked separately before being stacked. (Note that the
single-pass algorithm was found superior to the multi-pass algorithm on
split trees but inferior on merge trees.)

``` r
# collect split tree Reeb graphs
tree_files <- vapply(
  c(
    `10` = "10_tree_iterations.txt",
    `100` = "100_tree_iterations.txt",
    `1000` = "1000_tree_iterations.txt"
  ),
  function(f) system.file("extdata", f, package = "rgph"),
  ""
)
tree_reebs <- lapply(tree_files, read_reeb_graph)
tree_reebs <- lapply(tree_reebs, function(rg) { rg$values <- -rg$values; rg })
# aggregate benchmark comparisons
tree_bench <- tibble()
for (i in seq_along(tree_reebs)) {
  bm <- bench::mark(
    multi = reeb_graph_pairs(tree_reebs[[i]], method = "multi_pass"),
    single = reeb_graph_pairs(tree_reebs[[i]], method = "single_pass"),
    check = FALSE
  )
  bm <- transmute(
    bm,
    method = as.character(expression),
    n_itr, time, memory
  )
  bm <- relocate(mutate(bm, size = as.integer(names(tree_files)[[i]])), size)
  tree_bench <- bind_rows(tree_bench, bm)
}
```

By plotting all of the run times from each of the benchmarks, we can
visualize both the differences in runtimes between the algorithms and
the variability in those runtimes.

``` r
# plot runtime results
tree_bench %>%
  select(size, method, time) %>%
  unnest(time) %>%
  ggplot(aes(x = as.factor(size), y = time * 1e3)) +
  geom_boxplot(aes(color = method, shape = method)) +
  scale_y_continuous(
    transform = "log1p",
    labels = scales::label_number(suffix = "ms")
  ) +
  labs(x = "tree size", y = "run time")
```

![](benchmark_files/figure-html/random%20(split)%20trees%20plot-1.png)

The single-pass advantage appears to grow with size. The ratio of
medians quantifies this:

``` r
tree_bench %>%
  transmute(size, method, median = vapply(time, median, 0.)) %>%
  pivot_wider(id_cols = size, names_from = method, values_from = median) %>%
  transmute(size, ratio = single / multi)
#> # A tibble: 3 × 2
#>    size ratio
#>   <int> <dbl>
#> 1    10 0.937
#> 2   100 0.748
#> 3  1000 0.615
```
