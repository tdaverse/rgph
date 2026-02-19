#' @title Compute Extended Persistent Homology of a Reeb Graph
#'
#' @description This function obtains extended persistent homology of a Reeb
#'   graph by way of pairing critical points.
#'
#' @details The types, values, and indices of critical pairs are obtained by
#'   [reeb_graph_pairs()]. `reeb_graph_persistence()` calls this function
#'   internally with the prescribed `method`, then restructures the values or
#'   indices as [phutil::persistence] data.
#'
#'   This function may be deprecated once a `reeb_graph_pairs` method is
#'   written for [phutil::as_persistence()].
#'
#' @importFrom phutil as_persistence
#' @param x A [`reeb_graph`][reeb_graph] or
#'   [`reeb_graph_pairs`][reeb_graph_pairs] object, or an object that can be
#'   [coerced to class "reeb_graph"][as_reeb_graph].
#' @inheritParams as_reeb_graph
#' @inheritParams reeb_graph_pairs
#' @param scale Character; the scale parameter used by the persistent pairs.
#'   Matched to `"value"` (the default), `"index"`, or `"order"`.
#' @returns A [phutil::persistence] object.
#' @seealso [reeb_graph_pairs()]
#' @examples
#' ex_sf <- system.file("extdata", "running_example.txt", package = "rgph")
#' ( ex_rg <- read_reeb_graph(ex_sf) )
#' ( ex_ph <- reeb_graph_persistence(ex_rg) )
#' phutil::get_pairs(ex_ph, dimension = 0)
#' phutil::get_pairs(ex_ph, dimension = 1)
#'
#' t10_f <- system.file("extdata", "10_tree_iterations.txt", package = "rgph")
#' ( t10 <- read_reeb_graph(t10_f) )
#' ( t10_ph <- reeb_graph_persistence(t10) )
#' phutil::get_pairs(t10_ph, dimension = 0)
#' ( t10_ph <- reeb_graph_persistence(t10, scale = "index") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#' ( t10_ph <- reeb_graph_persistence(t10, scale = "order") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#'
#' @export
reeb_graph_persistence <- function(
    x,
    scale = c("value", "index", "order"),
    ...
) UseMethod("reeb_graph_persistence")

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.default <- function(
    x,
    scale = c("value", "index", "order"),
    ...
) {
  stop(paste0(
    "No `reeb_graph_persistence()` method for class(es) '",
    paste(class(x), collapse = "', '"),
    "'."
  ))
}

reeb_graph_persistence_graph <- function(
    x,
    scale = c("value", "index", "order"),
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    values = NULL,
    ...
) {
  x <- as_reeb_graph(x, values = values)

  reeb_graph_persistence.reeb_graph(
    x,
    scale = scale, sublevel = sublevel, method = method
  )
}

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.igraph <- reeb_graph_persistence_graph

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.network <- reeb_graph_persistence_graph

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.reeb_graph <- function(
    x,
    scale = c("value", "index", "order"),
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    ...
) {
  # pair critical points
  cp <- reeb_graph_pairs(x, sublevel = sublevel, method = method)

  # convert critical pairs to persistent homology
  reeb_graph_persistence.reeb_graph_pairs(cp, scale = scale)
}

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.reeb_graph_pairs <- function(
    x,
    scale = c("value", "index", "order"),
    ...
) {
  scale <- match.arg(tolower(scale), c("value", "index", "order"))

  # degrees of persistent features
  ph_deg0 <- x$type[, 1L] == "LEAF_MIN"
  # extended persistent features
  ph_ext <- ( ph_deg0 & x$type[, 2L] == "LEAF_MAX" ) |
    ( ! ph_deg0 & x$type[, 2L] == "DOWNFORK" )

  # degree-0 features; ordinary part (increasing)
  ord_0 <- ph_deg0 & ( ! ph_ext )
  ph_ord_0 <- unname(cbind(x[[scale]][ord_0, 1L], x[[scale]][ord_0, 2L]))
  # degree-1 features; relative part (decreasing)
  rel_1 <- ( ! ph_deg0 ) & ( ! ph_ext )
  ph_rel_1 <- unname(cbind(x[[scale]][rel_1, 2L], x[[scale]][rel_1, 1L]))
  # degree-0 features; extended-positive part (increasing)
  ext_0 <- ph_deg0 & ph_ext
  ph_ext_0 <- unname(cbind(x[[scale]][ext_0, 1L], x[[scale]][ext_0, 2L]))
  # degree-1 features; extended-negative part (decreasing)
  ext_1 <- ( ! ph_deg0 ) & ph_ext
  ph_ext_1 <- unname(cbind(x[[scale]][ext_1, 2L], x[[scale]][ext_1, 1L]))

  # format as persistence data
  ph <- as_persistence(
    list(
      rbind(ph_ord_0, ph_ext_0),
      rbind(ph_rel_1, ph_ext_1)
    ),
    warn = FALSE
  )
  ph$metadata$engine <- "rgph::reeb_graph_persistence"
  ph$metadata$filtration <- paste0(
    "extended Reeb (",
    if (attr(x, "sublevel")) "sublevel" else "superlevel",
    ")"
  )
  ph$metadata$parameters <- list(
    method = paste0("'", attr(x, "method"), "'"),
    scale = paste0("'", scale, "'")
  )

  ph
}
