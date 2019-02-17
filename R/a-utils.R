set_names <- function (object = nm, nm) {
  names(object) <- nm
  object
}

as_logical <- function(x) {
  as.logical(as.integer(x))
}

as_date <- function(x) {
  as.Date(x, origin = "1970-01-01")
}

as_posixct <- function(x) {
  as.POSIXct(x, origin = "1970-01-01 00:00:00")
}
