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
#' @param x A [`reeb_graph`][reeb_graph] object.
#' @param sublevel Logical; whether to take the sublevel set filtration (`TRUE`,
#'   the default) or else the superlevel set filtration (via reversing
#'   `x$values` before paring critical points.
#' @param method Character; the pairing method to use. Matched to
#'   `"single_pass"` (the default) or `"multi_pass"`.
#' @return A data frame containing the six output vectors returned by the Java
#'   method: the birth and death values (`double`), birth and death indices
#'   (`integer`), and birth and death orders (`integer`). The data frame has
#'   attributes `"method"` for the method used and `"elapsedTime"` for the
#'   elapsed time.
#' @examples
#' ex_sf <- system.file("extdata", "running_example.txt", package = "rgp")
#' ( ex_rg <- read_reeb_graph(ex_sf) )
#' ( ex_cp <- reeb_graph_pairs(ex_rg) )
#' attr(ex_cp, "method")
#' attr(ex_cp, "elapsedTime")
#'
#' reeb_graph_pairs(ex_rg, sublevel = FALSE)
#'
#' @template ref-reebgraphpairing
#' @template ref-tu2019
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
    birth_value = vRealValues,
    death_value = pRealValues,
    birth_index = vGlobalIDs,
    death_index = pGlobalIDs,
    birth_order = vValues,
    death_order = pValues
  )
  attr(res, "method") <- method
  attr(res, "elapsedTime") <- elapsedTime
  res
}
