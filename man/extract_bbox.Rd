% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract.R
\name{extract_bbox}
\alias{extract_bbox}
\title{Extract a bounding box from an object}
\usage{
extract_bbox(x, tolatlon = TRUE, ...)
}
\arguments{
\item{x}{A \code{Spatial*} object, a \code{Raster*} object, a bounding box,
or a character string that will be passed to \code{searchbbox()} (prettymapr package). Multiple
strings will result in a bounding box that contains all of the geocoded
bounding boxes. The last resort is calling \code{sp::bbox()} on the \code{x}.}

\item{tolatlon}{Should the bounding box be un-projected to lat/lon coordinates?}

\item{...}{Passed to \code{searchbbox()} if applicable}
}
\value{
A bounding box in the form of \code{sp::bbox()}
}
\description{
This function is used internally by \link{osm.plot}, \link{bmaps.plot}, and
\link{osm.raster} to extract a bounding box from their first argument. This allows
considerable flexibility when specifying a location to map, in particular with
character input (a place name that will be geocoded), and other Spatial*/Raster*
objects.
}
\examples{
library(prettymapr)
ns <- makebbox(47.2, -59.7, 43.3, -66.4)
stopifnot(identical(ns, extract_bbox(ns)))

\donttest{
# downloads data, takes a long time to test
ns <- extract_bbox("nova scotia")
}

}

