.onLoad <- function(libname, pkgname) {
  rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
  rJava::.jpackage(pkgname, lib.loc = libname)
  rJava::.jaddClassPath(dir(file.path(getwd(), "inst/java"), full.names = TRUE))
}
