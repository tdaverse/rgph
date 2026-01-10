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
#'   Note that the names of the output data frame use `lo_` and `hi_` prefixes,
#'   in contrast to the Java source code that uses `birth_` and `death_`. This
#'   is meant to distinguish the pairs and their metadata from [persistent
#'   homology][reeb_graph_persistence], which is here reformulated following
#'   Carrière & Oudot (2018).
#'
#'   The output S3 class is a light wrapper around a data frame containing the
#'   types, values, indices, and orders of persistent pairs.
#'
#' @param x A [`reeb_graph`][reeb_graph] object.
#' @param sublevel Logical; whether to use the sublevel set filtration (`TRUE`,
#'   the default) or else the superlevel set filtration (via reversing
#'   `x$values` before paring critical points.
#' @param method Character; the pairing method to use. Matched to
#'   `"single_pass"` (the default) or `"multi_pass"`.
#' @return A data frame with subclass [reeb_graph_pairs] containing eight
#'   vectors output by the Java method characterizing the low- and high-valued
#'   critical points of each pair:
#'   \describe{
#'     \item{`lo_type`,`hi_type`}{
#'       Character; the type of critical point,
#'       one of `LEAF_MIN`, `LEAF_MAX`, `UPFORK`, and `DOWNFORK`.
#'     }
#'     \item{`lo_value`,`hi_value`}{
#'       Double; the value (stored in `x$values`) of the critical point.
#'     }
#'     \item{`lo_index,hi_index`}{
#'       Integer; the index (used in `x$edgelist`) of the critical point.
#'       Regular points will not appear,
#'       while degenerate critical points will appear multiple times.
#'     }
#'     \item{`lo_order,hi_order`}{
#'       Integer; the order of the critical point in the pairing.
#'       This is based on the conditioned Reeb graph constructed internally
#'       so will not be duplicated.
#'     }
#'   }
#'   The data frame also has attributes `"method"` for the method used and
#'   `"elapsedTime"` for the elapsed time.
#' @examples
#' ex_sf <- system.file("extdata", "running_example.txt", package = "rgp")
#' ( ex_rg <- read_reeb_graph(ex_sf) )
#' ( ex_cp <- reeb_graph_pairs(ex_rg) )
#' attr(ex_cp, "method")
#' attr(ex_cp, "elapsedTime")
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
#' @template ref-reebgraphpairing
#' @template ref-tu2019
#' @template ref-carriere2018
#' @export
reeb_graph_pairs <- function(
    x,
    sublevel = TRUE,
    method = c("single_pass", "multi_pass")
) {
  stopifnot(inherits(x, "reeb_graph"))

  # reverse value function
  if (! is.logical(sublevel) || is.na(sublevel))
    stop("`sublevel` must be `TRUE` or `FALSE`.")
  if (! sublevel) x$values <- -x$values
  # dynamically decide which pairing method to use based on the method
  method <- match.arg(tolower(method), c("single_pass", "multi_pass"))

  # converting R vectors into the required format for Java
  vertex_indices_java <- .jarray(as.integer(seq(0L, length(x$values) - 1L)))
  # REVIEW: Are floats in Java as precise as doubles in R?
  vertex_heights_java <- .jfloat(x$values)
  # first column is the origin vertex
  edges_from_java <- .jarray(as.integer(x$edgelist[, 1L] - 1L))
  # second column is the destination vertex
  edges_to_java <- .jarray(as.integer(x$edgelist[, 2L] - 1L))

  # the name of the Java class we need to instantiate for the pairing method
  pairing_java_object <- switch(
    method,
    single_pass = paste("usf.saav.cmd.", "MergePairingCLI", sep = ""),
    multi_pass = paste("usf.saav.cmd.", "PPPairingCLI", sep = "")
  )
  # the Java project file path of the corresponding pairing type
  java_file_path <- switch(
    method,
    single_pass = paste("usf/saav/cmd/", "MergePairingCLI", sep=""),
    multi_pass = paste("usf/saav/cmd/", "PPPairingCLI", sep="")
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

  # assemble as data frame
  res <- data.frame(
    lo_type  = vType,
    hi_type  = pType,
    lo_value = vRealValues,
    hi_value = pRealValues,
    lo_index = vGlobalIDs,
    hi_index = pGlobalIDs,
    lo_order = vValues,
    hi_order = pValues
  )
  attr(res, "sublevel") <- sublevel
  attr(res, "method") <- method
  attr(res, "elapsedTime") <- elapsedTime

  class(res) <- c("reeb_graph_pairs", class(res))
  res
}

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
  # check that types are comprehensible
  stopifnot(
    all(cp$lo_type == "LEAF_MIN" | cp$lo_type == "UPFORK"),
    all(cp$hi_type == "LEAF_MAX" | cp$hi_type == "DOWNFORK")
  )
}
