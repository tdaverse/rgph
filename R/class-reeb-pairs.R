#' @title An S3 class for Reeb graph persistent pairs
#'
#' @description This S3 class is a light wrapper around a data frame containing
#'   the values, indices, and orders of persistent pairs.
#'
#' @details The data frame has 6 columns, 2 each (birth and death) for 6
#'   properties: value (height), index, and order.
#'
#' @examples
#' x <- reeb_graph(
#'   values = c(0, .4, .6, 1),
#'   edgelist = c( 1,2, 1,3, 2,4, 3,4 )
#' )
#' ( mp <- reeb_graph_pairs(x) )
#' class(mp)
#' as.data.frame(mp)
#' @export
as.data.frame.reeb_graph_pairs <- function(x, ...) {
  check_reeb_graph_pairs(x)
  class(x) <- "data.frame"
  x
}

check_reeb_graph_pairs <- function(x) {
  stopifnot(
    inherits(x, "data.frame"),
    setequal(
      names(x),
      outer(
        c("lo", "hi"),
        c("type", "value", "index", "order"),
        FUN = paste, sep = "_"
      )
    ),
    is.numeric(x$lo_value), is.numeric(x$hi_value),
    is.integer(x$lo_index), is.integer(x$hi_index),
    is.numeric(x$lo_order), is.numeric(x$hi_order)
  )
}
