#' @title Compute Persistent Homology of a Reeb Graph
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
#' @inheritParams reeb_graph_pairs
#' @param value Character; the numerical value used by the persistent pairs.
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
#' ( t10_ph <- reeb_graph_persistence(t10, value = "index") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#' ( t10_ph <- reeb_graph_persistence(t10, value = "order") )
#' phutil::get_pairs(t10_ph, dimension = 0)
#'
#' @export
reeb_graph_persistence <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    value = c("value", "index", "order")
) {

  stopifnot(inherits(x, "reeb_graph"))
  value <- match.arg(tolower(value), c("value", "index", "order"))

  # pair critical points
  cp <- reeb_graph_pairs(x, sublevel = sublevel, method = method)
  # check that types are comprehensible
  stopifnot(
    all(cp$lo_type == "LEAF_MIN" | cp$lo_type == "UPFORK"),
    all(cp$hi_type == "LEAF_MAX" | cp$hi_type == "DOWNFORK")
  )

  # degrees of persistent features
  ph_deg0 <- cp$lo_type == "LEAF_MIN"
  # extended persistent features
  ph_ext <- ( ph_deg0 & cp$hi_type == "LEAF_MAX" ) |
    ( ! ph_deg0 & cp$hi_type == "DOWNFORK" )
  # low- and high-value columns
  lo_hi <- match(paste0(c("lo", "hi"), "_", value), names(cp))

  # degree-0 features; ordinary part (increasing)
  ord_0 <- ph_deg0 & ( ! ph_ext )
  ph_ord_0 <- cbind(cp[[lo_hi[1L]]][ord_0], cp[[lo_hi[2L]]][ord_0])
  # degree-1 features; relative part (decreasing)
  rel_1 <- ( ! ph_deg0 ) & ( ! ph_ext )
  ph_rel_1 <- cbind(cp[[lo_hi[2L]]][rel_1], cp[[lo_hi[1L]]][rel_1])
  # degree-0 features; extended-positive part (increasing)
  ext_0 <- ph_deg0 & ph_ext
  ph_ext_0 <- cbind(cp[[lo_hi[1L]]][ext_0], cp[[lo_hi[2L]]][ext_0])
  # degree-1 features; extended-negative part (decreasing)
  ext_1 <- ( ! ph_deg0 ) & ph_ext
  ph_ext_1 <- cbind(cp[[lo_hi[2L]]][ext_1], cp[[lo_hi[1L]]][ext_1])

  # format as persistence data
  ph <- phutil::as_persistence(list(
    rbind(ph_ord_0, ph_ext_0),
    rbind(ph_rel_1, ph_ext_1)
  ))
  ph$metadata$engine <- "rph::reeb_graph_pairs"
  ph$metadata$filtration <- paste0(
    "extended Reeb (",
    if (sublevel) "sublevel" else "superlevel",
    ")"
  )
  # FIXME: Encode parameters so that they print with quotes.
  ph$metadata$parameters <- list(
    method = attr(cp, "method"),
    value = value
  )

  ph
}
