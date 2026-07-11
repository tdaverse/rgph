# rgph 0.2.0

This upgrade was supported by OpenCode.

## R

### bug fixes and refactors

An unconditional nullification of `name` in `as_reeb_graph.igraph()` was removed.

### new features

A `matrix` method for `reeb_graph_pairs()` takes the same input as `as_reeb_graph()`.

## R-Java interface

### bug fixes and refactors

`reeb_graph_pairs()` is revised as follows:
* uses full strings for Java class names
* collects garbage via `.jgc()` after computing pairs via `.jcall()`
* coerces index values to integer (before adding 1)

`MergePairingCLI.mainR()` and `PPPairingCLI.mainR()` are revised as follows:
* clear static result fields at the start of each call
* throw exceptions to R as errors, rather than being silenced

# rgph 0.1.0

* Initial CRAN submission.
