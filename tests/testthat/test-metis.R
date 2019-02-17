context("Driver & queries work")

skip_on_cran()

drv <- metis::Athena()

expect_is(drv, "AthenaDriver")

dbConnect(
  drv = drv,
  schema_name = "sampledb",
  provider = "com.simba.athena.amazonaws.auth.PropertiesFileCredentialsProvider",
  AwsCredentialsProviderArguments = path.expand("~/.aws/athenaCredentials.props"),
  s3_staging_dir = "s3://aws-athena-query-results-569593279821-us-east-1",
) -> con

expect_is(con, "AthenaConnection")

expect_equal(dbListTables(con, schema="sampledb"), "elb_logs")

expect_true(dbExistsTable(con, "elb_logs", schema="sampledb"))

expect_true("url" %in% dbListFields(con, "elb_logs", "sampledb"))

expect_is(
  dbGetQuery(con, "SELECT * FROM sampledb.elb_logs LIMIT 10"),
  "data.frame"
)