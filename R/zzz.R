.onLoad <- function(libname, pkgname) {
  rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
  rJava::.jaddClassPath(dir(file.path(getwd(), "inst/java"), full.names = TRUE))
  o <- getOption("java.parameters", "")
  if (!any(grepl("-Xrs", o))) {
    packageStartupMessage(
      "Did not find '-Xrs' in java.parameters option. Until rJava is updated, ",
      "please set this up in your/an Rprofile or at the start of scripts."
    )
  }
}
