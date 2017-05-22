
[`metis`](https://en.wikipedia.org/wiki/Metis_(mythology)) : Helpers for Accessing and Querying Amazon Athena

Including a lightweight RJDBC shim.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Winged_goddess_Louvre_F32.jpg/300px-Winged_goddess_Louvre_F32.jpg)

THIS IS SUPER ALPHA QUALITY. NOTHING TO SEE HERE. MOVE ALONG.

The goal will be to get around enough of the "gotchas" that are preventing raw RJDBC Athena connecitons from "just working" with `dplyr` v0.6.0+ and also get around the [`fetchSize` problem](https://www.reddit.com/r/aws/comments/6aq22b/fetchsize_limit/) without having to not use `dbGetQuery()`.

It will also support more than the vanilla id/secret auth mechism (it currently support the default basic auth and temp token auth, the latter via environment variables).

This package includes the `AthenaJDBC41-1.0.1.jar` JAR file out of convenience but that will likely move to a separate package as this gets closer to prime time.

See the **Usage** section for an example.

The following functions are implemented:

-   `athena_connect`: Make a JDBC connection to Athena (this returns an `AthenaConnection` object which is a super-class of it's RJDBC vanilla counterpart)
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
library(dplyr)

# current verison
packageVersion("metis")
```

    ## [1] '0.1.0'

``` r
ath <- athena_connect("your_schema_name")

res <- dbGetQuery(ath, "
SELECT format_datetime(timestamp, 'yyyy-MM-dd HH:00:00') timestamp,
        port as field, count(port) cnt_field FROM your_schema_name.your_table_name
        WHERE CONTAINS(ARRAY['201705'], date)
        AND port IN (445, 139, 3389)
        AND timestamp > date '2017-05-01'
        AND timestamp <= date '2017-05-22'
GROUP BY format_datetime(timestamp, 'yyyy-MM-dd HH:00:00'), port LIMIT 1000000
")
```
