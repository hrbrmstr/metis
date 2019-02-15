0.3.0
=========

- Added `sql_translate_env.AthenaConnection()`
- Handles Athena JDBC column types!

0.2.0
=========

- Updated authentication provider to be `com.amazonaws.athena.jdbc.shaded.com.amazonaws.auth.DefaultAWSCredentialsProviderChain` (via @dabdine)
- Now supports additional DBI/RJDBC methods including: `dbExistsTable()`,
  `dbListFields()`, `dbListTables()`, `dbReadTable()`
- More documentation
- Added code of conduct

0.1.0 
=========

- Using the `cloudyr` `aws.signature` package vs DIY 