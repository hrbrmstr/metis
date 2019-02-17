
# metis

Access and Query Amazon Athena via DBI/JDBC

## Description

In Greek mythology, Metis was Athena’s “helper” so methods are provided
to help you accessing and querying Amazon Athena via DBI/JDBC and/or
`dplyr`. \#’ Methods are provides to connect to ‘Amazon’ ‘Athena’,
lookup schemas/tables,

## IMPORTANT

Since R 3.5 (I don’t remember this happening in R 3.4.x) signals sent
from interrupting Athena JDBC calls crash the R interpreter. You need to
set the `-Xrs` option to avoid signals being passed on to the JVM owner.
That has to be done *before* `rJava` is loaded so you either need to
remember to put it at the top of all scripts *or* stick this in your
local `~/.Rprofile` and/or sitewide `Rprofile`:

``` r
if (!grepl("-Xrs", getOption("java.parameters", ""))) {
  options(
    "java.parameters" = c(getOption("java.parameters", default = NULL), "-Xrs")
  )
}
```

## What’s Inside The Tin?

The following functions are implemented:

Easy-interface connection helper:

  - `athena_connect` Simplified Athena JDBC connection helper

Custom JDBC Classes:

  - `Athena`: AthenaJDBC (make a new Athena con obj)
  - `AthenaConnection-class`: AthenaJDBC
  - `AthenaDriver-class`: AthenaJDBC
  - `AthenaResult-class`: AthenaJDBC

Custom JDBC Class Methods:

  - `dbConnect-method`
  - `dbExistsTable-method`
  - `dbGetQuery-method`
  - `dbListFields-method`
  - `dbListTables-method`
  - `dbReadTable-method`
  - `dbSendQuery-method`

Pulled in from other `cloudyr` pkgs:

  - `read_credentials`: Use Credentials from .aws/credentials File
  - `use_credentials`: Use Credentials from .aws/credentials File

## Installation

``` r
devtools::install_git("https://git.sr.ht/~hrbrmstr/metis-lite")
# OR
devtools::install_gitlab("hrbrmstr/metis-lite")
# OR
devtools::install_github("hrbrmstr/metis-lite")
```

## Usage

``` r
library(metis.lite)

# current verison
packageVersion("metis.lite")
```

    ## [1] '0.3.0'

``` r
library(rJava)
library(RJDBC)
library(metis.lite)
library(magrittr)
library(dbplyr)
library(dplyr)

dbConnect(
  drv = metis.lite::Athena(),
  schema_name = "sampledb",
  provider = "com.simba.athena.amazonaws.auth.PropertiesFileCredentialsProvider",
  AwsCredentialsProviderArguments = path.expand("~/.aws/athenaCredentials.props"),
  s3_staging_dir = "s3://aws-athena-query-results-569593279821-us-east-1",
) -> con

dbListTables(con, schema="sampledb")
```

    ## [1] "elb_logs"

``` r
dbExistsTable(con, "elb_logs", schema="sampledb")
```

    ## [1] TRUE

``` r
dbListFields(con, "elb_logs", "sampledb")
```

    ##  [1] "timestamp"             "elbname"               "requestip"             "requestport"          
    ##  [5] "backendip"             "backendport"           "requestprocessingtime" "backendprocessingtime"
    ##  [9] "clientresponsetime"    "elbresponsecode"       "backendresponsecode"   "receivedbytes"        
    ## [13] "sentbytes"             "requestverb"           "url"                   "protocol"

``` r
dbGetQuery(con, "SELECT * FROM sampledb.elb_logs LIMIT 10") %>% 
  glimpse()
```

    ## Observations: 10
    ## Variables: 16
    ## $ timestamp             <chr> "2014-09-29T18:18:51.826955Z", "2014-09-29T18:18:51.920462Z", "2014-09-29T18:18:52.2725…
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo",…
    ## $ requestip             <chr> "255.48.150.122", "249.213.227.93", "245.108.120.229", "241.112.203.216", "241.43.107.2…
    ## $ requestport           <int> 62096, 62096, 62096, 62096, 56454, 33254, 18918, 64352, 1651, 56454
    ## $ backendip             <chr> "244.238.214.120", "248.99.214.228", "243.3.190.175", "246.235.181.255", "241.112.203.2…
    ## $ backendport           <int> 8888, 8888, 8888, 8888, 8888, 8888, 8888, 8888, 8888, 8888
    ## $ requestprocessingtime <dbl> 9.0e-05, 9.7e-05, 8.7e-05, 9.4e-05, 7.6e-05, 8.3e-05, 6.3e-05, 5.4e-05, 8.2e-05, 8.7e-05
    ## $ backendprocessingtime <dbl> 0.007410, 0.256533, 0.442659, 0.016772, 0.035036, 0.029892, 0.034148, 0.014858, 0.01518…
    ## $ clientresponsetime    <dbl> 0.000055, 0.000075, 0.000131, 0.000078, 0.000057, 0.000043, 0.000033, 0.000043, 0.00007…
    ## $ elbresponsecode       <chr> "302", "302", "200", "200", "200", "200", "200", "200", "200", "200"
    ## $ backendresponsecode   <chr> "200", "200", "200", "200", "200", "200", "200", "200", "200", "200"
    ## $ receivedbytes         <S3: integer64> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <S3: integer64> 0, 0, 58402, 152213, 20766, 32370, 3408, 3884, 84245, 3831
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/", "http://www.abcxyz.com:80/accounts/login/?next=/", "http:/…
    ## $ protocol              <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HT…

### Check types

``` r
dbGetQuery(con, "
SELECT
  CAST('chr' AS CHAR(4)) achar,
  CAST('varchr' AS VARCHAR) avarchr,
  CAST(SUBSTR(timestamp, 1, 10) AS DATE) AS tsday,
  CAST(100.1 AS DOUBLE) AS justadbl,
  CAST(127 AS TINYINT) AS asmallint,
  CAST(100 AS INTEGER) AS justanint,
  CAST(100000000000000000 AS BIGINT) AS abigint,
  CAST(('GET' = 'GET') AS BOOLEAN) AS is_get,
  ARRAY[1, 2, 3] AS arr1,
  ARRAY['1', '2, 3', '4'] AS arr2,
  MAP(ARRAY['foo', 'bar'], ARRAY[1, 2]) AS mp,
  CAST(ROW(1, 2.0) AS ROW(x BIGINT, y DOUBLE)) AS rw,
  CAST('{\"a\":1}' AS JSON) js
FROM elb_logs
LIMIT 1
") %>% 
  glimpse()
```

    ## Observations: 1
    ## Variables: 13
    ## $ achar     <chr> "chr "
    ## $ avarchr   <chr> "varchr"
    ## $ tsday     <date> 2014-09-26
    ## $ justadbl  <dbl> 100.1
    ## $ asmallint <int> 127
    ## $ justanint <int> 100
    ## $ abigint   <S3: integer64> 100000000000000000
    ## $ is_get    <lgl> TRUE
    ## $ arr1      <chr> "1, 2, 3"
    ## $ arr2      <chr> "1, 2, 3, 4"
    ## $ mp        <chr> "{bar=2, foo=1}"
    ## $ rw        <chr> "{x=1, y=2.0}"
    ## $ js        <chr> "\"{\\\"a\\\":1}\""

#### dplyr

``` r
tbl(con, sql("
SELECT
  CAST('chr' AS CHAR(4)) achar,
  CAST('varchr' AS VARCHAR) avarchr,
  CAST(SUBSTR(timestamp, 1, 10) AS DATE) AS tsday,
  CAST(100.1 AS DOUBLE) AS justadbl,
  CAST(127 AS TINYINT) AS asmallint,
  CAST(100 AS INTEGER) AS justanint,
  CAST(100000000000000000 AS BIGINT) AS abigint,
  CAST(('GET' = 'GET') AS BOOLEAN) AS is_get,
  ARRAY[1, 2, 3] AS arr,
  ARRAY['1', '2, 3', '4'] AS arr,
  MAP(ARRAY['foo', 'bar'], ARRAY[1, 2]) AS mp,
  CAST(ROW(1, 2.0) AS ROW(x BIGINT, y DOUBLE)) AS rw,
  CAST('{\"a\":1}' AS JSON) js
FROM elb_logs
LIMIT 1
")) %>% 
  glimpse()
```

    ## Observations: ??
    ## Variables: 13
    ## Database: AthenaConnection
    ## $ achar     <chr> "chr "
    ## $ avarchr   <chr> "varchr"
    ## $ tsday     <date> 2014-09-27
    ## $ justadbl  <dbl> 100.1
    ## $ asmallint <int> 127
    ## $ justanint <int> 100
    ## $ abigint   <S3: integer64> 100000000000000000
    ## $ is_get    <lgl> TRUE
    ## $ arr       <chr> "1, 2, 3"
    ## $ arr       <chr> "1, 2, 3, 4"
    ## $ mp        <chr> "{bar=2, foo=1}"
    ## $ rw        <chr> "{x=1, y=2.0}"
    ## $ js        <chr> "\"{\\\"a\\\":1}\""

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
