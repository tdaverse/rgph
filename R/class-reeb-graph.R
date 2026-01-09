#' @title An S3 class and constructors for Reeb graphs
#'
#' @description This is an S3 class with associated constructors for a data
#'   structure to represent Reeb graphs in R.
#'
#' @details Vertex indices start at zero, for consistency with examples. The
#'   positions of `values` and the integer values in `edgelist` will correspond
#'   to the same vertices; `length(values)` must bound `max(edgelist)`.
#'
#' @param values Numeric vector of function values at vertices.
#' @param edgelist 2-column integer matrix of linked vertex pairs.
#' @param x Object of class `"reeb_graph"`.
#' @param ... Additional arguments passed to [base::format()].
#' @param n Integer number of edges to print.
#' @param file A plain text file containing Reeb graph data formatted as at
#'   `ReebGraphPairing`.
#' @returns An object of class `"reeb_graph"`, which is a list of two elements:
#'
#' - `values`: Numeric vector of function values at vertices.
#' - `edgelist`: 2-column integer matrix of linked vertex pairs.
#' @examples
#' x <- reeb_graph(
#'   values = c(0, .4, .6, 1),
#'   edgelist = rbind( c(1,2), c(1,3), c(2,4), c(3,4))
#' )
#' print(x)
#'
#' t10 <- system.file("extdata", "10_tree_iterations.txt", package = "rgp")
#' ( y <- read_reeb_graph(t10) )
#'
#' reeb_graph_pairs(x, method = "multi_pass")
#' reeb_graph_pairs(y, method = "multi_pass")
#'
#' @template ref-reebgraphpairing
#' @export
reeb_graph <- function(values, edgelist) {
  check_reeb_data(values, edgelist)
  if (is.vector(edgelist)) edgelist <- t(matrix(edgelist, nrow = 2L))

  storage.mode(values) <- "double"
  storage.mode(edgelist) <- "integer"

  res <- list(values = values, edgelist = edgelist)
  class(res) <- c("reeb_graph", class(res))
  res
}

check_reeb_data <- function(values, edgelist) {
  stopifnot(
    is.numeric(values),
    is.vector(values),
    all(is.finite(values)),
    all(! is.na(values)),
    is.numeric(edgelist),
    ( is.vector(edgelist) && length(edgelist) %% 2L == 0L ) ||
      ( is.matrix(edgelist) && ncol(edgelist) == 2L ),
    all(! is.na(edgelist)),
    min(edgelist) >= 1L,
    max(edgelist) <= length(values),
    all(as.vector(edgelist) - as.integer(edgelist) == 0)
  )
}

#' @rdname reeb_graph
#' @export
print.reeb_graph <- function(x, ..., n = NULL) {
  cat(format(x, ..., n = n), sep = "\n")
}

#' @rdname reeb_graph
#' @export
format.reeb_graph <- function(x, ..., n = NULL) {
  vcount <- length(x$values)
  frange <- range(x$values)
  ecount <- nrow(x$edgelist)

  if (is.null(n)) n <- min(nrow(x$edgelist), 6L)
  fpairs <- matrix(
    paste0(
      as.vector(x$edgelist[seq(n), ]),
      " [", x$values[as.vector(x$edgelist[seq(n), ])], "]"
    ),
    nrow = n, ncol = 2L
  )
  fout <- apply(fpairs, 1L, function(r) paste(r, collapse = " -- "))

  cat(paste(
    paste0(
      "Reeb graph with ", vcount, " vertices and ", ecount, " edges ",
      "taking values in [", frange[1L], ",", frange[2L], "]:"
    ),
    paste(fout, collapse = "\n"),
    if (n <  nrow(x$edgelist)) "...",
    sep = "\n"
  ))
}

#' @rdname reeb_graph
#' @export
read_reeb_graph <- function(file) {
  lines <- readLines(file)

  values <- lines[grepl("^v ", lines)]
  indices <- as.integer(gsub("^v ([0-9]+) [0-9\\.]+$", "\\1", values))
  order_indices <- order(indices)
  values <- as.numeric(gsub("^v [0-9]+ ([0-9\\.]+)$", "\\1", values))
  values <- values[order_indices]

  edgelist <- lines[grepl("^e ", lines)]
  fromlist <- as.integer(gsub("^e ([0-9]+) [0-9]+$", "\\1", edgelist))
  tolist <- as.integer(gsub("^e [0-9]+ ([0-9]+)$", "\\1", edgelist))
  edgelist <- unname(cbind(fromlist, tolist))
  # index from 1 in R
  edgelist <- edgelist + 1L

  reeb_graph(values = values, edgelist = edgelist)
}
