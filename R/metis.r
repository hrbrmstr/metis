#' Make a JDBC connection to Athena
#'
#' Handles the up-front JDBC config
#'
#' @md
#' @param default_schema default schema (you'll still need to fully qualify non-default schema table names)
#' @param region AWS region (Ref: <http://docs.aws.amazon.com/general/latest/gr/rande.html#athena>)
#' @param s3_staging_dir the Amazon S3 location to which your query output is written. The JDBC driver then asks Athena to read the results and provide rows of data back to the user.
#' @param max_error_retries the maximum number of retries that the JDBC client attempts to make a request to Athena.
#' @param connection_timeout the maximum amount of time, in milliseconds, to make a successful connection to Athena before an attempt is terminated.
#' @param socket_timeout the maximum amount of time, in milliseconds, to wait for a socket in order to send data to Athena.
#' @param retry_base_delay minimum delay amount, in milliseconds, between retrying attempts to connect Athena.
#' @param retry_max_backoff_time maximum delay amount, in milliseconds, between retrying attempts to connect Athena.
#' @param log_path local path of the Athena JDBC driver logs. If no log path is provided, then no log files are created.
#' @param log_level log level of the Athena JDBC driver logs.
#' @export
#' @examples \dontrun{
#' use_credentials("personal")
#'
#' ath <- athena_connect(default_schema = "sampledb",
#'                       s3_staging_dir = "s3://accessible-bucket",
#'                       log_path = "/tmp/athena.log",
#'                       log_level = "DEBUG")
#'
#' dbListTables(ath)
#'
#' dbGetQuery(ath, "SELECT * FROM sampledb.elb_logs LIMIT 1")
#'
#' }
athena_connect <- function(default_schema = "default",
                           region = c("us-east-1", "us-east-2", "us-west-2"),
                           s3_staging_dir = Sys.getenv("AWS_S3_STAGING_DIR"),
                           max_error_retries = 10,
                           connection_timeout = 10000,
                           socket_timeout = 10000,
                           retry_base_delay = 100,
                           retry_max_backoff_time = 1000,
                           log_path = "",
                           log_level = c("INFO", "DEBUG", "WARN", "ERROR", "ALL", "OFF", "FATAL", "TRACE")) {

  athena_jdbc <- Athena()

  region <- match.arg(region, c("us-east-1", "us-east-2", "us-west-2"))
  log_level <- match.arg(log_level, c("INFO", "DEBUG", "WARN", "ERROR", "ALL", "OFF", "FATAL", "TRACE"))

  # if (!simple) {
  con <- dbConnect(athena_jdbc,
                   schema_name = default_schema,
                   region = region,
                   s3_staging_dir = s3_staging_dir,
                   max_error_retries = max_error_retries,
                   connection_timeout = connection_timeout,
                   socket_timeout = socket_timeout,
                   retry_base_delay = retry_base_delay,
                   retry_max_backoff_time = retry_max_backoff_time,
                   log_path = log_path,
                   log_level = log_level)
  # } else {
  #   con <- dbConnect(athena_jdbc, provider = NULL, schema_name = default_schema, region = region,
  #                    s3_staging_dir = s3_staging_dir, log_path = log_path, log_level = log_level)
  # }

  con

}
