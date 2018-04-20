
# `metis`

Helpers for Accessing and Querying Amazon Athena

Including a lightweight RJDBC shim.

In Greek mythology, Metis was Athena’s “helper”.

## Description

Still fairly beta-quality level but getting there.

The goal will be to get around enough of the “gotchas” that are
preventing raw RJDBC Athena connections from “just working” with `dplyr`
v0.6.0+ and also get around the [`fetchSize`
problem](https://www.reddit.com/r/aws/comments/6aq22b/fetchsize_limit/)
without having to not use `dbGetQuery()`.

The `AthenaJDBC42_2.0.2.jar` JAR file is included out of convenience but
that will likely move to a separate package as this gets closer to prime
time if this goes on CRAN.

NOTE that the updated driver *REQUIRES JDK 1.8+*.

See the **Usage** section for an example.

## What’s Inside The Tin?

The following functions are implemented:

Easy-interface connection helper:

  - `athena_connect` Make a JDBC connection to Athena

Custom JDBC Classes:

  - `Athena`: AthenaJDBC (make a new Athena con obj)
  - `AthenaConnection-class`: AthenaJDBC
  - `AthenaDriver-class`: AthenaJDBC
  - `AthenaResult-class`: AthenaJDBC

Custom JDBC Class Methods:

  - `dbConnect-method`: AthenaJDBC
  - `dbExistsTable-method`: AthenaJDBC
  - `dbGetQuery-method`: AthenaJDBC
  - `dbListFields-method`: AthenaJDBC
  - `dbListTables-method`: AthenaJDBC
  - `dbReadTable-method`: AthenaJDBC
  - `dbSendQuery-method`: AthenaJDBC

Pulled in from other `cloudyr` pkgs:

  - `read_credentials`: Use Credentials from .aws/credentials File
  - `use_credentials`: Use Credentials from .aws/credentials File

## Installation

``` r
devtools::install_github("hrbrmstr/metis")
```

## Usage

``` r
library(metis)
library(tidyverse)

# current verison
packageVersion("metis")
```

    ## [1] '0.2.0'

``` r
use_credentials("default")

athena_connect(
  default_schema = "sampledb", 
  s3_staging_dir = "s3://accessible-bucket",
  log_path = "/tmp/athena.log",
  log_level = "DEBUG"
) -> ath

dbListTables(ath, schema="sampledb")
```

    ## [1] "elb_logs"

``` r
dbExistsTable(ath, "elb_logs", schema="sampledb")
```

    ## [1] TRUE

``` r
dbListFields(ath, "elb_logs", "sampledb")
```

    ##  [1] "timestamp"             "elbname"               "requestip"             "requestport"          
    ##  [5] "backendip"             "backendport"           "requestprocessingtime" "backendprocessingtime"
    ##  [9] "clientresponsetime"    "elbresponsecode"       "backendresponsecode"   "receivedbytes"        
    ## [13] "sentbytes"             "requestverb"           "url"                   "protocol"

``` r
dbGetQuery(ath, "SELECT * FROM sampledb.elb_logs LIMIT 10") %>% 
  type_convert() %>% 
  glimpse()
```

    ## Observations: 10
    ## Variables: 16
    ## $ timestamp             <dttm> 2014-09-30 00:00:25, 2014-09-30 00:00:57, 2014-09-30 00:01:06, 2014-09-30 00:01:29, ...
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo...
    ## $ requestip             <chr> "246.247.182.239", "250.128.76.75", "243.157.244.21", "255.172.234.242", "245.27.105....
    ## $ requestport           <dbl> 33998, 33998, 33998, 33998, 33998, 33998, 33998, 14346, 33998, 33998
    ## $ backendip             <chr> "251.173.42.143", "254.201.134.52", "240.175.197.76", "255.212.79.68", "250.102.227.5...
    ## $ backendport           <dbl> 8888, 8888, 8888, 8888, 8888, 8888, 8888, 8000, 8888, 8888
    ## $ requestprocessingtime <dbl> 0.000091, 0.000092, 0.000105, 0.000091, 0.000091, 0.000091, 0.000090, 0.000077, 0.000...
    ## $ backendprocessingtime <dbl> 0.048114, 0.055741, 0.008005, 0.037602, 0.039396, 0.053371, 0.040238, 0.192458, 0.027...
    ## $ clientresponsetime    <dbl> 6.2e-05, 5.0e-05, 4.8e-05, 6.1e-05, 4.7e-05, 6.2e-05, 5.5e-05, 8.3e-05, 5.7e-05, 8.5e-05
    ## $ elbresponsecode       <int> 200, 200, 302, 200, 200, 200, 200, 500, 200, 200
    ## $ backendresponsecode   <int> 404, 200, 200, 200, 200, 200, 400, 500, 200, 200
    ## $ receivedbytes         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <dbl> 2, 2, 0, 2, 2, 2, 2, 28098, 2, 2
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/jobbrowser/?format=json&state=running&user=l29ezwd", "http:...
    ## $ protocol              <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "...

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
