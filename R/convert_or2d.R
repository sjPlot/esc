#' @title Convert effect size OR from d
#' @name convert_or2d
#'
#' @description Compute effect size \code{d} from effect size \code{OR}.
#'
#' @param or The effect size as odds ratio.
#' @param es.type Type of effect size that should be returned.
#'        \describe{
#'          \item{\code{"d"}}{returns effect size \code{d}}
#'          \item{\code{"cox.d"}}{returns effect size \code{d}, based on Cox method}
#'          \item{\code{"g"}}{returns effect size Hedges' \code{g} (see \code{\link{hedges_g}})}
#'        }
#'
#' @inheritParams esc_beta
#' @inheritParams convert_d2or
#'
#' @note While \code{or} is the exponentiated log odds, the variance or standard
#'       error need to be on the log-scale!
#'
#' @return The effect size \code{es}, the standard error \code{se}, the variance
#'         of the effect size \code{var}, the lower and upper confidence limits
#'         \code{ci.lo} and \code{ci.hi}, the weight factor \code{w} and the
#'         total sample size \code{totaln}.
#'
#' @references Lipsey MW, Wilson DB. 2001. Practical meta-analysis. Thousand Oaks, Calif: Sage Publications
#'             \cr \cr
#'             Wilson DB. 2016. Formulas Used by the "Practical Meta-Analysis Effect Size Calculator". Unpublished manuscript: George Mason University
#'
#' @examples
#' convert_or2d(3.56, se = 0.91)
#' convert_d2or(0.7, se = 0.5)
#'
#' @export
convert_or2d <- function(or, se, v, totaln, es.type = c("d", "cox.d", "g", "f", "eta"), info = NULL, study = NULL) {
  # match arguments
  es.type <- match.arg(es.type)

  # check if parameter are complete
  if ((missing(se) || is.null(se) || is.na(se)) && (missing(v) || is.null(v) || is.na(v))) {
    warning("Either `se` or `v` must be specified.", call. = F)
    return(esc_generic(es = NA, v = NA, es.type = es.type, grp1n = NA, grp2n = NA, info = NA, study = NA))
  }

  # do we have se?
  if (!missing(se) && !is.null(se) && !is.na(se)) v <- se^2

  # do we have total n?
  if (missing(totaln) || is.na(totaln)) totaln <- NULL

  # do we have a separate info string?
  if (is.null(info)) {
    if (es.type == "cox.d")
      info <- "effect size OR to effect size Cox d"
    else if (es.type == "d")
      info <- "effect size OR to effect size d"
    else if (es.type == "g")
      info <- "effect size OR to effect size Hedges' g"
    else if (es.type == "f")
      info <- "effect size OR to effect size Cohen's f"
    else if (es.type == "eta")
      info <- "effect size OR to effect size eta squared"
  }

  if (es.type %in% c("d", "g", "f", "eta")) {
    es <- log(or) / (pi / sqrt(3))
    v <- v / ((pi^2) / 3)
    measure <- es.type

    # hedges g?
    if (es.type == "g") {
      # do we have total n?
      if (is.null(totaln))
        warning("`totaln` is needed to calculate Hedges' g.", call. = F)
      else
        es <- hedges_g(d = es, totaln = totaln)
    }

    # f?
    if (es.type == "f") es <- cohens_f(d = es)

    # eta squared?
    if (es.type == "eta") es <- eta_squared(d = es)

  } else {
    es <- log(or) / 1.65
    v <- v / (1.65^2)
    measure <- "cox d"
  }

  # return effect size d
  structure(
    class = c("esc", "convert_or2d"),
    list(es = es, se = sqrt(v), var = v, ci.lo = lower_d(es, v),
         ci.hi = upper_d(es, v), w = 1 / v, totaln = totaln,
         measure = measure, info = info, study = study)
  )
}
