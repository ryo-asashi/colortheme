.onLoad <- function(libname, pkgname) {
  init_colorthemes(env = colortheme_registry(), pkgname = pkgname)
  invisible(NULL)
}
