#' @title Coerce objects to class `reeb_graph`
#'
#' @description Coerce objects to `[reeb_graph]`-class objects.
#'
#' @details The `as_reeb_graph()` methods require a network (mathematical graph)
#'   structure and a real-valued function on the vertex set.
#'
#'   For coercion between external network classes, use the `intergraph`
#'   package.
#'
#' @param x An R object to be coerced. See Details.
#' @param names For coercion _to_ class `reeb_graph`, a character value; the
#'   node attribute to use as the Reeb graph node names. If `NULL`, names are
#'   omitted. For coercion _from_ class `reeb_graph`, a character value; the
#'   name of the node attribute in which to store the Reeb graph node names.
#' @param values For coercion _to_ class `reeb_graph`, a character value; the
#'   node attribute to use as the Reeb graph value function. If `NULL` (the
#'   default), the first numeric node attribute is used. For coercion _from_
#'   class `reeb_graph`, a character value; the name of the node attribute in
#'   which to store the Reeb graph value function.
#' @param ... Additional arguments passed to methods.
#' @returns A [reeb_graph] object.
#' @seealso [reeb_graph()]

#' @examplesIf rlang::is_installed("igraph")
#' library(igraph)
#' ( g <- make_kautz_graph(2, 1) )
#' l_g <- layout_with_fr(g)
#' plot(g, layout = l_g)
#' ( rg <- as_reeb_graph(g, l_g[, 1]) )
#' vertex_attr(g, "height") <- rg$value
#' l_rg <- layout_with_sugiyama(g, V(g)$height)
#' plot(g, layout = l_rg)

#' @examplesIf rlang::is_installed("network")
#' library(network)
#' data("emon")
#' mtsi <- emon$Cheyenne
#' mtsi_reeb <- as_reeb_graph(
#'   mtsi,
#'   values = "Command.Rank.Score",
#'   names = "vertex.names"
#' )
#' print(mtsi_reeb, minlength = 24)
#' @export
as_reeb_graph <- function(x, ...) UseMethod("as_reeb_graph")

#' @rdname as_reeb_graph
#' @export
as_reeb_graph.igraph <- function(x, values = NULL, names = NULL, ...) {
  if (is.null(values)) {
    x_attr <- igraph::vertex_attr_names(x)
    x_attr <- which(vapply(x_attr, function(nm) {
      nm_values <- igraph::vertex_attr(x, nm)
      is.numeric(nm_values) & ! any(is.na(nm_values))
    }, FALSE))
    if (length(x_attr) == 0L)
      stop("Input `igraph` object has no complete numeric vertex attributes.")
    values <- igraph::vertex_attr(x, names(x_attr))
  } else if (is.character(values)) {
    values <- igraph::vertex_attr(x, values)
  }

  if (! is.null(names))
    names(values) <- igraph::vertex_attr(x, names)

  if (! is.null(names)) {
    if (names %in% igraph::vertex_attr_names(x)) {
      names(values) <- igraph::vertex_attr(x, names)
    } else {
      warning("`igraph` object has no vertex attribute '", names, "'.")
    }
  }

  r <- reeb_graph(values, igraph::as_edgelist(x, names = FALSE))
}

#' @rdname as_reeb_graph
#' @export
as_reeb_graph.network <- function(x, values = NULL, names = NULL, ...) {
  if (network::is.bipartite(x))
    stop("Input `network` must not be bipartite.")
  if (network::is.hyper(x))
    stop("Input `network` must not be a hypergraph.")

  if (is.null(values)) {
    x_attr <- network::list.vertex.attributes(x)
    x_attr <- which(vapply(x_attr, function(nm) {
      nm_values <- network::get.vertex.attribute(x, nm)
      is.numeric(nm_values) & ! any(is.na(nm_values))
    }, FALSE))
    if (length(x_attr) == 0L)
      stop("Input `network` object has no complete numeric vertex attributes.")
    values <- network::get.vertex.attribute(x, names(x_attr)[min(x_attr)])
  } else if (is.character(values)) {
    values <- network::get.vertex.attribute(x, values)
  }

  if (! is.null(names)) {
    if (! names %in% network::list.vertex.attributes(x)) {
      warning("`network` object has no vertex attribute '", names, "'.")
    } else {
      names(values) <- network::get.vertex.attribute(x, names)
    }
  }

  reeb_graph(values, as.matrix(x, matrix.type = "edgelist"))
}

#' @rdname as_reeb_graph
#' @export
as_igraph <- function(x, ...) UseMethod("as_igraph")

#' @rdname as_reeb_graph
#' @export
as_igraph.reeb_graph <- function(x, values = "value", names = "name", ...) {
  g <- igraph::graph_from_edgelist(x$edgelist)
  igraph::vertex_attr(g, values) <- unname(x$values)
  if (! is.null(names))
    igraph::vertex_attr(g, names) <- names(x$values)
  g
}

#' @rdname as_reeb_graph
#' @export
as_network <- function(x, ...) UseMethod("as_network")

#' @rdname as_reeb_graph
#' @export
as_network.reeb_graph <- function(
    x, values = "value", names = "vertex.names", ...
) {
  net <- network::network(x$edgelist, matrix.type = "edgelist", multiple = TRUE)
  network::set.vertex.attribute(net, values, unname(x$values))
  if (! is.null(names) && ! is.null(names(x$values)))
    network::set.vertex.attribute(net, names, names(x$values))
  net
}
