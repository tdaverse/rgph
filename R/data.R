#' @title Glomerular Capillary Networks
#'
#' @description These edge lists encode the capillary structure of several
#'   murine glomeruli.
#'
#' @details As meta-analyzed by Wahl &al (2004), several investigations of the
#'   capillary systems in (mostly rat) glomeruli have produced transit-style
#'   diagrams of their network structure. Some of these painstakingly
#'   reconstructed networks are used to illustrate data analysis using Reeb
#'   graphs.
#'
#'   The transit diagrams were encoded as edgelists via breadth-first search. In
#'   each case, vertex `1` is the afferent arteriole and the highest-index
#'   vertex is the efferent arteriole.
#'
#'   There is no intrinsic height function. Instead, circuit analysis can be
#'   used to infer direction of flow and assign pressure differentials to the
#'   vertices.
#'
#' @format 2-column matrices encoding undirected graphs indexed from 1:
#' \describe{
#'   \item{`Nyengaard1993`}{newborn rat (Nyengaard & Marcussen, 1993)}
#' }
#' @name glomeruli
#' @aliases Nyengaard1993
#' @keywords datasets
#' @template ref-nyengaard1993
#' @template ref-wahl2004
NULL
