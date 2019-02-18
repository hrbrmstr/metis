#' Simplified Athena JDBC connection helper
#'
#' Handles the up-front JDBC config
#'
#' @md
#' @param default_schema the name of the database schema to use when a schema is
#'        not explicitly specified in a query. You can still issue queries on other
#'        schemas by explicitly specifying the schema in the query.
#' @param provider JDBC auth provider (defaults to `com.simba.athena.amazonaws.auth.DefaultAWSCredentialsProviderChain`)
#' @param region AWS region (Ref: <http://docs.aws.amazon.com/general/latest/gr/rande.html#athena>)
#' @param s3_staging_dir the Amazon S3 location to which your query output is written.
#'        The JDBC driver then asks Athena to read the results and provide rows
#'        of data back to the user.
#' @param max_error_retries the maximum number of retries that the JDBC client
#'        attempts to make a request to Athena.
#' @param connection_timeout the maximum amount of time, in milliseconds, to
#'        make a successful connection to Athena before an attempt is terminated.
#' @param socket_timeout the maximum amount of time, in milliseconds, to wait
#'        for a socket in order to send data to Athena.
#' @param log_path local path of the Athena JDBC driver logs. If no log path is
#'        provided, then no log files are created.
#' @param log_level log level of the Athena JDBC driver logs. Use  names
#'        "OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE".
#' @param ... passed on to the driver
#' @export
#' @references [Connect with JDBC](https://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html);
#'     [Simba Athena JDBC Driver with SQL Connector Installation and Configuration Guide](https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC_2.0.6/docs/Simba+Athena+JDBC+Driver+Install+and+Configuration+Guide.pdf)
#' @examples \dontrun{
#' use_credentials("personal")
#'
#' athena_connect(
#'   default_schema = "sampledb",
#'   s3_staging_dir = "s3://accessible-bucket",
#'   log_path = "/tmp/athena.log",
#'   log_level = "DEBUG"
#' ) -> ath
#'
#' dbListTables(ath)
#'
#' dbGetQuery(ath, "SELECT * FROM sampledb.elb_logs LIMIT 1")
#'
#' }
athena_connect <- function(
  default_schema = "default",
  provider = "com.simba.athena.amazonaws.auth.DefaultAWSCredentialsProviderChain",
  region = c("us-east-1", "us-east-2", "us-west-2"),
  s3_staging_dir = Sys.getenv("AWS_S3_STAGING_DIR"),
  max_error_retries = 10,
  connection_timeout = 10000,
  socket_timeout = 10000,
  log_path = "",
  log_level = c("OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE"),
  ...
) {

  athena_jdbc <- Athena()

  region <- match.arg(region, c("us-east-1", "us-east-2", "us-west-2"))
  log_level <- match.arg(log_level, c("OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE"))

  dbConnect(
    athena_jdbc,
    Schema = default_schema,
    AwsRegion = region,
    S3OutputLocation = s3_staging_dir,
    MaxErrorRetry = max_error_retries,
    ConnectTimeout = connection_timeout,
    SocketTimeout = socket_timeout,
    LogPath = log_path,
    LogLevel = log_level,
    AwsCredentialsProviderClass= provider,
    ...
  ) -> con

}
