#' @title Pair Reeb Graph Critical Points via Java
#'
#' @description This function calls one of two methods, merge-pair and
#'   propagate-and-pair, to compute the extended persistent homology of a Reeb
#'   graph.
#'
#' @details The function uses the `rJava` package to call either of two Java
#'   methods from `ReebGraphPairing`. Ensure the Java Virtual Machine (JVM) is
#'   initialized and the required class is available in the class path.
#'
#' @param name description
#' @return A data frame containing the six output vectors returned by the Java
#'   method: the birth and death values (`double`), birth and death indices
#'   (`integer`), and birth and death orders (`integer`). The data frame has an
#'   attribute `"elapsedTime"` for the elapsed time.
#' @examples
#' ( ex_rg <- read_reeb_graph("files/running_example_reeb_graph.txt") )
#' ( ex_ph <- reeb_graph_pairs(ex_rg) )
#' attr(ex_ph, "elapsedTime")
#'
#' @example inst/examples/ex-reeb-graph-pairs.R
#' @export
reeb_graph_pairs <- function(x, method = "multi_pass") {

  stopifnot(inherits(x, "reeb_graph"))
  # dynamically decide which pairing method to use based on the method
  method <- match.arg(tolower(method), c("single_pass", "multi_pass"))

  # converting R vectors into the required format for Java
  vertex_indices_java <- .jarray(as.integer(seq(0L, length(x$values) - 1L)))
  # REVIEW: Are floats in Java as precise as doubles in R?
  vertex_heights_java <- .jfloat(x$values)
  # first column is the origin vertex
  edges_from_java <- .jarray(as.integer(x$edgelist[, 1L]))
  # second column is the destination vertex
  edges_to_java <- .jarray(as.integer(x$edgelist[, 2L]))

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
  pValues <- .jcall(java_file_path, "[F", "getPValues")
  pRealValues <- .jcall(java_file_path, "[F", "getPRealValues")
  vValues <- .jcall(java_file_path, "[F", "getVValues")
  vRealValues <- .jcall(java_file_path, "[F", "getVRealValues")
  pGlobalIDs <- .jcall(java_file_path, "[I", "getPGlobalIDs")
  vGlobalIDs <- .jcall(java_file_path, "[I", "getVGlobalIDs")
  elapsedTime <- .jcall(java_file_path, "D", "getElapsedTime")

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
