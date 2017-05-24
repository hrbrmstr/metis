#' Helpers for Accessing and Querying Amazon Athena
#'
#' Including a lightweight RJDBC shim.
#'
#' @name metis
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import RJDBC
#' @import DBI
#' @import dplyr
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
