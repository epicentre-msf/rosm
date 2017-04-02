ROSM: Open Street Map tiles in R
================
Dewey Dunnington
March 20, 2017

[![](http://cranlogs.r-pkg.org/badges/rosm)](https://cran.r-project.org/package=rosm)

Download and plot [Open Street Map](http://www.openstreetmap.org/), [Bing Maps](http://www.bing.com/maps), and other tiled map sources in a way that works seamlessly with plotting from the 'sp' package. Use to create high-resolution basemaps and add hillshade to vector based maps. Note that rosm uses base plotting and not ggplot2: for mapping in ggplot2, use [ggspatial](https://github.com/paleolimbot/ggspatial) or [ggmap](https://github.com/dkahle/ggmap).

Installation
------------

The {rosm} package is [available on CRAN](https://cran.r-project.org/package=rosm), and can be installed using `install.packages("rosm")`.

Using {rosm} to plot basemaps
-----------------------------

The {rosm} package pulls [Bing Maps](https://www.bing.com/maps/), [Open Street Map](https://www.openstreetmap.org/), and [related maps](http://wiki.openstreetmap.org/wiki/Tile_servers) from the internet, caches them locally, and renders them to provide context to overlying data (your sample sites, etc.). For details, take a look at the [{rosm} manual](https://cran.r-project.org/web/packages/rosm/rosm.pdf). First we'll load the packages (we'll also be using the [prettymapr](http://paleolimbot.github.io/prettymapr) package to help us with bounding boxes and plotting.)

``` r
library(rosm)
library(prettymapr)
```

### Step 1: Find your bounding box

The {rosm} package plots based on a **bounding box**, or an area that you would like to be visible. There's a few ways to go about doing this, but the easiest way is to visit the [Open Street Maps Export page](http://www.openstreetmap.org/export), zoom to your area of interest, and copy/paste the values into `makebbox(northlat, eastlon, southlat, westlon)` from the {prettymapr} package. You can also use `searchbbox("my location name")`, also from the {prettymapr} package, which will query google for an appropriate bounding box. You'll notice that the bounding box returned by these methods is just a 2x2 matrix, the same as that returned by `bbox()` in the {sp} package.

``` r
altalake <- searchbbox("alta lake, BC")
# or
altalake <- makebbox(50.1232, -122.9574, 50.1035, -123.0042)
```

Make sure you've got your bounding box right by trying `osm.plot()` or `bmaps.plot()` with the bounding box as your first argument.

``` r
osm.plot(altalake)
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-3-1.png)

The first thing you'll notice is that the margins are huge! By default, `osm.plot()` doesn't mess with your graphical parameters. In Step 3 you'll see how to wrap your plotting code in `prettymap()` to automatically remove margins and add a scale bar (and make the margins come back again so you can use `plot()` normally).

A recent addition to the rosm package is the function `extract_bbox()`, which converts its input to a bounding box. This is used to coerce the first argument to `osm.plot()`, `bmaps.plot()`, and `osm.raster()`. This means you can type `osm.plot("alta lake, BC")` and get the same output as above. You can aso pass a `Spatial*` object or a `Raster*` object, from which a bounding box will be extracted.

### Step 2: Choose your map type and zoom level

The rosm package provides access to a number of map types (and even the ability to load your own if you're savvy), but the most common ones you'll use are `type=osm`, `type="hillshade"`, `type="stamenwatercolor"`, and `type="stamenbw"` for `osm.plot()` and `type="Aerial"` with `bmaps.plot()`. Look at all of them with `osm.types()` and `bmaps.types()`.

``` r
osm.types()
```

    ##  [1] "osm"                    "opencycle"             
    ##  [3] "hotstyle"               "loviniahike"           
    ##  [5] "loviniacycle"           "hikebike"              
    ##  [7] "hillshade"              "osmgrayscale"          
    ##  [9] "stamenbw"               "stamenwatercolor"      
    ## [11] "osmtransport"           "thunderforestlandscape"
    ## [13] "thunderforestoutdoors"  "cartodark"             
    ## [15] "cartolight"

``` r
osm.plot(altalake, type="stamenbw")
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-4-1.png)

``` r
bmaps.types()
```

    ## [1] "Aerial"           "AerialWithLabels" "Road"

``` r
bmaps.plot(altalake, type="AerialWithLabels")
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-5-1.png)

The next thing we'll adjust is the zoom level. The zoom level (level of detail) is calculated automatically, but it may be that you're looking for higher (or lower) resolution. To specify a resolution specifically, use `res=300` (where 300 is the resolution in dpi; useful when exporting figures), or `zoomin=1`, which will use the automatically specified zoom level and zoom in 1 more. For `osm.raster()`, the default is based on number of tiles loaded and not the resolution, but the zoom can be similarly adjusted.

``` r
bmaps.plot(altalake, zoomin=1) # res=300 will also work
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-6-1.png)

### Step 3: Add overlays

Next we'll use the `osm.points()`, `osm.lines()`, `osm.polygon()`, and `osm.text()` functions to draw on top of the map we've just plotted. We are using these functions instead of their base graphics counterparts because `osm.plot()` projects its images to a different coordinate system (epsg:3857, if you're curious). You can also pass `project = FALSE` to `osm.plot()` to disable this, but I don't suggest it: for large-scale plotting of continents, your points will be wildly out of place (and most likely you will blame me for this, and I'm just a lowly PhD student).

``` r
# plot without projecting
osm.plot(altalake)
osm.points(c(-122.9841, -122.9812), c(50.11055, 50.11765), 
           pch=15, cex=0.6)
osm.text(c(-122.9841, -122.9812), c(50.11055, 50.11765), 
         labels=c("GC6", "GC2"), adj=c(-0.2, 0.5), cex=0.5)
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-7-1.png)

### Step 4: Putting it all together

Putting it all together, an example plotting script might like this (we're going to use the `prettymap()` function to set the margins and add our scale bar).

``` r
altalake <- makebbox(50.1232, -122.9574, 50.1035, -123.0042)
prettymap({
  bmaps.plot(altalake, res=300)
  osm.points(c(-122.9841, -122.9812), c(50.11055, 50.11765), 
             pch=15, cex=0.6, col="white")
  osm.text(c(-122.9841, -122.9812), c(50.11055, 50.11765), 
           labels=c("GC6", "GC2"), adj=c(-0.2, 0.5), cex=0.7, col="white")
  })
```

![](inst/README_files/figure-markdown_github/unnamed-chunk-8-1.png)

There's tons of options for `prettymap()` that let you customize the north arrow, scale bar etc., which you can find in the [{prettymapr} manual](https://cran.r-project.org/web/packages/prettymapr/prettymapr.pdf).

More to come
------------

There's definitely more work to do on this package, but I hope it continues to be useful in its current form. Feel free to email questions and bugs to <dewey@fishandwhistle.net>.

