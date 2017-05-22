#' AthenaJDBC
#'
#' @export
setClass("AthenaDriver", representation("JDBCDriver", identifier.quote="character", jdrv="jobjRef"))

#' AthenaJDBC
#'
#' @export
Athena <- function(identifier.quote='`') {
  drv <- JDBC(driverClass="com.amazonaws.athena.jdbc.AthenaDriver",
              system.file("AthenaJDBC41-1.0.1.jar", package="metis"),
              identifier.quote="'")
  return(as(drv, "AthenaDriver"))
}

#' AthenaJDBC
#'
#' @export
setMethod(

  "dbConnect",
  "AthenaDriver",

  def = function(drv,
                 provider = "com.amazonaws.athena.jdbc.shaded.com.amazonaws.auth.EnvironmentVariableCredentialsProvider",
                 conn_string = 'jdbc:awsathena://athena.us-east-1.amazonaws.com:443/',
                 schema_name, ...) {

    if (!is.null(provider)) {

      jc <- callNextMethod(drv, conn_string,
                           s3_staging_dir=Sys.getenv("AWS_S3_STAGING_DIR"),
                           schema_name=schema_name,
                           aws_credentials_provider_class=provider, ...)

    } else {

      jc <- callNextMethod(drv,
                       'jdbc:awsathena://athena.us-east-1.amazonaws.com:443/',
                       s3_staging_dir=Sys.getenv("AWS_S3_STAGING_DIR"),
                       schema_name=schema_name,
                       user = Sys.getenv("AWS_ACCESS_KEY_ID"),
                       password = Sys.getenv("AWS_SECRET_ACCESS_KEY"))

    }

    return(as(jc, "AthenaConnection"))

  }

)

#' AthenaJDBC
#'
#' @export
setClass("AthenaConnection", contains = "JDBCConnection")

#' AthenaJDBC
#'
#' @export
setClass("AthenaResult", contains = "JDBCResult")

#' AthenaJDBC
#'
#' @export
setMethod(

  "dbSendQuery",
  "AthenaDriver",

  def = function(conn, statement, ...) {
    return(as(callNextMethod(), "AthenaResult"))
  }

)

#' AthenaJDBC
#'
#' @export
setMethod(

  "dbGetQuery",
  signature(conn="AthenaConnection", statement="character"),

  def = function(conn, statement, ...) {
    r <- dbSendQuery(conn, statement, ...)
    on.exit(.jcall(r@stat, "V", "close"))
    dplyr::tbl_df(fetch(r, -1, block=256))
  }

)
