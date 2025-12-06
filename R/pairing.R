
propagatepair_java_class_name <- "PPPairingCLI"
mergepairing_java_class_name <- "MergePairingCLI"

merge_pairing_method <- "single_pass"
propagate_pairing_method <- "multi_pass"

java_package_period_delimited <- "usf.saav.cmd."
java_package_class_path <- "usf/saav/cmd/"

pairing <- function(vertex_indices, vertex_heights, edge_list, method) {

  # converting R vectors into the required format for java
  vertex_indices_java <- .jarray(as.integer(vertex_indices))
  vertex_heights_java <- .jfloat(vertex_heights)
  # first column is the origin vertex
  edges_from_java <- .jarray(as.integer(as.list(edge_list[, 1])))
  # second column is the destination vertex
  edges_to_java <- .jarray(as.integer(as.list(edge_list[, 2])))

  # variable holding the name of the java class we need to instantiate for the pairing method we require
  pairing_java_object <- ""
  # the java project file path of the corresponding pairing type
  pairing_java_file_path <- ""

  # dynamically deciding which pairing to use based on the method
  if( tolower(method) == merge_pairing_method) {
    pairing_java_object <- paste(java_package_period_delimited, mergepairing_java_class_name, sep = "")
    pairing_java_file_path <- paste(java_package_class_path, mergepairing_java_class_name, sep="")
  } else if(tolower(method) == propagate_pairing_method) {
    pairing_java_object <- paste(java_package_period_delimited, propagatepair_java_class_name, sep = "")
    pairing_java_file_path <- paste(java_package_class_path, propagatepair_java_class_name, sep="")
  } else {
    print("method must be either \"single_pass\" or \"multi_pass\"")
    return("ERROR")
  }

  jhw <- .jnew(pairing_java_object)
  # calling method to run propagate pairing algorithm for custom lists
  .jcall(jhw, "V", "mainR", vertex_indices_java, vertex_heights_java, edges_from_java, edges_to_java)

  # retrieving the prepopulated list
  rlist <- .jcall(pairing_java_file_path,
                  "[Ljava/lang/String;", "getFinalGraph")

  # retrieving the separate lists
  pValues <- .jcall(pairing_java_file_path,
                    "[F", "getPValues")

  pRealValues <- .jcall(pairing_java_file_path,
                        "[F", "getPRealValues")

  vValues <- .jcall(pairing_java_file_path,
                    "[F", "getVValues")

  vRealValues <- .jcall(pairing_java_file_path,
                        "[F", "getVRealValues")

  pGlobalIDs <- .jcall(pairing_java_file_path,
                       "[I", "getPGlobalIDs")

  vGlobalIDs <- .jcall(pairing_java_file_path,
                       "[I", "getVGlobalIDs")

  elapsedTime <- .jcall(pairing_java_file_path,
                        "D", "getElapsedTime")

  res <- data.frame(
    birth_value = vRealValues,
    death_value = pRealValues,
    birth_index = vGlobalIDs,
    death_index = pGlobalIDs,
    # need to carefully interpret these
    birth_order = vValues,
    death_order = pValues,
    elapsedTime = elapsedTime
  )
  res
}


test_pairing_method <- function() {
  vertex_indices <- c(
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    31, 32, 33, 34, 35, 36, 37, 38, 39, 40
  )

  vertex_values <- c(
    0.0, 1.3862943611198906, 3.295836866004329, 5.545177444479562, 8.047189562170502,
    10.75055681536833, 13.621371043387192, 16.635532333438686, 19.775021196025975, 23.02585092994046,
    26.376848000782076, 29.818879797456006, 33.34434164699998, 36.94680261461362, 40.62075301653315,
    44.3614195558365, 48.16462684895568, 52.02669164213096, 55.94434060416236, 59.914645471079815,
    63.93497119219188, 68.00293397388296, 72.11636696637044, 76.2732919283507, 80.47189562170502,
    84.71050998855854, 88.9875953821169, 93.30172628490571, 97.65157906960775, 102.03592144986466,
    106.45360333903953, 110.90354888959125, 115.38474952839385, 119.89625783694949, 124.43718215212947,
    129.00668178441995, 133.6039627678363, 138.22827406960266, 142.8789041990562, 147.55517816455745,
    152.25645473487663
  )

  edges_from <- c(
    0, 0, 1, 2, 2, 3, 5, 6, 6, 7,
    8, 9, 10, 10, 12, 13, 14, 14, 17, 18,
    18, 20, 21, 22, 22, 23, 25, 26, 26, 27,
    29, 30, 30, 31, 33, 34, 34, 37, 38, 38
  )

  edges_to <- c(
    1, 13, 2, 3, 4, 5, 6, 8, 7, 17,
    9, 10, 11, 12, 29, 14, 16, 15, 18, 19,
    20, 21, 22, 24, 23, 25, 26, 27, 28, 37,
    30, 32, 31, 33, 34, 35, 36, 38, 40, 39
  )

  print("Merge Pairing")
  print(pairing(vertex_indices, vertex_values, cbind(edges_from, edges_to), "single_pass"))

  print("Propagate Pairing")
  print(pairing(vertex_indices, vertex_values, cbind(edges_from, edges_to), "multi_pass"))

}
