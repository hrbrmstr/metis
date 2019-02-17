#' Access and Query Amazon Athena via DBI/JDBC
#'
#' Methods are provided to connect to 'Amazon' 'Athena', lookup
#' schemas/tables, perform queries and retrieve query results using the
#' Athena JDBC driver found in 'metis.jars'.
#'
#' @name metis
#'
#' @md
#' @encoding UTF-8
#' @keywords internal
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import RJDBC DBI bit64 metis.jars
#' @importFrom methods as callNextMethod
#' @references [Simba Athena JDBC Driver with SQL Connector Installation and Configuration Guide](https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.6/docs/Simba+Athena+JDBC+Driver+Install+and+Configuration+Guide.pdf)
NULL

#' Use Credentials from .aws/credentials File
#'
#' @md
#' @importFrom aws.signature use_credentials read_credentials
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
