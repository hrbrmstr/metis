#' AthenaJDBC
#'
#' @export
setClass("AthenaDriver", representation("JDBCDriver", identifier.quote="character", jdrv="jobjRef"))

#' AthenaJDBC
#'
#' @export
Athena <- function(identifier.quote='`') {
  drv <- JDBC(driverClass="com.amazonaws.athena.jdbc.AthenaDriver",
              system.file("AthenaJDBC41-1.1.0.jar", package="metis"),
              identifier.quote=identifier.quote)
  return(as(drv, "AthenaDriver"))
}

#' AthenaJDBC
#'
#' @export
setMethod(

  "dbConnect",
  "AthenaDriver",

  def = function(drv,
                 provider = "com.amazonaws.athena.jdbc.shaded.com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
                 region = "us-east-1",
                 s3_staging_dir = Sys.getenv("AWS_S3_STAGING_DIR"),
                 schema_name = "default",
                 max_error_retries = 10,
                 connection_timeout = 10000,
                 socket_timeout = 10000,
                 retry_base_delay = 100,
                 retry_max_backoff_time = 1000,
                 log_path,
                 log_level,
                 ...) {

    conn_string = sprintf('jdbc:awsathena://athena.%s.amazonaws.com:443/%s', region, schema_name)

    # if (!is.null(provider)) {

    jc <- callNextMethod(drv, conn_string,
                         s3_staging_dir = s3_staging_dir,
                         schema_name = schema_name,
                         max_error_retries = max_error_retries,
                         connection_timeout = connection_timeout,
                         socket_timeout = socket_timeout,
                         retry_base_delay = retry_base_delay,
                         retry_max_backoff_time = retry_max_backoff_time,
                         log_path = log_path,
                         log_level = log_level,
                         aws_credentials_provider_class = provider,
                         ...)

    # } else {
    #
    #   jc <- callNextMethod(drv, conn_string,
    #                        schema_name = schema_name,
    #                        max_error_retries = max_error_retries,
    #                        connection_timeout = connection_timeout,
    #                        socket_timeout = socket_timeout,
    #                        retry_base_delay = retry_base_delay,
    #                        retry_max_backoff_time = retry_max_backoff_time,
    #                        s3_staging_dir = s3_staging_dir,
    #                        schema_name = schema_name,
    #                        log_path = log_path,
    #                        log_level = log_level,
    #                        user = Sys.getenv("AWS_ACCESS_KEY_ID"),
    #                        password = Sys.getenv("AWS_SECRET_ACCESS_KEY"))
    #
    # }

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
    dplyr::tbl_df(fetch(r, -1, block=1000))
  }

)
