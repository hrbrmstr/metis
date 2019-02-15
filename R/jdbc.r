.jt <- list(
  BIT = -7,
  TINYINT = -6,
  BIGINT = -5,
  LONGVARBINARY = -4,
  VARBINARY = -3,
  BINARY = -2,
  LONGVARCHAR = -1,
  .NULL = 0,
  CHAR = 1,
  NUMERIC = 2,
  DECIMAL = 3,
  INTEGER = 4,
  SMALLINT = 5,
  FLOAT = 6,
  REAL = 7,
  DOUBLE = 8,
  VARCHAR = 12,
  DATE = 91,
  TIME = 92,
  TIMESTAMP = 93,
  OTHER = 1111
)


stats::setNames(
  0:6,
  c("OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE")
) -> .ll_trans

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
#' @export
Athena <- function(identifier.quote = '`') {

  JDBC(
    driverClass = "com.simba.athena.jdbc.Driver",
    system.file("java", "AthenaJDBC42_2.0.6.jar", package = "metis"),
    identifier.quote = identifier.quote
  ) -> drv

  return(as(drv, "AthenaDriver"))

}

#' AthenaJDBC
#'
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
#' @param ... unused
#' @references <https://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html>
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
    max_error_retries = 10,
    connection_timeout = 10000,
    socket_timeout = 10000,
    # retry_base_delay = 100,
    # retry_max_backoff_time = 1000,
    log_path,
    log_level,
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
      # retry_base_delay = retry_base_delay,
      # retry_max_backoff_time = retry_max_backoff_time,
      LogPath = log_path,
      LogLevel = log_level,
      AwsCredentialsProviderClass = provider,
      ...
    ) -> jc

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
#' @param statement SQL statement
#' @param ... unused
#' @importFrom rJava .jcall
#' @export
setMethod(

  "dbGetQuery",
  signature(conn="AthenaConnection", statement="character"),

  definition = function(conn, statement, type_convert=FALSE, ...) {

    r <- dbSendQuery(conn, statement, ...)

    on.exit(.jcall(r@stat, "V", "close"))

    structure(
      list(
        cols = list(),
        default = structure(list(), class = c("collector_guess", "collector"))
      ),
      class = "col_spec"
    ) -> l

    cols <- .jcall(r@md, "I", "getColumnCount")
    nms <- c()

    cts <- rep(0L, cols)
    for (i in 1:cols) {
      ct <- .jcall(r@md, "I", "getColumnType", i)
      if (ct == .jt$CHAR) {
        l$cols[[i]] <- col_character()
      } else if (ct == .jt$NUMERIC) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$DECIMAL) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$INTEGER) {
        l$cols[[i]] <- col_integer()
      } else if (ct == .jt$SMALLINT) {
        l$cols[[i]] <- col_integer()
      } else if (ct == .jt$TINYINT) {
        l$cols[[i]] <- col_integer()
      } else if (ct == .jt$BIGINT) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$FLOAT) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$REAL) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$DOUBLE) {
        l$cols[[i]] <- col_double()
      } else if (ct == .jt$VARCHAR) {
        l$cols[[i]] <- col_character()
      } else if (ct == .jt$DATE) {
        l$cols[[i]] <- col_date()
      } else if (ct == .jt$TIME) {
        l$cols[[i]] <- col_time()
      } else if (ct == .jt$TIMESTAMP) {
        l$cols[[i]] <- col_datetime()
      } else if (ct == .jt$BIT) {
        l$cols[[i]] <- col_logical()
      } else {
        l$cols[[i]] <- col_character()
      }
      nms[i] <- .jcall(r@md, "S", "getColumnLabel", i)
    }

    l$cols <- stats::setNames(l$cols, nms)

    res <- fetch(r, -1, block=1000)
    res <- readr::type_convert(res, col_types = l)

    class(res) <- c("tbl_df", "tbl", "data.frame")

    res

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
