.aws_bin <- function() {
  unname(Sys.which('aws'))
}

.athenacli <- function(...) {

  args <- c("athena")

  in_args <- list(...)
  if (length(in_args) == 0) in_args <- "help"

  args <- c(args, unlist(in_args, use.names=FALSE))

  res <- sys::exec_internal(.aws_bin(), args = args, error = FALSE)

  if (length(res$stdout) > 0) {

    out <- rawToChar(res$stdout)

    if ("help" %in% args) cat(out, sep="")

    invisible(out)

  }

}
