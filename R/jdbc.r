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
#' Mandatory JDBC connection parameters are also named function
#' parameters. You can use `...` to supply additional/optional
#' parameters.
#'
#' @section Higlighted Extra Driver Configuration Options:
#'
#' These are take from the second item in References. See that resource
#' for more information.
#'
#' - `BinaryColumnLength`: <int> The maximum data length for `BINARY` columns. Default `32767L`
#' - `ComplexTypeColumnLength`: <int> The maximum data length for `ARRAY`, `MAP`, and `STRUCT` columns. Default `65535L`
#' - `StringColumnLength`: <int> The maximum data length for `STRING` columns. Default `255L`
#'
#' @param drv driver
#' @param Schema The name of the database schema to use when a schema is not explicitly
#'        specified in a query. You can still issue queries on other schemas by explicitly
#'        specifying the schema in the query.
#' @param AwsRegion AWS region the Athena tables are in
#' @param AwsCredentialsProviderClass JDBC auth provider; You can add a
#'        lengrh1 character vecrtor named parameter `AwsCredentialsProviderArguments`
#'        to the `dbConnect()`  call to use alternate auth providers. Use a
#'        comma-separated list of String arguments.
#' @param S3OutputLocation A write-able bucket on S3 that you have permissions for
#' @param MaxErrorRetry,ConnectTimeout,SocketTimeout
#'     technical connection info that you should only muck with if you know what you're doing.
#' @param LogPath,LogPath The Athena JDBC driver can (shockingly) provide a decent bit
#'     of data in logs. Set this to a temporary directory or something log4j can use. For
#'     `LogPath` use the names ("INFO", "DEBUG", "WARN", "ERROR", "ALL", "OFF", "FATAL", "TRACE") or
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
    Schema = "default",
    AwsRegion = "us-east-1",
    AwsCredentialsProviderClass = "com.simba.athena.amazonaws.auth.DefaultAWSCredentialsProviderChain",
    S3OutputLocation = Sys.getenv("AWS_S3_STAGING_DIR", unset = ""),
    MaxErrorRetry = 10,
    ConnectTimeout = 10000,
    SocketTimeout = 10000,
    LogPath = "",
    LogLevel = 0,
    fetch_size = 1000L,
    ...) {

    conn_string = sprintf(
      'jdbc:awsathena://athena.%s.amazonaws.com:443/%s', AwsRegion, Schema
    )

    if (!(LogLevel %in% 0:6)) LogLevel <- .ll_trans[LogLevel]

    callNextMethod(
      drv,
      conn_string,
      S3OutputLocation = S3OutputLocation,
      Schema = Schema,
      AwsRegion = AwsRegion,
      MaxErrorRetry = MaxErrorRetry,
      ConnectTimeout = ConnectTimeout,
      SocketTimeout = SocketTimeout,
      LogPath = LogPath,
      LogLevel = LogLevel,
      AwsCredentialsProviderClass = AwsCredentialsProviderClass,
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
