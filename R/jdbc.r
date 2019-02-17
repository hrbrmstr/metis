structure(
  0:6,
  .Names = c(
    "OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE"
  )
)-> .ll_trans

#' AthenaJDBC
#'
#' @export
setClass(

  "AthenaDriver",
  representation(
    "JDBCDriver",
    identifier.quote = "character",
    jdrv = "jobjRef"
  )

)

#' AthenaJDBC
#'
#' @param identifier.quote how to quote identifiers
#' @export
Athena <- function(identifier.quote = '`') {

  JDBC(
    driverClass = "com.simba.athena.jdbc.Driver",
    metis.jars::metis_jar_path(),
    identifier.quote = identifier.quote
  ) -> drv

  return(as(drv, "AthenaDriver"))

}

#' AthenaJDBC
#'
#' Connect to Athena
#'
#' @section Driver Configuration Options:
#'
#' - `BinaryColumnLength`: <int> The maximum data length for `BINARY` columns. Default `32767L`
#' - `ComplexTypeColumnLength`: <int> The maximum data length for `ARRAY`, `MAP`, and `STRUCT` columns. Default `65535L`
#' - `StringColumnLength`: <int> The maximum data length for `STRING` columns. Default `255L`
#'
#' @param drv driver
#' @param provider JDBC auth provider (ideally leave default)
#' @param region AWS region the Athena tables are in
#' @param s3_staging_dir A write-able bucket on S3 that you have permissions for
#' @param schema_name LOL if only this actually worked with Amazon's hacked Presto driver
#' @param max_error_retries,connection_timeout,socket_timeout
#'     technical connection info that you should only muck with if you know what you're doing.
#' @param log_path,log_level The Athena JDBC driver can (shockingly) provide a decent bit
#'     of data in logs. Set this to a temporary directory or something log4j can use. For
#'     `log_level` use the names ("INFO", "DEBUG", "WARN", "ERROR", "ALL", "OFF", "FATAL", "TRACE") or
#'     their corresponding integer values 0-6.
#' @param fetch_size Athena results fetch size
#' @param ... passed on to the driver. See Details.
#' @references [Connect with JDBC](https://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html);
#'     [Simba Athena JDBC Driver with SQL Connector Installation and Configuration Guide](https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.6/docs/Simba+Athena+JDBC+Driver+Install+and+Configuration+Guide.pdf)
#' @export
setMethod(

  "dbConnect",
  "AthenaDriver",

  def = function(
    drv,
    provider = "com.simba.athena.amazonaws.auth.DefaultAWSCredentialsProviderChain",
    region = "us-east-1",
    s3_staging_dir = Sys.getenv("AWS_S3_STAGING_DIR"),
    schema_name = "default",
    fetch_size = 1000L,
    max_error_retries = 10,
    connection_timeout = 10000,
    socket_timeout = 10000,
    log_path = "",
    log_level = 0,
    ...) {

    conn_string = sprintf(
      'jdbc:awsathena://athena.%s.amazonaws.com:443/%s', region, schema_name
    )

    if (!(log_level %in% 0:6)) log_level <- .ll_trans[log_level]

    callNextMethod(
      drv,
      conn_string,
      S3OutputLocation = s3_staging_dir,
      Schema = schema_name,
      MaxErrorRetry = max_error_retries,
      ConnectTimeout = connection_timeout,
      SocketTimeout = socket_timeout,
      LogPath = log_path,
      LogLevel = log_level,
      AwsCredentialsProviderClass = provider,
      ...
    ) -> jc


    jc <- as(jc, "AthenaConnection")
    jc@fetch_size <- as.integer(fetch_size)

    return(jc)

  }

)

#' AthenaJDBC
#'
#' @param jc job ref
#' @param identifier.quote how to quote identifiers
#' @param fetch_size Athena results fetch size
#' @export
setClass("AthenaConnection", representation("JDBCConnection", jc="jobjRef", identifier.quote="character", fetch_size="integer"))

# setClass("AthenaConnection", contains = "JDBCConnection")

#' AthenaJDBC
#'
#' @export
setClass("AthenaResult", contains = "JDBCResult")

#' AthenaJDBC
#'
#' @param conn Athena connection
#' @param statement SQL statement
#' @param ... unused
#' @export
setMethod(

  "dbSendQuery",
  signature(conn="AthenaConnection", statement="character"),

  definition = function(conn, statement, ...) {
    return(as(callNextMethod(), "AthenaResult"))
  }

)

#' AthenaJDBC
#'
#' @param conn Athena connection
#' @param pattern table name pattern
#' @param schema Athena schema name
#' @param ... unused
#' @export
setMethod(

  "dbListTables",
  signature(conn="AthenaConnection"),

  definition = function(conn, pattern='*', schema, ...) {

    if (missing(pattern)) {
      dbGetQuery(
        conn, sprintf("SHOW TABLES IN %s", schema)
      ) -> x
    } else {
      dbGetQuery(
        conn, sprintf("SHOW TABLES IN %s %s", schema, dbQuoteString(conn, pattern))
      ) -> x
    }

    x$tab_name
  }

)

#' AthenaJDBC
#'
#' @param conn Athena connection
#' @param name table name
#' @param schema Athena schema name
#' @param ... unused
#' @export
setMethod(

  "dbExistsTable",
  signature(conn="AthenaConnection", name="character"),

  definition = function(conn, name, schema, ...) {
    length(dbListTables(conn, schema=schema, pattern=name)) > 0
  }

)

#' AthenaJDBC
#'
#' @param conn Athena connection
#' @param name table name
#' @param schema Athena schema name
#' @param ... unused
#' @export
setMethod(

  "dbListFields",
  signature(conn="AthenaConnection", name="character"),

  definition = function(conn, name, schema, ...) {
    query <- sprintf("SELECT * FROM %s.%s LIMIT 1", schema, name)
    res <- dbGetQuery(conn, query)
    colnames(res)
  }

)

#' AthenaJDBC
#'
#' @param conn Athena connection
#' @param name table name
#' @param schema Athena schema name
#' @param ... unused
#' @export
setMethod(

  "dbReadTable",
  signature(conn="AthenaConnection", name="character"),

  definition = function(conn, name, schema, ...) {
    query <- sprintf("SELECT * FROM %s.%s LIMIT 1", schema, dbQuoteString(conn, name))
    dbGetQuery(conn, query)
  }

)
