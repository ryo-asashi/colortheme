# Getting Started with Color Themes

## Color themes

The `"colortheme"` object provides two color-generating functions:
[`palette()`](https://rdrr.io/r/grDevices/palette.html) and `ramp()`.
The [`palette()`](https://rdrr.io/r/grDevices/palette.html) function
accepts an integer $`n`$ and returns a vector of $`n`$ discrete colors.
It is primarily intended for **qualitative** themes, where distinct
colors are used to represent categorical data. The `ramp()` function
accepts a numeric vector $`x`$ with values in the $`[0, 1]`$ interval
and returns a vector of corresponding colors. It maps numeric values
onto a continuous color gradient, making it suitable for **sequential**
and **diverging** themes.

### Pre-defined themes

You can get a pre-defined `"colortheme"` object by providing a theme
name to the
[`colortheme()`](https://ryo-asashi.github.io/colortheme/reference/colortheme.md)
function.

``` r

library(colortheme)
# diverging color theme "azurerose" (package:colortheme)
azurerose <- colortheme("azurerose")
print(azurerose)
#> Diverging Color Theme: 'azurerose' (from 'colortheme')
#> 
#> Kernel Class: color
#> 
#> Kernel Colors:
#> #005AAD, #3B78C2, #729BD6, #AFC4E8, #F7F7F7, #E8B3CC, #D67FA8, #BD4989, #A4136E
#> 
#> Options:
#>   kernel.size      : 9L
#>   palette.formatter: "interpolate"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#>   reverse.method   : NA
#> 
#> Kernel Arguments:
#>   mode : "ramp"
#>   alpha: NA
```

![](colortheme_files/figure-html/unnamed-chunk-2-1.png)

``` r

azurerose$palette(5)
#> [1] "#0059AC" "#729AD6" "#F7F7F7" "#D67FA7" "#A4136D"
```

``` r

azurerose$ramp(c(0.00, 0.25, 0.50, 0.75, 1.00))
#> [1] "#0059AC" "#729AD6" "#F7F7F7" "#D67FA7" "#A4136D"
```

``` r

# sequential color theme "viridis" (package:viridisLite)
viridis <- colortheme("viridis")
print(viridis)
#> Sequential Color Theme: 'viridis' (from 'viridisLite')
#> 
#> Kernel Class: palette
#> 
#> Kernel Function:
#> function (n, alpha = 1, begin = 0, end = 1, direction = 1, option = "D")
#> 
#> Options:
#>   kernel.size      : Inf
#>   reverse.method   : "kernel.args$direction <- - kernel.args$direction"
#>   palette.formatter: "interpolate"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#> 
#> Kernel Arguments:
#>   option   : "viridis"
#>   alpha    : 1
#>   begin    : 0.2
#>   end      : 0.8
#>   direction: 1
```

![](colortheme_files/figure-html/unnamed-chunk-4-1.png)

``` r

viridis$palette(5)
#> [1] "#414487FF" "#2F6C8EFF" "#21908CFF" "#2FB47CFF" "#7AD151FF"
```

``` r

viridis$ramp(c(0.00, 0.25, 0.50, 0.75, 1.00))
#> [1] "#404486" "#2E6C8D" "#21908C" "#2EB37B" "#79D151"
```

You can modify themes by **reversing** the color order or **changing**
the theme type (e.g., from sequential to qualitative). These changes can
be applied in two ways:

1.  **Using Arguments** : provide the appropriate argument to the
    function, such as `reverse = TRUE` or `type = "qualitative"`.
2.  **Using Suffixes** : for convenience, you can append a suffix
    directly to the theme’s name. `_r` to reverse the theme, `@q` (or
    longer, such as `@qual`) to make the theme qualitative (`@d` for
    diverging, `@s` for sequential).

``` r

plot(colortheme("nightfall", reverse = TRUE),
     text = "khroma/nightfall_r")
```

![](colortheme_files/figure-html/unnamed-chunk-6-1.png)

``` r

plot(colortheme("nightfall", type = "qualitative"),
     text = "khroma/nightfall@qual")
```

![](colortheme_files/figure-html/unnamed-chunk-6-2.png)

``` r

plot(colortheme("viridis_r"),
     text = "viridisLite/viridis_r")
```

![](colortheme_files/figure-html/unnamed-chunk-6-3.png)

``` r

plot(colortheme("viridis@qual", kernel.size = 8L),
     text = "viridisLite/viridis@qual")
```

![](colortheme_files/figure-html/unnamed-chunk-6-4.png)

You can also customize kernel arguments on the fly using query
parameters after `?` (e.g., `"highlight?which=1:2"`).

When multiple packages provide a theme with the same name (e.g.,
`"Paired"`), you can specify which one to use in two ways:

1.  **Using Argument** : provide the package name to the `source`
    argument (e.g., `source = "grDevices"`).
2.  **Using Prefix** : prepend the package name and a forward slash to
    the theme name (e.g., `"RColorBrewer/Paired"`).

``` r

# qualitative color theme "Paired" (package:grDevices)
paired <- colortheme("Paired", source = "grDevices")
plot(paired, text = "grDevices/Paired")
```

![](colortheme_files/figure-html/unnamed-chunk-7-1.png)

``` r

# qualitative color theme "Paired" (package:RColorBrewer)
paired2 <- colortheme("RColorBrewer/Paired")
plot(paired2, text = "RColorBrewer/Paired")
```

![](colortheme_files/figure-html/unnamed-chunk-7-2.png)

### Custom themes

Alternatively, you can create a new `"colortheme"` object by passing a
custom color vector or function to the first argument of
[`colortheme()`](https://ryo-asashi.github.io/colortheme/reference/colortheme.md).

``` r

# create a new color theme using a color vector
mytheme <- colortheme(
  c("#003f5c", "#7a5195", "#ef5675", "#ffa600"),
  type = "sequential", name = "mytheme"
)
print(mytheme)
#> Sequential Color Theme: 'mytheme'
#> 
#> Kernel Class: color
#> 
#> Kernel Colors:
#> #003f5c, #7a5195, #ef5675, #ffa600
#> 
#> Options:
#>   kernel.size      : 4L
#>   palette.formatter: "interpolate"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#>   reverse.method   : NA
#> 
#> Kernel Arguments:
#>   mode : "ramp"
#>   alpha: NA
```

![](colortheme_files/figure-html/unnamed-chunk-8-1.png)

``` r

mytheme$palette(5)
#> [1] "#003F5B" "#614D86" "#B85485" "#F46C63" "#FFA500"
```

``` r

mytheme$ramp(c(0.00, 0.25, 0.50, 0.75, 1.00))
#> [1] "#003F5B" "#614D86" "#B85485" "#F46C63" "#FFA500"
```

``` r

# create a new color theme using a color function
rainbow <- colortheme(
  grDevices::rainbow,
  name = "rainbow", source = "grDevices"
)
print(rainbow)
#> Sequential Color Theme: 'rainbow' (from 'grDevices')
#> 
#> Kernel Class: palette
#> 
#> Kernel Function:
#> function (n, s = 1, v = 1, start = 0, end = max(1, n - 1)/n, alpha, rev = FALSE)
#> 
#> Options:
#>   kernel.size      : Inf
#>   palette.formatter: "interpolate"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#>   reverse.method   : NA
```

![](colortheme_files/figure-html/unnamed-chunk-10-1.png)

``` r

rainbow$palette(5)
#> [1] "#FF0000" "#CCFF00" "#00FF66" "#0066FF" "#CC00FF"
```

``` r

rainbow$ramp(c(0.00, 0.25, 0.50, 0.75, 1.00))
#> [1] "#FF0000" "#81FF00" "#00FFFB" "#7B00FF" "#FF0006"
```

You can register a custom theme to call it by name later in your current
R session. To do so, use the
[`register_colortheme()`](https://ryo-asashi.github.io/colortheme/reference/colorthemes.md)
function.

``` r

register_colortheme(mytheme, name = "mytheme", source = "custom")
colortheme("mytheme_r@div")
#> Diverging Color Theme: 'mytheme' (from 'custom')
#> 
#> Kernel Class: color
#> 
#> Kernel Colors:
#> #ffa600, #ef5675, #7a5195, #003f5c
#> 
#> Options:
#>   kernel.size      : 4L
#>   palette.formatter: "interpolate"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#>   reverse.method   : NA
#> 
#> Kernel Arguments:
#>   mode : "ramp"
#>   alpha: NA
```

![](colortheme_files/figure-html/unnamed-chunk-12-1.png)

``` r

colortheme("custom/mytheme@q")
#> Qualitative Color Theme: 'mytheme' (from 'custom')
#> 
#> Kernel Class: color
#> 
#> Kernel Colors:
#> #003f5c, #7a5195, #ef5675, #ffa600
#> 
#> Options:
#>   kernel.size      : 4L
#>   palette.formatter: "recycle"
#>   palette.reverse  : FALSE
#>   ramp.rescaler    : c(0, 1)
#>   na.color         : NA
#>   reverse.method   : NA
#> 
#> Kernel Arguments:
#>   mode : "palette"
#>   alpha: NA
```

![](colortheme_files/figure-html/unnamed-chunk-12-2.png)

### Using themes with **ggplot2**

To apply your color themes to **ggplot2** plots, use the
[`scale_color_theme()`](https://ryo-asashi.github.io/colortheme/reference/scale_color_theme.md)
and
[`scale_fill_theme()`](https://ryo-asashi.github.io/colortheme/reference/scale_color_theme.md)
functions. These scales integrate your themes directly into the plot’s
`color` and `fill` aesthetics.

``` r

library(ggplot2)
library(gridExtra)
theme_set(theme_minimal())

set.seed(42)
dataset <- diamonds[sample(nrow(diamonds), 5000L), ]

p <- ggplot(dataset) + geom_point(aes(carat, price, col = color))
grid.arrange(
  p + scale_color_theme("shiki"),
  p + scale_color_theme("viridisLite/mako", discrete = TRUE),
  p + scale_color_theme("tokyo@qual"),
  p + scale_color_theme("highlight?base='#80808010'&which=6:7")
)
```

![](colortheme_files/figure-html/unnamed-chunk-13-1.png)

``` r

p2 <- ggplot(dataset) +
  geom_histogram(aes(x = carat, fill = cut), bins = 20)
grid.arrange(
  p2 + scale_fill_theme("ukiyoe"),
  p2 + scale_fill_theme("khroma/discreterainbow"),
  p2 + scale_fill_theme("mytheme@q"),
  p2 + scale_fill_theme("highlight?which=1:2")
)
```

![](colortheme_files/figure-html/unnamed-chunk-14-1.png)

``` r

# Continuous scales with sequential and diverging themes
p3 <- ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
  geom_raster()
grid.arrange(
  p3 + scale_fill_theme("ai"),
  p3 + scale_fill_theme("Cividis", middle = 0.017),
  p3 + scale_fill_theme("ai_r"),
  p3 + scale_fill_theme("Viridis?alpha=0.5")
)
```

![](colortheme_files/figure-html/unnamed-chunk-15-1.png)

## Pre-defined color themes

The following color themes are available when the **colortheme** package
is loaded. Some themes depend on other packages being installed, so for
full functionality, please ensure you have already installed the
**viridisLite**, **RColorBrewer**, and **khroma** packages.

### Diverging Color Themes

![](colortheme_files/figure-html/diverging_gallery-1.png)![](colortheme_files/figure-html/diverging_gallery-2.png)![](colortheme_files/figure-html/diverging_gallery-3.png)![](colortheme_files/figure-html/diverging_gallery-4.png)![](colortheme_files/figure-html/diverging_gallery-5.png)![](colortheme_files/figure-html/diverging_gallery-6.png)![](colortheme_files/figure-html/diverging_gallery-7.png)![](colortheme_files/figure-html/diverging_gallery-8.png)![](colortheme_files/figure-html/diverging_gallery-9.png)![](colortheme_files/figure-html/diverging_gallery-10.png)![](colortheme_files/figure-html/diverging_gallery-11.png)![](colortheme_files/figure-html/diverging_gallery-12.png)![](colortheme_files/figure-html/diverging_gallery-13.png)![](colortheme_files/figure-html/diverging_gallery-14.png)![](colortheme_files/figure-html/diverging_gallery-15.png)![](colortheme_files/figure-html/diverging_gallery-16.png)![](colortheme_files/figure-html/diverging_gallery-17.png)

### Qualitative Color Themes

![](colortheme_files/figure-html/qualitative_gallery-1.png)![](colortheme_files/figure-html/qualitative_gallery-2.png)![](colortheme_files/figure-html/qualitative_gallery-3.png)![](colortheme_files/figure-html/qualitative_gallery-4.png)![](colortheme_files/figure-html/qualitative_gallery-5.png)![](colortheme_files/figure-html/qualitative_gallery-6.png)![](colortheme_files/figure-html/qualitative_gallery-7.png)![](colortheme_files/figure-html/qualitative_gallery-8.png)![](colortheme_files/figure-html/qualitative_gallery-9.png)![](colortheme_files/figure-html/qualitative_gallery-10.png)![](colortheme_files/figure-html/qualitative_gallery-11.png)![](colortheme_files/figure-html/qualitative_gallery-12.png)

### Sequential Color Themes

![](colortheme_files/figure-html/sequential_gallery-1.png)![](colortheme_files/figure-html/sequential_gallery-2.png)![](colortheme_files/figure-html/sequential_gallery-3.png)![](colortheme_files/figure-html/sequential_gallery-4.png)![](colortheme_files/figure-html/sequential_gallery-5.png)![](colortheme_files/figure-html/sequential_gallery-6.png)![](colortheme_files/figure-html/sequential_gallery-7.png)![](colortheme_files/figure-html/sequential_gallery-8.png)![](colortheme_files/figure-html/sequential_gallery-9.png)![](colortheme_files/figure-html/sequential_gallery-10.png)![](colortheme_files/figure-html/sequential_gallery-11.png)![](colortheme_files/figure-html/sequential_gallery-12.png)![](colortheme_files/figure-html/sequential_gallery-13.png)![](colortheme_files/figure-html/sequential_gallery-14.png)![](colortheme_files/figure-html/sequential_gallery-15.png)![](colortheme_files/figure-html/sequential_gallery-16.png)![](colortheme_files/figure-html/sequential_gallery-17.png)![](colortheme_files/figure-html/sequential_gallery-18.png)![](colortheme_files/figure-html/sequential_gallery-19.png)![](colortheme_files/figure-html/sequential_gallery-20.png)![](colortheme_files/figure-html/sequential_gallery-21.png)![](colortheme_files/figure-html/sequential_gallery-22.png)![](colortheme_files/figure-html/sequential_gallery-23.png)![](colortheme_files/figure-html/sequential_gallery-24.png)![](colortheme_files/figure-html/sequential_gallery-25.png)![](colortheme_files/figure-html/sequential_gallery-26.png)![](colortheme_files/figure-html/sequential_gallery-27.png)![](colortheme_files/figure-html/sequential_gallery-28.png)![](colortheme_files/figure-html/sequential_gallery-29.png)![](colortheme_files/figure-html/sequential_gallery-30.png)![](colortheme_files/figure-html/sequential_gallery-31.png)![](colortheme_files/figure-html/sequential_gallery-32.png)![](colortheme_files/figure-html/sequential_gallery-33.png)
