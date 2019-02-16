list(
  "-7" = as.logical, # BIT
  "-6" = as.integer, # TINYINT
  "-5" = bit64::as.integer64, # BIGINT
  "-4" = as.character, # LONGVARBINARY
  "-3" = as.character, # VARBINARY
  "-2" = as.character, # BINARY
  "-1" = as.character, # LONGVARCHAR
  "0" = as.character, # NULL
  "1" = as.character, # CHAR
  "2" = as.double, # NUMERIC
  "3" = as.double, # DECIMAL
  "4" = as.integer, # INTEGER
  "5" = as.integer, # SMALLINT
  "6" = as.double, # FLOAT
  "7" = as.double, # REAL
  "8" = as.double, # DOUBLE
  "12" = as.character, # VARCHAR
  "16" = as.logical, # BOOLEAN
  "91" = as_date, # DATE
  "92" = as.character, # TIME
  "93" = as_posixct, # TIMESTAMP
  "1111" = as.character # OTHER
) -> .jdbc_converters

#' @export
#' @keywords internal
setMethod("dbGetInfo", "AthenaDriver", def=function(dbObj, ...)
  list(
    name = "AthenaJDBC",
    driver_version = list.files(system.file("java", package="metis.lite"), "jar$")[1],
    package_version = utils::packageVersion("metis.lite")
  )
)

#' @export
#' @keywords internal
setMethod("dbGetInfo", "AthenaConnection", def=function(dbObj, ...)
  list(
    name = "AthenaJDBC",
    driver_version = list.files(system.file("java", package="metis.lite"), "jar$")[1],
    package_version = utils::packageVersion("metis.lite")
  )
)


#' Fetch records from a previously executed query
#'
#' Fetch the next `n` elements (rows) from the result set and return them
#' as a data.frame.
#'
#' @param res An object inheriting from [DBIResult-class], created by
#'   [dbSendQuery()].
#' @param n maximum number of records to retrieve per fetch. Use `n = -1`
#'   or `n = Inf`
#'   to retrieve all pending records.  Some implementations may recognize other
#'   special values.
#' @param ... Other arguments passed on to methods.
#' @export
setMethod(
  "fetch",
  signature(res="AthenaResult", n="numeric"),
  def = function(res, n, block = 1000L, ...) {

    nms <- c()
    athena_type_convert <- list()

    cols <- .jcall(res@md, "I", "getColumnCount")

    for (i in 1:cols) {
      ct <- as.character(.jcall(res@md, "I", "getColumnType", i))
      athena_type_convert[[i]] <- .jdbc_converters[[ct]]
      nms <- c(nms, .jcall(res@md, "S", "getColumnLabel", i))
    }

    athena_type_convert <- set_names(athena_type_convert, nms)

    out <- callNextMethod(res = res, n = n, block = block, ...)

    for (nm in names(athena_type_convert)) {
      out[[nm]] <- athena_type_convert[[nm]](out[[nm]])
    }

    out

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

    res <- fetch(r, -1, block = 1000L)

    class(res) <- c("tbl_df", "tbl", "data.frame")

    res

  }

)