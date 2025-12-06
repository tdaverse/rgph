

propagatepair <- function(vertex_indices, vertex_heights, edges_from, edges_to) {

  # change value to height
  # do floats and doubles differ for R and java

  # reading in a sample test file
  files <- .jarray(c("./files/mergepairingtest.txt"))
  # converting R vectors into the required format for java
  vertex_indices_java <- .jarray(as.integer(vertex_indices))
  vertex_heights_java <- .jfloat(vertex_heights)
  edges_from_java <- .jarray(as.integer(edges_from))
  edges_to_java <- .jarray(as.integer(edges_to))

  # creating a java object of type MergePairingCLI
  jhw <- .jnew("usf.saav.cmd.PPPairingCLI")
  # calling method to run propagate pairing algorithm for custom lists
  .jcall(jhw, "V", "mainR", vertex_indices_java, vertex_heights_java, edges_from_java, edges_to_java)

  # retrieving the prepopulated list
  rlist <- .jcall("usf/saav/cmd/PPPairingCLI",
                  "[Ljava/lang/String;", "getFinalGraph")

  # retrieving the separate lists
  pValues <- .jcall("usf/saav/cmd/PPPairingCLI",
                    "[F", "getPValues")

  pRealValues <- .jcall("usf/saav/cmd/PPPairingCLI",
                        "[F", "getPRealValues")

  vValues <- .jcall("usf/saav/cmd/PPPairingCLI",
                    "[F", "getVValues")

  vRealValues <- .jcall("usf/saav/cmd/PPPairingCLI",
                        "[F", "getVRealValues")

  pGlobalIDs <- .jcall("usf/saav/cmd/PPPairingCLI",
                       "[I", "getPGlobalIDs")

  vGlobalIDs <- .jcall("usf/saav/cmd/PPPairingCLI",
                       "[I", "getVGlobalIDs")

  elapsedTime <- .jcall("usf/saav/cmd/PPPairingCLI",
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


test_pp <- function() {
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

  print(propagatepair(vertex_indices, vertex_values, edges_from, edges_to))

}
