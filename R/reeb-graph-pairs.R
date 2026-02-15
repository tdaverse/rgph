#' @title Pair Reeb Graph Critical Points via Java
#'
#' @description This function calls one of two methods, merge-pair and
#'   propagate-and-pair, to pair the critical points of a Reeb graph.
#'
#' @details The function uses the `rJava` package to call either of two Java
#'   methods from `ReebGraphPairing`. Ensure the Java Virtual Machine (JVM) is
#'   initialized and the required class is available in the class path.
#'
#'   The Propagate-and-Pair algorithm (`"single_pass"`) performs both join and
#'   split merge tree operations along a single sweep through the Reeb graph. It
#'   was shown to be more efficient on most test data, and to scale better with
#'   graph size, than an algorithm (`"multi_pass"`) that pairs some types along
#'   the sublevel filtration and others along the superlevel filtration (Tu &al,
#'   2019).
#'
#'   The output S3 class is a list of 2-column matrices containing the types,
#'   values, indices, and orders of persistent pairs, with attributes containing
#'   the node names and metadata. The [print()] method visually expresses each
#'   pair, increasing from left to right, with nodes formatted as with
#'   [reeb_graph].
#'
#'   The names of the coerced data frame use `lo_` and `hi_` prefixes, in
#'   contrast to the Java source code that uses `birth_` and `death_`. This is
#'   meant to distinguish the pairs and their metadata from [persistent
#'   homology][reeb_graph_persistence], which is here reformulated following
#'   Carrière & Oudot (2018).
#'
#' @param x A [`reeb_graph`][reeb_graph] object.
#' @inheritParams as_reeb_graph
#' @param sublevel Logical; whether to use the sublevel set filtration (`TRUE`,
#'   the default) or else the superlevel set filtration (via reversing
#'   `x[["values"]]` before paring critical points.
#' @param method Character; the pairing method to use. Matched to
#'   `"single_pass"` (the default) or `"multi_pass"`.
#' @param n Integer number of critical pairs to print.
#' @param minlength Minimum name abbreviation length; passed to
#'   [base::abbreviate()].
#' @return A list of subclass [reeb_graph_pairs] containing 4 2-column matrices
#'   characterizing the low- and high-valued critical points of each pair:
#'   \describe{
#'     \item{`type`}{
#'       Character; the type of critical point,
#'       one of `LEAF_MIN`, `LEAF_MAX`, `UPFORK`, and `DOWNFORK`.
#'     }
#'     \item{`value`}{
#'       Double; the value (stored in `x[["values"]]`) of the critical point.
#'     }
#'     \item{`index`}{
#'       Integer; the index (used in `x[["edgelist"]]`) of the critical point.
#'       Regular points will not appear,
#'       while degenerate critical points will appear multiple times.
#'     }
#'     \item{`order`}{
#'       Integer; the order of the critical point in the pairing.
#'       This is based on the conditioned Reeb graph constructed internally
#'       so will not be duplicated.
#'     }
#'   }
#'   The data frame also has attributes `"names"` for the node names, `"method"`
#'   for the method used, and `"elapsed_time"` for the elapsed time.
#' @seealso [reeb_graph_persistence()]
#' @examples
#' ex_sf <- system.file("extdata", "running_example.txt", package = "rgph")
#' ( ex_rg <- read_reeb_graph(ex_sf) )
#' ( ex_cp <- reeb_graph_pairs(ex_rg) )
#' attr(ex_cp, "method")
#' attr(ex_cp, "elapsed_time")
#'
#' reeb_graph_pairs(ex_rg, sublevel = FALSE)
#'
#' x <- reeb_graph(
#'   values = c(0, .4, .6, 1),
#'   edgelist = c( 1,2, 1,3, 2,4, 3,4 )
#' )
#' ( mp <- reeb_graph_pairs(x) )
#' class(mp)
#' as.data.frame(mp)
#'
#' names(x$values) <- letters[seq_along(x$values)]
#' ( mp <- reeb_graph_pairs(x) )
#' as.data.frame(mp)
#'
#' @examplesIf rlang::is_installed("network")
#' library(network)
#' data("emon")
#' mtsi <- emon$Cheyenne
#' mtsi_reeb <- as_reeb_graph(
#'   mtsi,
#'   values = "Command.Rank.Score",
#'   names = "vertex.names"
#' )
#' mtsi_cp <- reeb_graph_pairs(mtsi_reeb, sublevel = FALSE)
#' print(mtsi_cp, minlength = 20)
#' @template ref-reebgraphpairing
#' @template ref-tu2019
#' @template ref-carriere2018
#' @export
reeb_graph_pairs <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    ...
) UseMethod("reeb_graph_pairs")

#' @rdname reeb_graph_pairs
#' @export
reeb_graph_pairs.default <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    ...
) {
  stop(paste0(
    "No `reeb_graph_pairs()` method for class(es) '",
    paste(class(x), collapse = "', '"),
    "'."
  ))
}

reeb_graph_pairs_graph <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    values = NULL,
    ...
) {
  x <- as_reeb_graph(x, values = values)

  reeb_graph_pairs.reeb_graph(
    x,
    sublevel = sublevel, method = method
  )
}

#' @rdname reeb_graph_pairs
#' @export
reeb_graph_pairs.igraph <- reeb_graph_pairs_graph

#' @rdname reeb_graph_pairs
#' @export
reeb_graph_pairs.network <- reeb_graph_pairs_graph

#' @rdname reeb_graph_pairs
#' @export
reeb_graph_pairs.reeb_graph <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass"),
    ...
) {
  # reverse value function for superlevel set persistence
  if (! is.logical(sublevel) || is.na(sublevel))
    stop("`sublevel` must be `TRUE` or `FALSE`.")
  if (! sublevel) x[["values"]] <- -x[["values"]]

  # dynamically decide which pairing method to use based on the method
  method <- match.arg(tolower(method), c("single_pass", "multi_pass"))

  # remove isolated vertices
  x <- drop_reeb_graph_points(x)

  # converting R vectors into the required format for Java
  vertex_indices_java <- .jarray(seq(0L, length(x[["values"]]) - 1L))
  # REVIEW: Are floats in Java as precise as doubles in R?
  vertex_heights_java <- .jfloat(x[["values"]])
  # first column is the origin vertex
  edges_from_java <- .jarray(as.integer(x[["edgelist"]][, 1L] - 1L))
  # second column is the destination vertex
  edges_to_java <- .jarray(as.integer(x[["edgelist"]][, 2L] - 1L))

  # the name of the Java class we need to instantiate for the pairing method
  pairing_java_object <- switch(
    method,
    multi_pass = paste("usf.saav.cmd.", "MergePairingCLI", sep = ""),
    single_pass = paste("usf.saav.cmd.", "PPPairingCLI", sep = "")
  )
  # the Java project file path of the corresponding pairing type
  java_file_path <- switch(
    method,
    multi_pass = paste("usf/saav/cmd/", "MergePairingCLI", sep=""),
    single_pass = paste("usf/saav/cmd/", "PPPairingCLI", sep="")
  )

  jhw <- .jnew(pairing_java_object)
  # call method to run propagate pairing algorithm for custom lists
  .jcall(
    jhw, "V", "mainR",
    vertex_indices_java, vertex_heights_java, edges_from_java, edges_to_java
  )

  # # retrieve the prepopulated list
  # rlist <- .jcall(java_file_path, "[Ljava/lang/String;", "getFinalGraph")

  # retrieve the separate lists
  pType <- .jcall(java_file_path, "[S", "getPTypes")
  vType <- .jcall(java_file_path, "[S", "getVTypes")
  pRealValues <- .jcall(java_file_path, "[F", "getPRealValues")
  vRealValues <- .jcall(java_file_path, "[F", "getVRealValues")
  pValues <- .jcall(java_file_path, "[F", "getPValues") + 1L
  vValues <- .jcall(java_file_path, "[F", "getVValues") + 1L
  pGlobalIDs <- .jcall(java_file_path, "[I", "getPGlobalIDs") + 1L
  vGlobalIDs <- .jcall(java_file_path, "[I", "getVGlobalIDs") + 1L
  elapsedTime <- .jcall(java_file_path, "D", "getElapsedTime")

  # un-reverse value function
  if (! sublevel) {
    pRealValues <- -pRealValues
    vRealValues <- -vRealValues
  }

  # assemble as a list of 2-column matrices
  res <- list(
    type  = cbind(lo = vType      , hi = pType      ),
    value = cbind(lo = vRealValues, hi = pRealValues),
    index = cbind(lo = vGlobalIDs , hi = pGlobalIDs ),
    order = cbind(lo = vValues    , hi = pValues    )
  )
  attr(res, "vertex_names") <- names(x[["values"]])
  attr(res, "sublevel") <- sublevel
  attr(res, "method") <- method
  attr(res, "elapsed_time") <- elapsedTime

  class(res) <- c("reeb_graph_pairs", class(res))
  res
}

#' @rdname reeb_graph_pairs
#' @export
as.data.frame.reeb_graph_pairs <- function(x, ...) {
  check_reeb_graph_pairs(x)
  df <- do.call(cbind, lapply(x, as.data.frame))
  colnames(df) <- outer(
    c("lo", "hi"),
    c("type", "value", "index", "order"),
    FUN = paste, sep = "_"
  )
  if (! is.null(attr(x, "vertex_names"))) {
    df$lo_name <- attr(x, "vertex_names")[df$lo_index]
    df$hi_name <- attr(x, "vertex_names")[df$hi_index]
  }
  df
}

drop_reeb_graph_points <- function(x) {
  incidents <- sort(unique(as.vector(x$edgelist)))
  n_isolates <- length(x$values) - length(incidents)
  if (n_isolates > 0L) {
    x$values <- x$values[incidents]
    x$edgelist[] <- match(x$edgelist, incidents)
    message("Note: ", n_isolates, " isolated vertices were dropped.")
  }
  x
}

check_reeb_graph_pairs <- function(x) {
  stopifnot(
    length(x) == 4L,
    all(names(x) == c("type", "value", "index", "order")),
    length(unique(vapply(x, nrow, 0L))) == 1L,
    all(unique(t(sapply(x, colnames))) == c("lo", "hi")),
    all(x[["type"]] %in% c("LEAF_MIN", "DOWNFORK", "LEAF_MAX", "UPFORK")),
    is.numeric(x[["value"]]),
    is.integer(x[["index"]]),
    is.numeric(x[["order"]]),
    # RHS is only evaluated if LHS is false
    is.null(attr(x, "vertex_names")) || is.character(attr(x, "vertex_names"))
  )
  # check that types are comprehensible
  stopifnot(
    all(x[["type"]][, 1L] == "LEAF_MIN" | x[["type"]][, 1L] == "UPFORK"),
    all(x[["type"]][, 2L] == "LEAF_MAX" | x[["type"]][, 2L] == "DOWNFORK")
  )
}

#' @rdname reeb_graph_pairs
#' @export
print.reeb_graph_pairs <- function(x, ..., n = NULL, minlength = 12L) {
  cat(format(x, ..., n = n, minlength = minlength), sep = "\n")
}

#' @rdname reeb_graph_pairs
#' @export
format.reeb_graph_pairs <- function(x, ..., n = NULL, minlength = 12L) {
  # summary info
  npairs <- nrow(x[["index"]])
  vnames <- ! is.null(attr(x, "vertex_names"))

  # formatting decisions
  if (is.null(n)) n <- min(npairs, 12L)
  if (vnames) minlength <- min(
    minlength,
    min(nchar(attr(x, "vertex_names")), na.rm = TRUE)
  )

  # vertical components
  pair_val <- apply(x[["value"]][seq(n), ], 2L, format)
  pair_ind <- apply(x[["index"]][seq(n), ], 2L, format)
  if (vnames) {
    pair_nam <-
      matrix(attr(x, "vertex_names")[x[["index"]][seq(n), ]], ncol = 2L)
    pair_nam <- abbreviate(
      pair_nam, minlength = minlength,
      strict = TRUE, named = FALSE
    )
    pair_nam[is.na(pair_nam)] <- ""
    pair_nam <- format(pair_nam, width = max(nchar(pair_nam)), justify = "left")
  }

  # body
  pair_fmt <- matrix(paste0(
    # high type
    c(
      LEAF_MIN = "", UPFORK = "", LEAF_MAX = "-• ", DOWNFORK = ">- "
    )[x[["type"]][seq(n), ]],
    # node info
    pair_ind,
    if (vnames) paste0("[", pair_nam, "]"),
    " (", pair_val, ")",
    # low type
    c(
      LEAF_MIN = " •-", UPFORK = " -<", LEAF_MAX = "", DOWNFORK = ""
    )[x[["type"]][seq(n), ]]
  ), ncol = 2L)
  pair_fmt <- apply(pair_fmt, 1L, paste, collapse = " ... ")

  # output
  cat(
    sprintf("Reeb graph critical pairing (%i pairs):", npairs),
    pair_fmt,
    sep = "\n"
  )
}
