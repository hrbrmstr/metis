
![](https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Winged_goddess_Louvre_F32.jpg/300px-Winged_goddess_Louvre_F32.jpg)

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

The `AthenaJDBC41-1.1.0.jar` JAR file is included out of convenience but
that will likely move to a separate package as this gets closer to prime
time if this goes on CRAN.

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
    ## $ timestamp             <dttm> 2014-09-30 01:03:00, 2014-09-30 01:03:01, 2014-09-30 01:03:01, 2014-09-30 01:03:01, ...
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo...
    ## $ requestip             <chr> "253.90.22.60", "253.51.141.83", "245.59.222.144", "241.35.85.250", "246.245.70.48", ...
    ## $ requestport           <dbl> 4095, 14668, 29796, 38607, 32750, 10182, 64948, 51279, 13331, 2700
    ## $ backendip             <chr> "250.133.18.39", "248.214.120.18", "250.38.70.52", "249.45.101.192", "249.28.120.9", ...
    ## $ backendport           <dbl> 8888, 443, 8899, 8888, 8888, 8888, 8888, 8888, 8888, 8000
    ## $ requestprocessingtime <dbl> 7.3e-05, 8.9e-05, 4.5e-05, 4.3e-05, 7.6e-05, 7.3e-05, 7.7e-05, 4.6e-05, 4.9e-05, 5.3e-05
    ## $ backendprocessingtime <dbl> 0.561864, 0.021517, 0.019530, 0.018937, 0.022727, 0.390384, 0.017017, 0.016437, 0.019...
    ## $ clientresponsetime    <dbl> 9.0e-05, 7.0e-05, 3.0e-05, 3.3e-05, 3.2e-05, 8.4e-05, 5.2e-05, 7.1e-05, 6.9e-05, 5.4e-05
    ## $ elbresponsecode       <int> 200, 304, 304, 304, 200, 200, 304, 304, 200, 304
    ## $ backendresponsecode   <int> 200, 200, 403, 200, 200, 400, 200, 200, 200, 200
    ## $ receivedbytes         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <dbl> 58402, 0, 0, 0, 152213, 58402, 0, 0, 152213, 0
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/", "http://www.abcxyz.com:80/static/css/hue3.css", "http://...
    ## $ protocol              <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "...

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
