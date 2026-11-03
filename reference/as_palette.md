# Extract Palette or Ramp Function

`as_palette()` and `as_ramp()` extract the underlying discrete palette
function or continuous color ramp function from a color theme or color
kernel.

## Usage

``` r
as_palette(x, ...)

# S3 method for class 'colortheme'
as_palette(x, ...)

# Default S3 method
as_palette(x, ...)

as_ramp(x, ...)

# S3 method for class 'colortheme'
as_ramp(x, ...)

# Default S3 method
as_ramp(x, ...)
```

## Arguments

- x:

  a `"colortheme"` object, a theme name (character string), a color
  vector, or a color-generating function.

- ...:

  additional arguments passed to
  [`colortheme`](https://ryo-asashi.github.io/colortheme/reference/colortheme.md)
  to modify the theme before extracting the function.

## Value

- `as_palette()` returns a palette function taking an integer `n` and
  returning `n` colors.

- `as_ramp()` returns a ramp function taking a numeric vector `x` in
  `[0, 1]` and returning corresponding colors.

## See also

[`colortheme`](https://ryo-asashi.github.io/colortheme/reference/colortheme.md),
[`map_to_colors`](https://ryo-asashi.github.io/colortheme/reference/map_to_colors.md)

## Examples

``` r
pal <- as_palette("Okabe-Ito")
pal(8L)
#> [1] "#000000" "#E69F00" "#56B4E9" "#009E73" "#F0E442" "#0072B2" "#D55E00"
#> [8] "#CC79A7"

ramp <- as_ramp("Viridis")
ramp(c(0, 0.5, 1.0))
#> [1] "#4B0054" "#009B94" "#FDE333"
```
