#' Helpers for Accessing and Querying Amazon Athena
#'
#' Methods are provides to connect to 'Amazon' 'Athena', lookup schemas/tables,
#' perform queries and retrieve query results. A lightweight 'RJDBC' implementation
#' is included along with an interface to the 'AWS' command-line utility.
#'
#' @section IMPORTANT:
#'
#' Since R 3.5 (I don't remember this happening in R 3.4.x) signals sent from interrupting 
#' Athena JDBC calls crash the R #' interpreter. You need to set the `-Xrs` option to avoid
#' signals being passed on to the JVM owner. That has to be done _#' before_ `rJava` is 
#' loaded so you either need to remember to put it at the top of all scripts _or_ stick this
#' in your local #' `~/.Rprofile` and/or sitewide `Rprofile`:
#'
#'
#'     if (!grepl("-Xrs", getOption("java.parameters", ""))) {
#'       options(
#'         "java.parameters" = c(getOption("java.parameters", default = NULL), "-Xrs")
#'       )
#'     }
#'
#' @name metis
#' @encoding UTF-8
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import RJDBC
#' @keywords internal
#' @import DBI
#' @import dplyr
#' @importFrom jsonlite fromJSON
#' @importFrom readr type_convert
#' @importFrom uuid UUIDgenerate
#' @importFrom sys exec_internal
#' @importFrom aws.signature use_credentials read_credentials
NULL


#' Use Credentials from .aws/credentials File
#'
#' @md
#' @references [aws.signature::use_credentials()] /  [aws.signature::read_credentials()]
#' @name use_credentials
#' @rdname use_credentials
#' @inheritParams aws.signature::use_credentials
#' @export
NULL

#' @name read_credentials
#' @rdname use_credentials
#' @export
NULL
