#' List and Register Color Themes
#'
#' @description
#' \code{colorthemes()} returns a data frame listing available color themes in the registry.
#' \code{register_colortheme()} registers a custom color theme into the registry.
#'
#' @details
#' \code{colorthemes()} extracts metadata from the registry environment and structures it into a data frame, allowing users to discover themes by \code{name}, \code{source}, and \code{type} (with case-insensitive prefix matching).
#'
#' \code{register_colortheme()} takes a color vector, a color-generating function, or an existing \code{"colortheme"} object and registers it under a specified \code{name} and \code{source} (defaulting to \code{"custom/newtheme"}).
#' To keep the registry lightweight, the \code{kernel} argument supports lazy loading: pass a character vector or list of length 2 where the first element is an R expression returning a kernel (e.g., \code{"rainbow"}) and the second is the namespace (e.g., \code{"grDevices"}).
#'
#' @param name for \code{colorthemes()}, a character vector of theme names to match (case-insensitive prefix matching). For \code{register_colortheme()}, a single string for the new theme name.
#' @param source for \code{colorthemes()}, a character vector of sources to match (case-insensitive prefix matching). For \code{register_colortheme()}, a single string for the source name.
#' @param type a character string or vector specifying the theme type(s): \code{"sequential"}, \code{"diverging"}, or \code{"qualitative"}.
#' @param env an environment where color themes are registered. Defaults to the package registry (\code{getOption("colortheme.registry")}).
#' @param kernel a color vector, a palette function, a ramp function, a \code{"colortheme"} object, or a length-2 character vector/list for lazy evaluation.
#' @param kernel.args a list of arguments passed to the color kernel.
#' @param options a list of option values controlling the color theme's behavior.
#'
#' @returns
#' \itemize{
#'   \item \code{colorthemes()}: A data frame with columns \code{"name"}, \code{"source"}, and \code{"type"}.
#'   \item \code{register_colortheme()}: Invisibly returns the metadata of the previous theme that was overwritten (or \code{NULL} if none existed).
#' }
#'
#' @seealso \code{\link{colortheme}}
#'
#' @examples
#' # List all available themes
#' head(colorthemes())
#'
#' # Case-insensitive prefix matching
#' head(colorthemes(name = "hc"))
#'
#' # Register a custom theme
#' register_colortheme(
#'   kernel = c("#264653", "#2a9d8f", "#e9c46a", "#f4a261", "#e76f51"),
#'   name = "sand", source = "custom", type = "sequential"
#' )
#' colorthemes(name = "sand")
#' @name colorthemes
NULL


# local helpers

colortheme_env <- new.env(parent = emptyenv())


colortheme_registry <- function() {
  getOption("colortheme.registry", default = colortheme_env)
}


colortheme_defaults <- function(
    type = c("sequential", "diverging", "qualitative"), use.options = TRUE
) {
  type <- match.arg(type)
  fallback <- switch(
    type, sequential = "bluescale", diverging = "RdBu", qualitative = "HCL"
  )
  if (!use.options) return(fallback)
  getOption(paste0("colortheme.", type), default = fallback)
}


# exports

#' @rdname colorthemes
#' @export
colorthemes <- function(name = NULL, source = NULL, type = NULL, env = NULL) {
  env <- env %||% colortheme_registry()
  nst <- c("name", "source", "type")
  err <- data.frame(
    name = character(),
    source = character(),
    type = character(),
    stringsAsFactors = FALSE
  )
  lenv <- as.list(env)
  if (!is.null(name)) {
    orgs <- names(lenv)
    nms <- unique(unlist(lapply(name, function(nm) {
      orgs[startsWith(tolower(orgs), tolower(nm))]
    }), use.names = FALSE))
    lenv <- lenv[nms]
  }
  if (length(lenv) == 0L) return(err)
  collect <- function(x, source = NULL) {
    if (!is.null(source)) {
      nms <- names(x)
      srcs <- unique(unlist(lapply(source, function(src) {
        nms[startsWith(tolower(nms), tolower(src))]
      }), use.names = FALSE))
      x <- x[srcs]
    }
    if (!is.list(x) || length(x) == 0L)
      return(matrix(NA_character_, nrow = 3, ncol = 0))
    vapply(
      X = x,
      FUN = function(y) {
        if (is.list(y) && all(nst %in% names(y))) {
          z <- y[nst]
          if (all(vapply(z, is.character, logical(1L))) && all(lengths(z) == 1L))
            return(unlist(z, use.names = FALSE))
        }
        rep.int(NA_character_, 3L)
      },
      FUN.VALUE = character(3L)
    )
  }
  res <- lapply(lenv, collect, source = source)
  mat <- do.call(cbind, res)
  if (is.null(mat) || NCOL(mat) == 0L) return(err)
  res <- as.data.frame(t(mat), stringsAsFactors = FALSE)
  res <- stats::setNames(res, nst)
  res <- res[rowSums(is.na(res)) < 3L, , drop = FALSE]
  if (!is.null(type)) {
    type <- match.arg(
      type, c("sequential", "diverging", "qualitative"), several.ok = TRUE
    )
    res <- res[res$type %in% type, , drop = FALSE]
  }
  if (nrow(res) == 0L) return(err)
  res <- res[order(res$type, res$name, res$source), , drop = FALSE]
  rownames(res) <- NULL
  res
}


#' @rdname colorthemes
#' @export
register_colortheme <- function(
    kernel, kernel.args = list(), options = list(), name = "newtheme",
    source = "custom", type = NULL, env = NULL
) {
  env <- env %||% colortheme_registry()
  if (is_colortheme(kernel)) {
    args <- as.list(kernel)[c("kernel", "kernel.args", "options", "type")]
    args$name <- name %||% kernel$name
    args$source <- source %||% kernel$source
    args$env <- env
    return(do.call(register_colortheme, args))
  }
  lazy_load_kernel(kernel, args = kernel.args)
  if (!is.list(kernel.args))
    stop("'kernel.args' must be a list", call. = FALSE)
  if (!is.list(options))
    stop("'options' must be a list", call. = FALSE)
  if (!is.character(name) || length(name) != 1L)
    stop("'name' must be a character string of length 1", call. = FALSE)
  if (grepl("(/|_r$|@|\\?)", name))
    stop("'name' must not contain the reserved characters: '/', '_r', '@', or '?'", call. = FALSE)
  if (!is.character(source) || length(source) != 1L)
    stop("'source' must be a character string of length 1", call. = FALSE)
  type <- match.arg(type, c("sequential", "diverging", "qualitative"))
  new <- list(
    kernel = kernel, kernel.args = kernel.args,
    options = options, name = name, source = source, type = type
  )
  old <- env[[name]][[source]]
  env[[name]][[source]] <- new
  invisible(old)
}


# internal helpers to call

init_colorthemes <- function(
    pkgname = "colortheme", overwrite.options = FALSE,
    env = colortheme_registry(), clear.env = FALSE
) {
  set_colortheme_options(overwrite = overwrite.options)
  if (isTRUE(clear.env)) {
    rm(list = ls(envir = env, all.names = TRUE), envir = env)
  }
  register_themes_builtin(env = env, pkgname = pkgname)
  register_themes_grDevices(env = env)
  register_themes_viridisLite(env = env)
  register_themes_RColorBrewer(env = env)
  register_themes_khroma(env = env)
  invisible(env)
}


set_colortheme_options <- function(overwrite = FALSE) {
  ops <- list(
    colortheme.registry    = colortheme_env,
    colortheme.sequential  = colortheme_defaults("sequential", use.options = FALSE),
    colortheme.diverging   = colortheme_defaults("diverging", use.options = FALSE),
    colortheme.qualitative = colortheme_defaults("qualitative", use.options = FALSE)
  )
  if (!overwrite) {
    toset <- !(names(ops) %in% names(options()))
    ops <- ops[toset]
  }
  if (length(ops) > 0L) options(ops)
  invisible(ops)
}


register_themes_builtin <- function(env = colortheme_registry(), pkgname = "colortheme") {
  register_colortheme(
    name = "midr", source = pkgname, type = "diverging", env = env,
    kernel = c("#005AAD", "#688BC0", "#A8B8D6", "#D7DCE7", "#F1F1F1", "#E9D8DF",
               "#D9ABBF", "#C27098", "#A4136E"),
    kernel.args = list(mode = "ramp")
  )
  register_colortheme(
    name = "bluescale", source = pkgname, type = "sequential", env = env,
    kernel = c("#132B43", "#56B1F7"),
    kernel.args = list(mode = "ramp")
  )
  register_colortheme(
    name = "grayscale", source = pkgname, type = "sequential", env = env,
    kernel = c("#FEFEFE", "#0F0F0F"),
    kernel.args = list(mode = "ramp")
  )
  register_colortheme(
    name = "shap", source = pkgname, type = "sequential", env = env,
    kernel = c("#2C87E1", "#2A6BE9", "#774DCF", "#9C30BB", "#C60099", "#E7007E",
               "#F72A5A"),
    kernel.args = list(mode = "ramp")
  )
  register_colortheme(
    name = "HCL", source = pkgname, type = "qualitative", env = env,
    kernel = c(text = "hcl_palette", namespace = pkgname),
    kernel.args = list(direction = 1L, alpha = NULL, chroma = 100, luminance = 65)
  )
  register_colortheme(
    name = "bicolor", source = pkgname, type = "diverging", env = env,
    kernel = c(text = "function(x, first, second) ifelse(x <= 0.5, first, second)",
               namespace = "base"),
    kernel.args = list(first = "steelblue", second = "maroon")
  )
  register_colortheme(
    name = "highlight", source = pkgname, type = "qualitative", env = env,
    kernel = c(text = paste0("function(n, accent, base, which = 1L) {",
                             "x <- rep.int(base, n);",
                             "x[which] <- rep_len(accent, length(which));",
                             "x[seq_len(n)]}"), namespace = "base"),
    kernel.args = list(accent = "#A4136E", base = "gray80", which = 1L)
  )
  invisible(NULL)
}


register_themes_grDevices <- function(env = colortheme_registry()) {
  if (!requireNamespace("grDevices", quietly = TRUE)) return(invisible(NULL))

  hcl_types <- c(
    sequential  = "sequential",
    diverging   = "diverging",
    divergingx  = "diverging",
    qualitative = "qualitative"
  )
  for (pal_type in names(hcl_types)) {
    theme_type <- hcl_types[[pal_type]]
    for (x in grDevices::hcl.pals(type = pal_type)) {
      register_colortheme(
        name = x, source = "grDevices", type = theme_type, env = env,
        kernel = c(text = "hcl.colors", namespace = "grDevices"),
        kernel.args = list(palette = x, alpha = NULL, rev = FALSE),
        options = list(
          kernel.size = Inf,
          reverse.method = "kernel.args$rev <- !kernel.args$rev"
        )
      )
    }
  }

  for (x in grDevices::palette.pals()) {
    register_colortheme(
      name = x, source = "grDevices", type = "qualitative", env = env,
      kernel = c(text = "palette.colors", namespace = "grDevices"),
      kernel.args = list(palette = x, alpha = NULL, recycle = FALSE),
      options = list(kernel.size = switch(
        x, 8L, Paired = 12L, "Pastel 1" = 9L, "Set 1" = 9L, "Set 3" = 12L,
        "Tableau 10" = 10L, "Classic Tableau" = 10L, "Polychrome 36" = 36L,
        Alphabet = 26L
      ))
    )
  }
  invisible(NULL)
}


register_themes_viridisLite <- function(env = colortheme_registry()) {
  if (!requireNamespace("viridisLite", quietly = TRUE)) return(invisible(NULL))

  pals <- c("magma", "inferno", "plasma", "viridis", "cividis", "rocket", "mako", "turbo")
  for (x in pals) {
    register_colortheme(
      name = x, source = "viridisLite", type = "sequential", env = env,
      kernel = c(text = "viridis", namespace = "viridisLite"),
      kernel.args = list(option = x, alpha = 1, begin = 0.2, end = 0.8, direction = 1),
      options = list(
        kernel.size = Inf,
        reverse.method = "kernel.args$direction <- - kernel.args$direction"
      )
    )
  }
  invisible(NULL)
}


register_themes_RColorBrewer <- function(env = colortheme_registry()) {
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) return(invisible(NULL))

  info <- RColorBrewer::brewer.pal.info
  for (i in seq_len(nrow(info))) {
    x <- rownames(info)[i]
    register_colortheme(
      name = x, source = "RColorBrewer", type = info[i, 2L], env = env,
      kernel = c(
        text = sprintf("brewer.pal(n = %d, name = '%s')", info[i, 1L], x),
        namespace = "RColorBrewer"
      )
    )
  }
  invisible(NULL)
}


register_themes_khroma <- function(env = colortheme_registry()) {
  if (!requireNamespace("khroma", quietly = TRUE)) return(invisible(NULL))

  info <- khroma::info()
  for (i in seq_len(nrow(info))) {
    x <- info[i, 1L]
    register_colortheme(
      name = x, source = "khroma", type = info[i, 2L], env = env,
      kernel = c(text = sprintf("color(palette = '%s')", x), namespace = "khroma"),
      kernel.args = list(range = c(0.0, 1.0)),
      options = list(kernel.size = info[i, 3L], na.color = info[i, 4L])
    )
  }
  invisible(NULL)
}
