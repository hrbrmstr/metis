#' Make a JDBC connection to Athena
#'
#' Handles the up-front JDBC config
#'
#' For all connection types it is expected that you have the following environment variables
#' defined (a good place is `~/.Renviron`):
#'
#' - `AWS_S3_STAGING_DIR`: the name of the S3 bucket where Athena can write stuff
#' - `AWS_PROFILE`: the AWS profile ID in `~/.aws/credentials` (defaults to `default` if not present)
#'
#' For `simple` == `FALSE` the expectation is that you're working with a managed
#' `~/.aws/credentials` file.
#'
#' There's a high likelihood of params changing in the near term as I work this out, but I'm
#' not very keen on parameter-izing things like id/secret.
#'
#' @md
#' @param default_schema def schema
#' @param region AWS region (Ref: <http://docs.aws.amazon.com/general/latest/gr/rande.html#athena>)
#' @param simple pickup id/secret only or use temp token? (this will become more robust)
#' @export
athena_connect <- function(default_schema = "default", region = "us-east-1", simple=FALSE) {

  athena_jdbc <- Athena()

  aws_config <- ini::read.ini(path.expand("~/.aws/credentials"))
  aws_profile <- aws_config[Sys.getenv("AWS_PROFILE", "default")][[1]]

  Sys.unsetenv("AWS_ACCESS_KEY_ID")
  Sys.unsetenv("AWS_SECRET_ACCESS_KEY")

  Sys.setenv(AWS_ACCESS_KEY_ID = aws_profile$aws_access_key_id)
  Sys.setenv(AWS_SECRET_ACCESS_KEY = aws_profile$aws_secret_access_key)

  con <- NULL

  if (!simple) {

    Sys.unsetenv("AWS_SESSION_TOKEN")
    Sys.setenv(AWS_SESSION_TOKEN = aws_profile$aws_session_token)

    con <- dbConnect(athena_jdbc, schema_name = default_schema, region = region)

  } else {

    con <- dbConnect(athena_jdbc, provider = NULL, schema_name = default_schema, region = region)

  }

  con

}
