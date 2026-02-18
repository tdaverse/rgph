#' @title An S3 class and constructors for Reeb graphs
#'
#' @description This is an S3 class with associated constructors for a data
#'   structure to represent Reeb graphs in R.
#'
#' @details Vertex indices start at zero, for consistency with examples. The
#'   positions of `values` and the integer values in `edgelist` will correspond
#'   to the same vertices; `length(values)` must bound `max(edgelist)`.
#'
#'   The S3 class is a list of `"values"` and `"edgelist"`. The [print()] method
#'   prints one edge per line, with nodes formatted as "`index[name] (value)`"
#'
#' @param values Numeric vector of function values at vertices; may have names,
#'   which may be duplicated and/or missing.
#' @param edgelist 2-column integer matrix of linked vertex pairs.
#' @param x Object of class `reeb_graph`.
#' @param ... Additional arguments passed to [base::format()].
#' @param n Integer number of edges to print.
#' @param minlength Minimum name abbreviation length; passed to
#'   [base::abbreviate()].
#' @param file A plain text file containing Reeb graph data formatted as at
#'   `ReebGraphPairing`.
#' @returns An object of class `"reeb_graph"`, which is a list of two elements:
#'
#' - `values`: Numeric vector of function values at vertices, optionally named.
#' - `edgelist`: 2-column integer matrix of linked vertex pairs.
#' @seealso [as_reeb_graph()]
#' @examples
#' x <- reeb_graph(
#'   values = c(a = 0, b = .4, c = .6, d = 1),
#'   edgelist = rbind( c(1,2), c(1,3), c(2,4), c(3,4))
#' )
#' print(x)
#'
#' t10 <- system.file("extdata", "10_tree_iterations.txt", package = "rgph")
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
print.reeb_graph <- function(x, ..., n = NULL, minlength = 12L) {
  cat(format(x, ..., n = n, minlength = minlength), sep = "\n")
}

#' @rdname reeb_graph
#' @export
format.reeb_graph <- function(x, ..., n = NULL, minlength = 12L) {
  vcount <- length(x[["values"]])
  frange <- range(x[["values"]])
  ecount <- nrow(x[["edgelist"]])
  vnames <- ! is.null(names(x[["values"]]))

  if (is.null(n)) n <- min(ecount, 12L)
  if (vnames) minlength <- min(
    minlength,
    min(nchar(names(x[["values"]])), na.rm = TRUE)
  )

  edge_ind <- format(as.vector(x[["edgelist"]][seq(n), ]))
  edge_val <- format(x[["values"]][as.vector(x[["edgelist"]][seq(n), ])])
  if (vnames) {
    edge_nam <- names(x[["values"]][as.vector(x[["edgelist"]][seq(n), ])])
    edge_nam <- abbreviate(
      edge_nam, minlength = minlength,
      strict = TRUE, named = FALSE
    )
    edge_nam[is.na(edge_nam)] <- ""
    edge_nam <- format(edge_nam, width = max(nchar(edge_nam)), justify = "left")
  }

  edge_fmt <- matrix(
    paste0(
      edge_ind,
      if (vnames) paste0("[", edge_nam, "]"),
      " (", edge_val, ")"
    ),
    nrow = n, ncol = 2L
  )
  edge_fmt <- apply(edge_fmt, 1L, function(r) paste(r, collapse = " -- "))

  cat(paste(
    paste0(
      "Reeb graph with ", vcount, " vertices and ", ecount, " edges ",
      "on [", format(frange[1L]), ",", format(frange[2L]), "]:"
    ),
    paste(edge_fmt, collapse = "\n"),
    if (n <  nrow(x[["edgelist"]])) "...",
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
  indices <- indices[order_indices]

  edgelist <- lines[grepl("^e ", lines)]
  fromlist <- as.integer(gsub("^e ([0-9]+) [0-9]+$", "\\1", edgelist))
  tolist <- as.integer(gsub("^e [0-9]+ ([0-9]+)$", "\\1", edgelist))
  edgelist <- unname(cbind(fromlist, tolist))
  edgelist[] <- match(edgelist, indices)

  reeb_graph(values = values, edgelist = edgelist)
}
