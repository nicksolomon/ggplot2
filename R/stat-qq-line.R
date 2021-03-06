#' A quantile-quantile line
#'
#' @section Aesthetics:
#' \aesthetics{stat}{qq_line}
#'
#' @param line.p Vector of quantiles to use when fitting the Q-Q line, defaults
#' defaults to \code{c(.25, .75)}.
#' @param fullrange Should the q-q line span the full range of the plot, or just
#'   the data
#' @inheritParams layer
#' @inheritParams geom_path
#' @inheritParams geom_qq
#' @export
#' @describeIn geom_qq Find the endpoints of a useful Q-Q line.
geom_qq_line <- function(mapping = NULL,
                         data = NULL,
                         geom = "path",
                         position = "identity",
                         ...,
                         distribution = stats::qnorm,
                         dparams = list(),
                         line.p = c(.25, .75),
                         fullrange = FALSE,
                         na.rm = FALSE,
                         show.legend = NA,
                         inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = StatQqLine,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      distribution = distribution,
      dparams = dparams,
      na.rm = na.rm,
      line.p = line.p,
      fullrange = fullrange,
      ...
    )
  )
}

#' @export
#' @rdname geom_qq
stat_qq_line <- geom_qq_line

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatQqLine <- ggproto("StatQqLine", Stat,
 default_aes = aes(x = ..x.., y = ..y..),

 required_aes = c("sample"),

 compute_group = function(data,
                          scales,
                          quantiles = NULL,
                          distribution = stats::qnorm,
                          dparams = list(),
                          na.rm = FALSE,
                          line.p = c(.25, .75),
                          fullrange = FALSE) {

   sample <- sort(data$sample)
   n <- length(sample)

   # Compute theoretical quantiles
   if (is.null(quantiles)) {
     quantiles <- stats::ppoints(n)
   } else {
     stopifnot(length(quantiles) == n)
   }

   theoretical <- do.call(distribution,
                          c(list(p = quote(quantiles)),
                            dparams))

   if (length(line.p) != 2) {
     stop("Cannot fit line quantiles ", line.p,
          ". Parameter line.p must have length 2.",
          call = FALSE)
   }

   x_coords <- do.call(distribution, c(list(p = line.p), dparams))
   y_coords <- quantile(sample, line.p)
   slope = diff(y_coords)/diff(x_coords)
   intercept = y_coords[1L] - slope * x_coords[1L]


   out <- data.frame()

   if (fullrange & !is.null(scales$x$dimension)){
     out$x <- scales$x$dimension()
   } else{
     out$x <- range(theoretical)
   }

   out$y <- slope * out$x + intercept
   out
 }
)
