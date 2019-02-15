
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

## IMPORTANT

Since R 3.5 (I don't remember this happening in R 3.4.x) signals sent from interrupting Athena JDBC calls crash the R interpreter. You need to set the `-Xrs` option to avoid signals being passed on to the JVM owner. That has to be done _before_ `rJava` is loaded so you either need to remember to put it at the top of all scripts _or_ stick this in your local `~/.Rprofile` and/or sitewide `Rprofile`:

```r
if (!grepl("-Xrs", getOption("java.parameters", ""))) {
  options(
    "java.parameters" = paste0(
      c(getOption("java.parameters", default = NULL), "-Xrs"), 
      collapse=" "
    )
  )
}
```

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

    ## [1] '0.3.0'

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
    ## $ timestamp             <dttm> 2014-09-30 01:28:17, 2014-09-30 00:01:30, 2014-09-30 00:01:30, 2014-09-30 00:01:30, ...
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo...
    ## $ requestip             <chr> "246.140.190.136", "240.109.129.138", "242.251.232.153", "253.227.207.81", "253.227.2...
    ## $ requestport           <dbl> 63777, 22705, 22705, 22705, 23282, 24178, 22916, 23807, 22916, 21443
    ## $ backendip             <chr> "250.193.168.100", "251.103.130.45", "243.140.114.254", "243.82.95.243", "246.129.102...
    ## $ backendport           <dbl> 8888, 8888, 8888, 8888, 8899, 8888, 8888, 8888, 8888, 8888
    ## $ requestprocessingtime <dbl> 7.2e-05, 6.9e-05, 8.7e-05, 9.7e-05, 8.1e-05, 4.6e-05, 4.3e-05, 5.3e-05, 5.5e-05, 4.4e-05
    ## $ backendprocessingtime <dbl> 0.379241, 0.007541, 0.187126, 0.413337, 0.037030, 0.050222, 0.043706, 0.045953, 0.015...
    ## $ clientresponsetime    <dbl> 8.0e-05, 4.3e-05, 7.5e-05, 8.7e-05, 4.5e-05, 3.3e-05, 3.3e-05, 6.9e-05, 8.5e-05, 4.9e-05
    ## $ elbresponsecode       <int> 200, 302, 302, 200, 200, 200, 200, 200, 200, 200
    ## $ backendresponsecode   <int> 200, 200, 200, 400, 200, 200, 200, 404, 200, 200
    ## $ receivedbytes         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <dbl> 58402, 0, 0, 58402, 32370, 20766, 3408, 152213, 84245, 3884
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/", "http://www.abcxyz.com:80/", "http://www.abcxyz.com:80/a...
    ## $ protocol              <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "...

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
