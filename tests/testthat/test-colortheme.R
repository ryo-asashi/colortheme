test_that("colortheme() creates themes from color vectors, palettes, and ramps", {
  # 1. Color vector kernel (sequential by default)
  cols <- c("#003f5c", "#bc5090", "#ffa600")
  ct_vec <- colortheme(cols, name = "custom_seq")
  expect_s3_class(ct_vec, "colortheme")
  expect_equal(ct_vec$type, "sequential")
  expect_equal(ct_vec$kernel.class, "color")
  expect_length(ct_vec$palette(5L), 5L)
  expect_equal(ct_vec$palette(0L), character(0L))
  expect_length(ct_vec$ramp(c(0, 0.5, 1)), 3L)

  # Color vector with alpha
  cols_alpha <- c("#003f5c80", "#ffa60080")
  ct_alpha <- colortheme(cols_alpha)
  expect_true(all(grepl("^#[0-9A-Fa-f]{8}$", ct_alpha$ramp(c(0, 1)))))

  # 2. Palette function kernel
  ct_pal <- colortheme(grDevices::rainbow, type = "qualitative")
  expect_equal(ct_pal$kernel.class, "palette")
  expect_equal(ct_pal$type, "qualitative")
  expect_length(ct_pal$palette(4L), 4L)
  expect_length(ct_pal$ramp(c(0, 0.5, 1)), 3L)

  # 3. Ramp function kernel
  my_ramp <- function(x) grDevices::rgb(x, 0, 1 - x)
  ct_ramp <- colortheme(my_ramp, type = "diverging")
  expect_equal(ct_ramp$kernel.class, "ramp")
  expect_equal(ct_ramp$type, "diverging")
  expect_length(ct_ramp$palette(3L), 3L)
  expect_equal(ct_ramp$ramp(c(0, 1)), c("#0000FF", "#FF0000"))

  # 4. NULL returns NULL; invalid object throws error
  expect_null(colortheme(NULL))
  expect_error(colortheme(12345), "can't be converted")
  expect_error(colortheme(character(0)), "single theme name or a vector")
})

test_that("colortheme() retrieves built-in themes and parses URL-like query syntax", {
  # Built-in themes from colortheme and grDevices
  ct_midr <- colortheme("midr")
  expect_equal(ct_midr$type, "diverging")
  expect_equal(ct_midr$name, "midr")

  ct_hcl <- colortheme("HCL")
  expect_equal(ct_hcl$type, "qualitative")
  expect_length(ct_hcl$palette(6L), 6L)

  # Syntax: source/name_r@type?query
  ct_syn <- colortheme("grDevices/Zissou 1_r@qual?alpha=0.5;na.color='#000000'")
  expect_equal(ct_syn$name, "Zissou 1")
  expect_equal(ct_syn$source, "grDevices")
  expect_equal(ct_syn$type, "qualitative")
  expect_equal(ct_syn$options$na.color, "#000000")
  expect_equal(ct_syn$kernel.args$alpha, 0.5)

  # Verify reversal via _r suffix
  ct_norm <- colortheme("bluescale")
  ct_rev  <- colortheme("bluescale_r")
  expect_equal(ct_norm$palette(5L), rev(ct_rev$palette(5L)))
  expect_equal(ct_norm$ramp(c(0.2, 0.8)), ct_rev$ramp(c(0.8, 0.2)))

  # Single valid color string ("red") is treated as a color vector if not registered
  ct_red <- colortheme("red")
  expect_equal(ct_red$kernel.class, "color")

  # Errors on unknown theme or malformed query
  expect_error(colortheme("non_existent_theme_xyz"), "not found")
  expect_error(colortheme("midr/non_existent"), "not found")
  expect_error(colortheme("midr?invalid_query_no_equals"), "can't be parsed")
})

test_that("colortheme modification, subset assignment, and formatting options work", {
  ct <- colortheme(c("#000000", "#FFFFFF"), type = "qualitative")
  expect_equal(ct$options$palette.formatter, "recycle")
  # Recycle when n > kernel.size (2)
  expect_equal(ct$palette(4L), c("#000000", "#FFFFFF", "#000000", "#FFFFFF"))

  # Switching type updates default mode and formatter automatically
  ct_seq <- colortheme(ct, type = "sequential")
  expect_equal(ct_seq$type, "sequential")
  expect_equal(ct_seq$options$palette.formatter, "interpolate")
  expect_equal(ct_seq$kernel.args$mode, "ramp")

  # Formatter: fill.na and error
  ct_na <- colortheme(ct, options = list(palette.formatter = "fill.na", na.color = "gray"))
  expect_equal(ct_na$palette(3L), c("#000000", "#FFFFFF", "gray"))
  ct_err <- colortheme(ct, options = list(palette.formatter = "none"))
  expect_error(ct_err$palette(3L), "kernel.size")

  # Out-of-bounds and NA handling in ramp()
  expect_equal(
    ct_na$ramp(c(-0.5, NA, 1.5)),
    c("gray", "gray", "gray")
  )
  expect_equal(
    ct_na$ramp(c(-0.5, 0, 1, 1.5)),
    c("gray", "#000000", "#FFFFFF", "gray")
  )

  # Dynamic recompilation via $<- and [[<-
  ct_mod <- colortheme(c("#000000", "#FFFFFF"), type = "qualitative")
  ct_mod$options$na.color <- "#FF0000"
  expect_equal(ct_mod$ramp(NA_real_), "#FF0000")
  ct_mod[["type"]] <- "sequential"
  expect_equal(ct_mod$type, "sequential")

  # Identity when called with 1 argument
  expect_identical(colortheme(ct_mod), ct_mod)
})

test_that("print.colortheme and plot.colortheme execute cleanly", {
  ct_seq  <- colortheme("bluescale")
  ct_qual <- colortheme("HCL")

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_output(res <- print(ct_seq, display = TRUE), "Sequential Color Theme: 'bluescale'")
  expect_identical(res, ct_seq)
  expect_output(print(ct_qual, display = FALSE), "Qualitative Color Theme: 'HCL'")
  expect_invisible(plot(ct_qual, n = 6L))
})

test_that("register_colortheme(), colorthemes(), and init_colorthemes() manage registry", {
  tmp_env <- new.env(parent = emptyenv())

  # Empty registry returns 0-row data.frame with exact schema
  df_empty <- colorthemes(env = tmp_env)
  expect_s3_class(df_empty, "data.frame")
  expect_equal(nrow(df_empty), 0L)
  expect_equal(names(df_empty), c("name", "source", "type"))

  # Register custom theme from vector and from colortheme object
  old <- register_colortheme(
    kernel = c("blue", "white", "red"),
    name = "bwr", source = "test_src", type = "diverging", env = tmp_env
  )
  expect_null(old)

  ct_obj <- colortheme("bwr", env = tmp_env)
  old2 <- register_colortheme(ct_obj, name = "bwr", source = "test_src", env = tmp_env)
  expect_type(old2, "list")
  expect_equal(old2$name, "bwr")

  # Query registry with prefix and type filters
  df_all <- colorthemes(env = tmp_env)
  expect_equal(nrow(df_all), 1L)
  expect_equal(nrow(colorthemes(env = tmp_env, name = "BW", source = "test", type = "div")), 1L)
  expect_equal(nrow(colorthemes(env = tmp_env, name = "unknown")), 0L)

  # Validation errors in register_colortheme
  expect_error(register_colortheme(c("red", "blue"), name = "bad/name", env = tmp_env), "reserved")
  expect_error(register_colortheme(c("red", "blue"), name = "bad_r", env = tmp_env), "reserved")
  expect_error(register_colortheme(c("red", "blue"), name = "bad@q", env = tmp_env), "reserved")
  expect_error(register_colortheme(c("red", "blue"), name = "bad?a=1", env = tmp_env), "reserved")

  # Initialize full suite into temporary environment and clear
  init_colortheme(env = tmp_env, clear.env = TRUE)
  expect_gt(nrow(colorthemes(env = tmp_env)), 10L)
})

test_that("map_to_colors() maps discrete and continuous values accurately", {
  # Continuous sequential
  x_num <- c(0, 5, 10, NA)
  c_seq <- map_to_colors(x_num, theme = c("#000000", "#FFFFFF"), na.value = "#FF0000")
  expect_equal(c_seq, c("#000000", "#767676", "#FFFFFF", "#FF0000"))

  # Continuous diverging with middle = 0
  x_div <- c(-10, 0, 5)
  ct_div <- colortheme(c("#0000FF", "#FFFFFF", "#FF0000"), type = "diverging")
  c_div <- map_to_colors(x_div, theme = ct_div, middle = 0)
  expect_equal(c_div[1L], "#0000FF")
  expect_equal(c_div[2L], "#FFFFFF")

  # Constant vector edge case (d == 0)
  expect_length(map_to_colors(c(5, 5, 5), theme = "bluescale"), 3L)
  expect_length(map_to_colors(c(0, 0, 0), theme = "midr", middle = 0), 3L)

  # Discrete mapping (character, factor, logical)
  x_chr <- c("A", "B", "A", NA)
  c_qual <- map_to_colors(x_chr, theme = colortheme(c("#111111", "#222222"), type = "qualitative"), na.value = "#999999")
  expect_equal(c_qual, c("#111111", "#222222", "#111111", "#999999"))

  # Qualitative theme for continuous variable throws error
  expect_error(map_to_colors(1:5, theme = "HCL"), "qualitative color theme can't be used")
})

test_that("scale_color_theme() and scale_fill_theme() construct ggplot2 scales", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("scales")

  s_disc <- scale_color_theme("HCL")
  expect_s3_class(s_disc, "ScaleDiscrete")

  s_seq <- scale_colour_theme("bluescale")
  expect_s3_class(s_seq, "ScaleContinuous")

  s_div <- scale_fill_theme("midr", middle = 0.5)
  expect_s3_class(s_div, "ScaleContinuous")
  expect_equal(s_div$aesthetics, "fill")

  # Force sequential theme into discrete scale
  s_forced <- scale_color_theme("bluescale", discrete = TRUE)
  expect_s3_class(s_forced, "ScaleDiscrete")

  # Qualitative theme on continuous scale throws error
  expect_error(scale_color_theme("HCL", discrete = FALSE), "qualitative color theme")
})

test_that("as_palette() and as_ramp() extract color-generating functions", {
  # From theme name
  pal <- as_palette("Okabe-Ito")
  expect_type(pal, "closure")
  expect_length(pal(5L), 5L)

  ramp <- as_ramp("bluescale")
  expect_type(ramp, "closure")
  expect_length(ramp(c(0, 0.5, 1)), 3L)

  # From colortheme object with on-the-fly modification via ...
  ct <- colortheme("bluescale")
  pal_rev <- as_palette(ct, reverse = TRUE)
  expect_equal(pal_rev(3L), rev(ct$palette(3L)))

  ramp_rev <- as_ramp(ct, reverse = TRUE)
  expect_equal(ramp_rev(c(0, 1)), ct$ramp(c(1, 0)))

  # Direct color vector fast-path in as_ramp.default
  fast_ramp <- as_ramp(c("#000000", "#FFFFFF"))
  expect_s3_class(fast_ramp, "ramp")
  expect_equal(fast_ramp(c(0, 1)), c("#000000", "#FFFFFF"))
})
