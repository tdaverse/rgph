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
#'   This function may be deprecated once a `"reeb_graph_pairs"` method is
#'   written for [phutil::as_persistence()].
#'
#' @param x A [`reeb_graph`][reeb_graph] or
#'   [`reeb_graph_pairs`][reeb_graph_pairs] object, or an object that can be
#'   [coerced to class "reeb_graph"][as_reeb_graph].
#' @inheritParams as_reeb_graph
#' @inheritParams reeb_graph_pairs
#' @param scale Character; the scale parameter used by the persistent pairs.
#'   Matched to `"value"` (the default), `"index"`, or `"order"`.
#' @return A [phutil::persistence] object.
#' @examples
#' ex_sf <- system.file("extdata", "running_example.txt", package = "rgp")
#' ( ex_rg <- read_reeb_graph(ex_sf) )
#' ( ex_ph <- reeb_graph_persistence(ex_rg) )
#' phutil::get_pairs(ex_ph, dimension = 0)
#' phutil::get_pairs(ex_ph, dimension = 1)
#'
#' t10_f <- system.file("extdata", "10_tree_iterations.txt", package = "rgp")
#' ( t10 <- read_reeb_graph(t10_f) )
#' ( t10_ph <- reeb_graph_persistence(t10) )
#' phutil::get_pairs(t10_ph, dimension = 0)
#' ( t10_ph <- reeb_graph_persistence(t10, scale = "index") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#' ( t10_ph <- reeb_graph_persistence(t10, scale = "order") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#'
#' @export
reeb_graph_persistence <- function(x, ...) UseMethod("reeb_graph_persistence")

#' @rdname reeb_graph_persistence
#' @export
reeb_graph_persistence.default <- function(x, ...) {
  stop(paste0(
    "No `reeb_graph_persistence()` method for class(es) '",
    paste(class(x), collapse = "', '"),
    "'."
  ))
}

reeb_graph_persistence_graph <- function(
    x,
    values = NULL,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    scale = c("value", "index", "order")
) {
  x <- as_reeb_graph(x, values = values)

  reeb_graph_persistence.reeb_graph(
    x,
    sublevel = sublevel, method = method, scale = scale
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
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    scale = c("value", "index", "order")
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
    scale = c("value", "index", "order")
) {
  scale <- match.arg(tolower(scale), c("value", "index", "order"))

  # degrees of persistent features
  ph_deg0 <- x$lo_type == "LEAF_MIN"
  # extended persistent features
  ph_ext <- ( ph_deg0 & x$hi_type == "LEAF_MAX" ) |
    ( ! ph_deg0 & x$hi_type == "DOWNFORK" )
  # low- and high-value columns
  lo_hi <- match(paste0(c("lo", "hi"), "_", scale), names(x))

  # degree-0 features; ordinary part (increasing)
  ord_0 <- ph_deg0 & ( ! ph_ext )
  ph_ord_0 <- cbind(x[[lo_hi[1L]]][ord_0], x[[lo_hi[2L]]][ord_0])
  # degree-1 features; relative part (decreasing)
  rel_1 <- ( ! ph_deg0 ) & ( ! ph_ext )
  ph_rel_1 <- cbind(x[[lo_hi[2L]]][rel_1], x[[lo_hi[1L]]][rel_1])
  # degree-0 features; extended-positive part (increasing)
  ext_0 <- ph_deg0 & ph_ext
  ph_ext_0 <- cbind(x[[lo_hi[1L]]][ext_0], x[[lo_hi[2L]]][ext_0])
  # degree-1 features; extended-negative part (decreasing)
  ext_1 <- ( ! ph_deg0 ) & ph_ext
  ph_ext_1 <- cbind(x[[lo_hi[2L]]][ext_1], x[[lo_hi[1L]]][ext_1])

  # format as persistence data
  ph <- phutil::as_persistence(list(
    rbind(ph_ord_0, ph_ext_0),
    rbind(ph_rel_1, ph_ext_1)
  ))
  ph$metadata$engine <- "rgp::reeb_graph_persistence"
  ph$metadata$filtration <- paste0(
    "extended Reeb (",
    if (attr(x, "sublevel")) "sublevel" else "superlevel",
    ")"
  )
  # FIXME: Encode parameters so that they print with quotes.
  ph$metadata$parameters <- list(
    method = attr(x, "method"),
    scale = scale
  )

  ph
}
