list_query_executions <- function(max_items=10, starting_token=NULL, page_size=NULL) {


  args <- c("list-query-executions", sprintf("--max-items=%s", as.integer(max_items)))

  if (!is.null(starting_token)) args <- c(args, sprintf("--starting-token=%s", starting_token))
  if (!is.null(page_size)) args <- c(args, sprintf("--page-size=%s", as.integer(page_size)))

  res <- .athenacli(args)

  jsonlite::fromJSON()

}