#' @rdname Athena
#' @keywords internal
#' @export
db_data_type.AthenaConnection <- function(con, fields, ...) {
  print("\n\n\ndb_data_type\n\n\n")
  data_type <- function(x) {
    switch(
      class(x)[1],
      integer64 = "BIGINT",
      logical = "BOOLEAN",
      integer = "INTEGER",
      numeric = "DOUBLE",
      factor =  "CHARACTER",
      character = "CHARACTER",
      Date = "DATE",
      POSIXct = "TIMESTAMP",
      stop("Can't map type ", paste(class(x), collapse = "/"),
           " to a supported database type.")
    )
  }
  vapply(fields, data_type, character(1))
}

#' @rdname Athena
#' @keywords internal
#' @export
sql_translate_env.AthenaConnection <- function(con) {

  x <- con

  dbplyr::sql_variant(

    scalar = dbplyr::sql_translator(
      .parent = dbplyr::base_scalar,
      `!=` = dbplyr::sql_infix("<>"),
      as.integer64 = function(x) dbplyr::build_sql("CAST(", x, "AS BIGINT)"),
      as.numeric = function(x) dbplyr::build_sql("CAST(", x, " AS DOUBLE)"),
      as.character = function(x) dbplyr::build_sql("CAST(", x, " AS CHARACTER)"),
      as.date = function(x) dbplyr::build_sql("CAST(", x, " AS DATE)"),
      as.Date = function(x) dbplyr::build_sql("CAST(", x, " AS DATE)"),
      as.POSIXct = function(x) dbplyr::build_sql("CAST(", x, " AS TIMESTAMP)"),
      as.posixct = function(x) dbplyr::build_sql("CAST(", x, " AS TIMESTAMP)"),
      as.logical = function(x) dbplyr::build_sql("CAST(", x, " AS BOOLEAN)"),
      date_part = function(x, y) dbplyr::build_sql("DATE_PART(", x, ",", y ,")"),
      grepl = function(x, y) dbplyr::build_sql("CONTAINS(", y, ", ", x, ")"),
      gsub = function(x, y, z) dbplyr::build_sql("REGEXP_REPLACE(", z, ", ", x, ",", y ,")"),
      trimws = function(x) dbplyr::build_sql("TRIM(both ' ' FROM ", x, ")"),
      cbrt = dbplyr::sql_prefix("CBRT", 1),
      degrees = dbplyr::sql_prefix("DEGREES", 1),
      e = dbplyr::sql_prefix("E", 0),
      row_number = dbplyr::sql_prefix("row_number", 0),
      lshift = dbplyr::sql_prefix("LSHIFT", 2),
      mod = dbplyr::sql_prefix("MOD", 2),
      age = dbplyr::sql_prefix("AGE", 1),
      negative = dbplyr::sql_prefix("NEGATIVE", 1),
      pi = dbplyr::sql_prefix("PI", 0),
      pow = dbplyr::sql_prefix("POW", 2),
      radians = dbplyr::sql_prefix("RADIANS", 1),
      rand = dbplyr::sql_prefix("RAND", 0),
      rshift = dbplyr::sql_prefix("RSHIFT", 2),
      trunc = dbplyr::sql_prefix("TRUNC", 2),
      contains = dbplyr::sql_prefix("CONTAINS", 2),
      convert_to = dbplyr::sql_prefix("CONVERT_TO", 2),
      convert_from = dbplyr::sql_prefix("CONVERT_FROM", 2),
      string_binary = dbplyr::sql_prefix("STRING_BINARY", 1),
      binary_string = dbplyr::sql_prefix("BINARY_STRING", 1),
      to_char = dbplyr::sql_prefix("TO_CHAR", 2),
      to_date = dbplyr::sql_prefix("TO_DATE", 2),
      to_number = dbplyr::sql_prefix("TO_NUMBER", 2),
      char_to_timestamp = dbplyr::sql_prefix("TO_TIMESTAMP", 2),
      double_to_timestamp = dbplyr::sql_prefix("TO_TIMESTAMP", 1),
      char_length = dbplyr::sql_prefix("CHAR_LENGTH", 1),
      flatten = dbplyr::sql_prefix("FLATTEN", 1),
      kvgen = dbplyr::sql_prefix("KVGEN", 1),
      repeated_count = dbplyr::sql_prefix("REPEATED_COUNT", 1),
      repeated_contains = dbplyr::sql_prefix("REPEATED_CONTAINS", 2),
      ilike = dbplyr::sql_prefix("ILIKE", 2),
      init_cap = dbplyr::sql_prefix("INIT_CAP", 1),
      length = dbplyr::sql_prefix("LENGTH", 1),
      lower = dbplyr::sql_prefix("LOWER", 1),
      tolower = dbplyr::sql_prefix("LOWER", 1),
      ltrim = dbplyr::sql_prefix("LTRIM", 2),
      nullif = dbplyr::sql_prefix("NULLIF", 2),
      position = function(x, y) dbplyr::build_sql("POSITION(", x, " IN ", y, ")"),
      regexp_replace = dbplyr::sql_prefix("REGEXP_REPLACE", 3),
      rtrim = dbplyr::sql_prefix("RTRIM", 2),
      rpad = dbplyr::sql_prefix("RPAD", 2),
      rpad_with = dbplyr::sql_prefix("RPAD", 3),
      lpad = dbplyr::sql_prefix("LPAD", 2),
      lpad_with = dbplyr::sql_prefix("LPAD", 3),
      strpos = dbplyr::sql_prefix("STRPOS", 2),
      substr = dbplyr::sql_prefix("SUBSTR", 3),
      trim = function(x, y, z) dbplyr::build_sql("TRIM(", x, " ", y, " FROM ", z, ")"),
      upper = dbplyr::sql_prefix("UPPER", 1),
      toupper = dbplyr::sql_prefix("UPPER", 1)
    ),

    aggregate = dbplyr::sql_translator(
      .parent = dbplyr::base_agg,
      n = function() dbplyr::sql("COUNT(*)"),
      cor = dbplyr::sql_prefix("CORR"),
      cov = dbplyr::sql_prefix("COVAR_SAMP"),
      sd =  dbplyr::sql_prefix("STDDEV_SAMP"),
      var = dbplyr::sql_prefix("VAR_SAMP"),
      n_distinct = function(x) {
        dbplyr::build_sql(dbplyr::sql("COUNT(DISTINCT "), x, dbplyr::sql(")"))
      }
    ),

    window = dbplyr::sql_translator(
      .parent = dbplyr::base_win,
      n = function() { dbplyr::win_over(dbplyr::sql("count(*)"),
                                        partition = dbplyr::win_current_group()) },
      cor = dbplyr::win_recycled("corr"),
      cov = dbplyr::win_recycled("covar_samp"),
      sd =  dbplyr::win_recycled("stddev_samp"),
      var = dbplyr::win_recycled("var_samp"),
      all = dbplyr::win_recycled("bool_and"),
      any = dbplyr::win_recycled("bool_or")
    )

  )

}