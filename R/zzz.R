.onLoad <- function(libname, pkgname) {
  init_colortheme(env = colortheme_registry(), pkgname = pkgname)
  invisible(NULL)
}
