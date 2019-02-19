
[![Travis-CI Build Status](https://travis-ci.org/hrbrmstr/metis.svg?branch=master)](https://travis-ci.org/hrbrmstr/metis) 
[![Coverage Status](https://codecov.io/gh/hrbrmstr/metis/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/metis
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/metis)](https://cran.r-project.org/package=metis)

# metis

Access and Query Amazon Athena via DBI/JDBC

## Description

In Greek mythology, Metis was Athena’s “helper” so…

Methods are provided to connect to ‘Amazon’ ‘Athena’, lookup
schemas/tables, perform queries and retrieve query results via the
included JDBC DBI driver.

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
devtools::install_git("https://git.sr.ht/~hrbrmstr/metis")
# OR
devtools::install_gitlab("hrbrmstr/metis")
# OR
devtools::install_github("hrbrmstr/metis")
```

## Usage

``` r
library(metis)

# current verison
packageVersion("metis")
```

    ## [1] '0.3.0'

``` r
library(rJava)
library(RJDBC)
library(metis)
library(magrittr) # for piping b/c I'm addicted
```

``` r
dbConnect(
  metis::Athena(),
  Schema = "sampledb",
  AwsCredentialsProviderClass = "com.simba.athena.amazonaws.auth.PropertiesFileCredentialsProvider",
  AwsCredentialsProviderArguments = path.expand("~/.aws/athenaCredentials.props")
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
  dplyr::glimpse()
```

    ## Observations: 10
    ## Variables: 16
    ## $ timestamp             <chr> "2014-09-27T00:00:25.424956Z", "2014-09-27T00:00:56.439218Z", "2014-09-27T00:01:27.4417…
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo",…
    ## $ requestip             <chr> "241.230.198.83", "252.26.60.51", "250.244.20.109", "247.59.58.167", "254.64.224.54", "…
    ## $ requestport           <int> 27026, 27026, 27026, 27026, 27026, 27026, 27026, 27026, 27026, 27026
    ## $ backendip             <chr> "251.192.40.76", "249.89.116.3", "251.111.156.171", "251.139.91.156", "251.111.156.171"…
    ## $ backendport           <int> 443, 8888, 8888, 8888, 8000, 8888, 8888, 8888, 8888, 8888
    ## $ requestprocessingtime <dbl> 9.1e-05, 9.4e-05, 8.4e-05, 9.7e-05, 9.1e-05, 9.3e-05, 9.4e-05, 8.3e-05, 9.0e-05, 9.0e-05
    ## $ backendprocessingtime <dbl> 0.046598, 0.038973, 0.047054, 0.039845, 0.061461, 0.037791, 0.047035, 0.048792, 0.04572…
    ## $ clientresponsetime    <dbl> 4.9e-05, 4.7e-05, 4.9e-05, 4.9e-05, 4.0e-05, 7.7e-05, 7.5e-05, 7.3e-05, 4.0e-05, 6.7e-05
    ## $ elbresponsecode       <chr> "200", "200", "200", "200", "200", "200", "200", "200", "200", "200"
    ## $ backendresponsecode   <chr> "200", "200", "200", "200", "200", "400", "400", "200", "200", "200"
    ## $ receivedbytes         <S3: integer64> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <S3: integer64> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/jobbrowser/?format=json&state=running&user=20g578y", "http://…
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
  dplyr::glimpse()
```

    ## Observations: 1
    ## Variables: 13
    ## $ achar     <chr> "chr "
    ## $ avarchr   <chr> "varchr"
    ## $ tsday     <date> 2014-09-29
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

``` r
cloc::cloc_pkg_md()
```

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| R    |        8 | 0.89 | 250 | 0.83 |          83 | 0.72 |      194 | 0.79 |
| Rmd  |        1 | 0.11 |  50 | 0.17 |          32 | 0.28 |       53 | 0.21 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
