#' Lookup GLI 2021 Spline Values
#'
#' Helper function to extract M spline and S spline values from lookup tables
#' based on age, sex, and spirometric parameter.
#'
#' @param age Numeric. Age in years
#' @param sex Character. Sex ("M", "Male", "MALE", "F", "Female", "FEMALE")
#' @param variable Character. Spirometric parameter ("FEV1", "FVC", "FEV1FVC")
#'
#' @return List with Mspline and Sspline values
#' @keywords internal
lookup_spline <- function(age, sex, variable) {
  # Load the lookup tables (these should be included as package data)
  # For now, assume SplineSheets is available in package environment
  
  if (variable == "FEV1") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheets[[1]][, c("Age", "M Spline", "S Spline")]
    } else {
      spline_tab <- SplineSheets[[4]][, c("Age", "M Spline", "S Spline")]
    }
  } else if (variable == "FVC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheets[[2]][, c("Age", "M Spline", "S Spline")]
    } else {
      spline_tab <- SplineSheets[[5]][, c("age", "M Spline", "S Spline")]
    }
  } else if (variable == "FEV1FVC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheets[[3]][, c("Age", "M Spline", "S Spline")]
    } else {
      spline_tab <- SplineSheets[[6]][, c("Age", "M Spline", "S Spline")]
    }
  }
  
  names(spline_tab) <- c("age", "Mspline", "Sspline")
  
  # Find the closest age from the lookup table
  age_delta <- abs(spline_tab$age - age)
  s <- which.min(age_delta)
  
  ret <- list(Mspline = spline_tab$Mspline[s], 
              Sspline = spline_tab$Sspline[s])
  return(ret)
}


#' Compute GLI 2021 Predicted Values
#'
#' Calculate predicted spirometric values using GLI 2021 Global (race-neutral) equations.
#' Based on Bowerman et al. 2023 reference equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Spirometric parameter ("FEV1", "FVC", or "FEV1FVC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Predicted value in liters (or ratio for FEV1/FVC)
#' 
#' @references
#' Bowerman C, et al. A race-neutral approach to the interpretation of lung 
#' function measurements. Am J Respir Crit Care Med. 2023.
#'
#' @export
#' @examples
#' # Calculate predicted FEV1 for a 45-year-old male, 175 cm tall
#' compute_gli_pred(sex = "Male", ht = 175, age = 45, param = "FEV1")
#' 
#' # Calculate predicted FVC for a 60-year-old female, 65 inches tall
#' compute_gli_pred(sex = "Female", ht = 65, ht_unit = "in", age = 60, param = "FVC")
compute_gli_pred <- function(sex, ht, ht_unit = "cm", age, param = "FEV1", ...) {
  stopifnot(param %in% c("FEV1", "FVC", "FEV1FVC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54  # Convert inches to cm
  }
  
  # Look up values for Mspline and Sspline
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FEV1" = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline),
      "FVC" = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline),
      "FEV1FVC" = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline)
    ),
    # Female equations
    switch(
      param,
      "FEV1" = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) + mspline),
      "FVC" = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline),
      "FEV1FVC" = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline)
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Lower Limit of Normal (LLN)
#'
#' Calculate lower limit of normal (5th percentile) using GLI 2021 Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Spirometric parameter ("FEV1", "FVC", or "FEV1FVC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Lower limit of normal in liters (or ratio for FEV1/FVC)
#'
#' @export
#' @examples
#' # Calculate LLN for FEV1
#' compute_gli_lln(sex = "Male", ht = 175, age = 45, param = "FEV1")
compute_gli_lln <- function(sex, ht, ht_unit = "cm", age, param = "FEV1", ...) {
  stopifnot(param %in% c("FEV1", "FVC", "FEV1FVC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FEV1" = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline +
                     (log(1 - 1.645 * 1.22703 * 
                            exp(-2.256278 + 0.080729*log(age) + sspline)) / 1.22703)),
      "FVC" = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline +
                    (log(1 - 1.645 * 0.9346 * 
                          exp(-2.195595 + 0.068466*log(age) + sspline)) / 0.9346)),
      "FEV1FVC" = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline +
                        (log(1 - 1.645 * (3.8243 - 0.3328*log(age)) * 
                              exp(-2.882025 + 0.068889*log(age) + sspline)) / 
                           (3.8243 - 0.3328*log(age))))
    ),
    # Female equations
    switch(
      param,
      "FEV1" = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) + mspline +
                     (log(1 - 1.645 * 1.21388 * 
                           exp(-2.364047 + 0.129402*log(age) + sspline)) / 1.21388)),
      "FVC" = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline +
                    log(1 - 1.645 * 0.899 * 
                          exp(-2.310148 + 0.120428*log(age) + sspline)) / 0.899),
      "FEV1FVC" = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline +
                        (log(1 - 1.645 * (6.6490 - 0.9920*log(age)) * 
                              exp(-3.171582 + 0.144358*log(age) + sspline)) / 
                           (6.6490 - 0.9920*log(age))))
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Upper Limit of Normal (ULN)
#'
#' Calculate upper limit of normal (95th percentile) using GLI 2021 Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Spirometric parameter ("FEV1", "FVC", or "FEV1FVC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Upper limit of normal in liters (or ratio for FEV1/FVC)
#'
#' @export
#' @examples
#' # Calculate ULN for FVC
#' compute_gli_uln(sex = "Female", ht = 165, age = 55, param = "FVC")
compute_gli_uln <- function(sex, ht, ht_unit = "cm", age, param = "FEV1", ...) {
  stopifnot(param %in% c("FEV1", "FVC", "FEV1FVC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FEV1" = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline +
                     (log(1 + 1.645 * 1.22703 * 
                           exp(-2.256278 + 0.080729*log(age) + sspline)) / 1.22703)),
      "FVC" = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline +
                    (log(1 + 1.645 * 0.9346 * 
                          exp(-2.195595 + 0.068466*log(age) + sspline)) / 0.9346)),
      "FEV1FVC" = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline +
                        (log(1 + 1.645 * (3.8243 - 0.3328*log(age)) * 
                              exp(-2.882025 + 0.068889*log(age) + sspline)) / 
                           (3.8243 - 0.3328*log(age))))
    ),
    # Female equations
    switch(
      param,
      "FEV1" = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) + mspline +
                     (log(1 + 1.645 * 1.21388 * 
                           exp(-2.364047 + 0.129402*log(age) + sspline)) / 1.21388)),
      "FVC" = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline +
                    log(1 + 1.645 * 0.899 * 
                          exp(-2.310148 + 0.120428*log(age) + sspline)) / 0.899),
      "FEV1FVC" = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline +
                        (log(1 + 1.645 * (6.6490 - 0.9920*log(age)) * 
                              exp(-3.171582 + 0.144358*log(age) + sspline)) / 
                           (6.6490 - 0.9920*log(age))))
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Z-Score
#'
#' Calculate z-score for measured spirometric values using GLI 2021 Global equations.
#' Z-score formula: ((measured/M)^L - 1)/(L*S)
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured spirometric value in liters (or ratio for FEV1/FVC)
#' @param param Character. Spirometric parameter ("FEV1", "FVC", or "FEV1FVC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Z-score (standard deviations from predicted mean)
#'
#' @details
#' A z-score < -1.645 indicates the value is below the lower limit of normal (LLN).
#' A z-score > +1.645 indicates the value is above the upper limit of normal (ULN).
#'
#' @export
#' @examples
#' # Calculate z-score for measured FEV1 of 3.2 L
#' compute_gli_zscore(sex = "Male", ht = 175, age = 45, 
#'                    measured = 3.2, param = "FEV1")
compute_gli_zscore <- function(sex, ht, ht_unit = "cm", age, measured, 
                               param = "FEV1", ...) {
  stopifnot(param %in% c("FEV1", "FVC", "FEV1FVC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FEV1" = (((measured / (exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline)))^1.22703) - 1) /
        (1.22703 * (exp(-2.256278 + 0.080729*log(age) + sspline))),
      "FVC" = ((measured / exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline))^0.9346 - 1) /
        (0.9346 * exp(-2.195595 + 0.068466*log(age) + sspline)),
      "FEV1FVC" = ((measured / exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline))^(3.8243 - 0.3328*log(age)) - 1) /
        ((3.8243 - 0.3328*log(age)) * exp(-2.882025 + 0.068889*log(age) + sspline))
    ),
    # Female equations
    switch(
      param,
      "FEV1" = ((measured / exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) + mspline))^1.21388 - 1) /
        (1.21388 * exp(-2.364047 + 0.129402*log(age) + sspline)),
      "FVC" = ((measured / exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline))^0.899 - 1) /
        (0.899 * exp(-2.310148 + 0.120428*log(age) + sspline)),
      "FEV1FVC" = ((measured / exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline))^(6.6490 - 0.9920*log(age)) - 1) /
        ((6.6490 - 0.9920*log(age)) * exp(-3.171582 + 0.144358*log(age) + sspline))
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Percent Predicted
#'
#' Calculate percent predicted for measured spirometric values.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured spirometric value in liters (or ratio for FEV1/FVC)
#' @param param Character. Spirometric parameter ("FEV1", "FVC", or "FEV1FVC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Percent predicted value
#'
#' @export
#' @examples
#' # Calculate percent predicted for measured FVC of 4.5 L
#' compute_gli_percent_pred(sex = "Female", ht = 165, age = 55, 
#'                          measured = 4.5, param = "FVC")
compute_gli_percent_pred <- function(sex, ht, ht_unit = "cm", age, measured, 
                                     param = "FEV1", ...) {
  pred <- compute_gli_pred(sex = sex, ht = ht, ht_unit = ht_unit, 
                           age = age, param = param)
  return((measured / pred) * 100)
}