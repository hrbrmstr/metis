context("Driver & queries work")

drv <- metis::Athena()

expect_is(drv, "AthenaDriver")

skip_on_cran()https://github.com/hrbrmstr/metis/blob/master/tests/testthat/test-metis.R#L3-L15

if (identical(Sys.getenv("TRAVIS"), "true")) {

  metis::dbConnect(
    drv = drv,
    Schema = "sampledb",
    S3OutputLocation = "s3://aws-athena-query-results-569593279821-us-east-1"
  ) -> con

} else {

  metis::dbConnect(
    drv = drv,
    Schema = "sampledb",
    AwsCredentialsProviderClass = "com.simba.athena.amazonaws.auth.PropertiesFileCredentialsProvider",
    AwsCredentialsProviderArguments = path.expand("~/.aws/athenaCredentials.props"),
    S3OutputLocation = "s3://aws-athena-query-results-569593279821-us-east-1",
  ) -> con

}

expect_is(con, "AthenaConnection")

expect_equal(dbListTables(con, schema="sampledb"), "elb_logs")

expect_true(dbExistsTable(con, "elb_logs", schema="sampledb"))

expect_true("url" %in% dbListFields(con, "elb_logs", "sampledb"))

expect_is(
  dbGetQuery(con, "SELECT * FROM sampledb.elb_logs LIMIT 10"),
  "data.frame"
)
