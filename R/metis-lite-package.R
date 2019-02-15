#' Helpers for Accessing and Querying Amazon Athena
#'
#' Methods are provides to connect to 'Amazon' 'Athena', lookup schemas/tables,
#' perform queries and retrieve query results. A lightweight 'RJDBC' implementation
#' is included along with an interface to the 'AWS' command-line utility.
#'
#' @name metis.lite
#' @encoding UTF-8
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import RJDBC
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
