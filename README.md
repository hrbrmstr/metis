
[`metis`](https://en.wikipedia.org/wiki/Metis_(mythology)) : Helpers for Accessing and Querying Amazon Athena

Including a lightweight RJDBC shim.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Winged_goddess_Louvre_F32.jpg/300px-Winged_goddess_Louvre_F32.jpg)

THIS IS SUPER ALPHA QUALITY. NOTHING TO SEE HERE. MOVE ALONG.

The goal will be to get around enough of the "gotchas" that are preventing raw RJDBC Athena connecitons from "just working" with `dplyr` v0.6.0+ and also get around the [`fetchSize` problem](https://www.reddit.com/r/aws/comments/6aq22b/fetchsize_limit/) without having to not use `dbGetQuery()`.

It will also support more than the vanilla id/secret auth mechism (it currently support the default basic auth and temp token auth, the latter via environment variables).

This package includes the `AthenaJDBC41-1.1.0.jar` JAR file out of convenience but that will likely move to a separate package as this gets closer to prime time.

See the **Usage** section for an example.

The following functions are implemented:

-   `athena_connect`: Make a JDBC connection to Athena (this returns an `AthenaConnection` object which is a super-class of it's RJDBC vanilla counterpart)
-   `read_credentials`: Use Credentials from .aws/credentials File
-   `use_credentials`: Use Credentials from .aws/credentials File
-   `Athena`: AthenaJDBC\`
-   `AthenaConnection-class`: AthenaJDBC
-   `AthenaDriver-class`: AthenaJDBC
-   `AthenaResult-class`: AthenaJDBC
-   `dbConnect-method`: AthenaJDBC
-   `dbGetQuery-method`: AthenaJDBC
-   `dbSendQuery-method`: AthenaJDBC

### Installation

``` r
devtools::install_github("hrbrmstr/metis")
```

### Usage

``` r
library(metis)
library(tidyverse)

# current verison
packageVersion("metis")
```

    ## [1] '0.1.0'

``` r
use_credentials("personal")

ath <- athena_connect(default_schema = "sampledb", 
                      s3_staging_dir = "s3://accessible-bucket",
                      log_path = "/tmp/athena.log",
                      log_level = "DEBUG")

dbListTables(ath)
```

    ## [1] "elb_logs"

``` r
dbGetQuery(ath, "SELECT * FROM sampledb.elb_logs LIMIT 10") %>% 
  type_convert() %>% 
  glimpse()
```

    ## Observations: 10
    ## Variables: 16
    ## $ timestamp             <dttm> 2014-09-26 23:00:27, 2014-09-26 23:00:40, 2014-09-26 23:00:57, 2014-09-26 23:01:10, ...
    ## $ elbname               <chr> "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo", "lb-demo...
    ## $ requestip             <chr> "250.244.91.129", "245.151.134.252", "250.144.139.199", "242.201.196.167", "253.206.1...
    ## $ requestport           <dbl> 30339, 30339, 30339, 30339, 30339, 30339, 30339, 30339, 30339, 30339
    ## $ backendip             <chr> "249.70.230.218", "240.86.17.179", "240.204.230.249", "254.88.26.13", "245.227.117.51...
    ## $ backendport           <dbl> 8000, 80, 8888, 8899, 8888, 8888, 8888, 8888, 8888, 8888
    ## $ requestprocessingtime <dbl> 0.000082, 0.000093, 0.000094, 0.000101, 0.000092, 0.000091, 0.000093, 0.000089, 0.000...
    ## $ backendprocessingtime <dbl> 0.047690, 0.047722, 0.039022, 0.046465, 0.046841, 0.042139, 0.040092, 0.048087, 0.039...
    ## $ clientresponsetime    <dbl> 7.2e-05, 5.1e-05, 6.4e-05, 6.4e-05, 4.9e-05, 4.7e-05, 5.1e-05, 7.4e-05, 5.4e-05, 5.4e-05
    ## $ elbresponsecode       <int> 200, 200, 200, 200, 200, 200, 200, 200, 200, 200
    ## $ backendresponsecode   <int> 200, 200, 404, 400, 500, 200, 200, 200, 200, 200
    ## $ receivedbytes         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ sentbytes             <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    ## $ requestverb           <chr> "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET", "GET"
    ## $ url                   <chr> "http://www.abcxyz.com:80/jobbrowser/?format=json&state=running&user=15llx5s", "http:...
    ## $ protocol              <chr> "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "HTTP/1.1", "...
