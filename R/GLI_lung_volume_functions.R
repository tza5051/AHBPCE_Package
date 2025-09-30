#' Lookup GLI 2021 Lung Volume Spline Values
#'
#' Helper function to extract M spline and S spline values from lung volume lookup tables
#' based on age, sex, and lung volume parameter.
#'
#' @param age Numeric. Age in years
#' @param sex Character. Sex ("M", "Male", "MALE", "F", "Female", "FEMALE")
#' @param variable Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
#'
#' @return List with Mspline and Sspline values
#' @keywords internal
lookup_spline_lv <- function(age, sex, variable) {
  # SplineSheetsLV should be available from sysdata.rda
  
  if (variable == "FRC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[1]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[2]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "TLC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[3]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[4]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "RV") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[5]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[6]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "RVTLC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[7]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[8]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "ERV") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[9]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[10]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "IC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[11]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[12]][, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "VC") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsLV[[13]][, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsLV[[14]][, c("age", "Mspline", "Sspline")]
    }
  }
  
  # Find the closest age from the lookup table
  age_delta <- abs(spline_tab$age - age)
  s <- which.min(age_delta)
  
  ret <- list(Mspline = spline_tab$Mspline[s], 
              Sspline = spline_tab$Sspline[s])
  return(ret)
}


#' Compute GLI 2021 Lung Volume Predicted Values
#'
#' Calculate predicted lung volume values using GLI 2021 Global (race-neutral) equations.
#' Based on GLI 2021 lung volume reference equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Predicted value in liters (or ratio for RV/TLC)
#' 
#' @details
#' Lung volume parameters:
#' \itemize{
#'   \item FRC: Functional Residual Capacity
#'   \item TLC: Total Lung Capacity
#'   \item RV: Residual Volume
#'   \item RVTLC: RV/TLC ratio
#'   \item ERV: Expiratory Reserve Volume
#'   \item IC: Inspiratory Capacity
#'   \item VC: Vital Capacity
#' }
#'
#' @references
#' GLI 2021 Lung Volume equations
#'
#' @export
#' @examples
#' # Calculate predicted TLC for a 45-year-old male, 175 cm tall
#' compute_gli_lv_pred(sex = "Male", ht = 175, age = 45, param = "TLC")
#' 
#' # Calculate predicted FRC for a 60-year-old female, 65 inches tall
#' compute_gli_lv_pred(sex = "Female", ht = 65, ht_unit = "in", age = 60, param = "FRC")
compute_gli_lv_pred <- function(sex, ht, ht_unit = "cm", age, param = "FRC", ...) {
  stopifnot(param %in% c("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54  # Convert inches to cm
  }
  
  # Look up values for Mspline and Sspline
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_lv(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FRC" = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline),
      "TLC" = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline),
      "RV" = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline),
      "RVTLC" = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline),
      "ERV" = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline),
      "IC" = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline),
      "VC" = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline)
    ),
    # Female equations
    switch(
      param,
      "FRC" = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline),
      "TLC" = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline),
      "RV" = exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline),
      "RVTLC" = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline),
      "ERV" = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline),
      "IC" = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline),
      "VC" = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline)
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Lung Volume Lower Limit of Normal (LLN)
#'
#' Calculate lower limit of normal (5th percentile) for lung volumes using GLI 2021 Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Lower limit of normal in liters (or ratio for RV/TLC)
#'
#' @export
#' @examples
#' # Calculate LLN for TLC
#' compute_gli_lv_lln(sex = "Male", ht = 175, age = 45, param = "TLC")
compute_gli_lv_lln <- function(sex, ht, ht_unit = "cm", age, param = "FRC", ...) {
  stopifnot(param %in% c("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_lv(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FRC" = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.3416 * 
                          exp(-1.60197 + 0.01513 * log(age) + sspline)) / 0.3416),
      "TLC" = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline +
                    log(1 - 1.645 * 0.9337 * 
                          exp(-2.0616143 - 0.0008534 * age + sspline)) / 0.9337),
      "RV" = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline + 
                   log(1 - 1.645 * 0.5931 * 
                         exp(-0.878572 - 0.007032 * age + sspline)) / 0.5931),
      "RVTLC" = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline + 
                      log(1 - 1.645 * 0.8646 * 
                            exp(-0.96804 - 0.01004 * age + sspline)) / 0.8646),
      "ERV" = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline +
                    log(1 - 1.645 * 0.5517 * 
                          exp(-1.307616 + 0.009177 * age)) / 0.5517),
      "IC" = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline + 
                   log(1 - 1.645 * 1.146 * 
                         exp(-1.856546 + 0.002008 * age)) / 1.146),
      "VC" = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline +
                   log(1 - 1.645 * 0.8611 * 
                         exp(-2.1367411 + 0.0009367 * age)) / 0.8611)
    ),
    # Female equations
    switch(
      param,
      "FRC" = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.2898 * 
                          exp(-1.48310 - 0.03372 * log(age) + sspline)) / 0.2898),
      "TLC" = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.4636 * 
                          exp(-2.0999321 + 0.0001564 * age + sspline)) / 0.4636),
      "RV" = exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline + 
                   log(1 - 1.645 * 0.4197 * 
                         exp(-0.902550 - 0.006005 * age + sspline)) / 0.4197),
      "RVTLC" = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline +
                      log(1 - 1.645 * 0.8037 * 
                            exp(-0.976602 - 0.009679 * age + sspline)) / 0.8037),
      "ERV" = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline +
                    log(1 - 1.645 * 0.5326 * 
                          exp(-1.54992 + 0.01409 * age)) / 0.5326),
      "IC" = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline +
                   log(1 - 1.645 * 0.9726 * 
                         exp(-1.775276 + 0.002673 * age)) / 0.9726),
      "VC" = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline +
                   log(1 - 1.645 * 1.038 * 
                         exp(-2.220260 + 0.002956 * age)) / 1.038)
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Lung Volume Upper Limit of Normal (ULN)
#'
#' Calculate upper limit of normal (95th percentile) for lung volumes using GLI 2021 Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Upper limit of normal in liters (or ratio for RV/TLC)
#'
#' @export
#' @examples
#' # Calculate ULN for RV
#' compute_gli_lv_uln(sex = "Female", ht = 165, age = 55, param = "RV")
compute_gli_lv_uln <- function(sex, ht, ht_unit = "cm", age, param = "FRC", ...) {
  stopifnot(param %in% c("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_lv(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FRC" = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.3416 * 
                          exp(-1.60197 + 0.01513 * log(age) + sspline)) / 0.3416),
      "TLC" = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline +
                    log(1 + 1.645 * 0.9337 * 
                          exp(-2.0616143 - 0.0008534 * age + sspline)) / 0.9337),
      "RV" = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline + 
                   log(1 + 1.645 * 0.5931 * 
                         exp(-0.878572 - 0.007032 * age + sspline)) / 0.5931),
      "RVTLC" = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline + 
                      log(1 + 1.645 * 0.8646 * 
                            exp(-0.96804 - 0.01004 * age + sspline)) / 0.8646),
      "ERV" = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline +
                    log(1 + 1.645 * 0.5517 * 
                          exp(-1.307616 + 0.009177 * age)) / 0.5517),
      "IC" = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline + 
                   log(1 + 1.645 * 1.146 * 
                         exp(-1.856546 + 0.002008 * age)) / 1.146),
      "VC" = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline +
                   log(1 + 1.645 * 0.8611 * 
                         exp(-2.1367411 + 0.0009367 * age)) / 0.8611)
    ),
    # Female equations
    switch(
      param,
      "FRC" = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.2898 * 
                          exp(-1.48310 - 0.03372 * log(age) + sspline)) / 0.2898),
      "TLC" = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.4636 * 
                          exp(-2.0999321 + 0.0001564 * age + sspline)) / 0.4636),
      "RV" = exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline + 
                   log(1 + 1.645 * 0.4197 * 
                         exp(-0.902550 - 0.006005 * age + sspline)) / 0.4197),
      "RVTLC" = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline +
                      log(1 + 1.645 * 0.8037 * 
                            exp(-0.976602 - 0.009679 * age + sspline)) / 0.8037),
      "ERV" = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline +
                    log(1 + 1.645 * 0.5326 * 
                          exp(-1.54992 + 0.01409 * age)) / 0.5326),
      "IC" = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline +
                   log(1 + 1.645 * 0.9726 * 
                         exp(-1.775276 + 0.002673 * age)) / 0.9726),
      "VC" = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline +
                   log(1 + 1.645 * 1.038 * 
                         exp(-2.220260 + 0.002956 * age)) / 1.038)
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Lung Volume Z-Score
#'
#' Calculate z-score for measured lung volume values using GLI 2021 Global equations.
#' Z-score formula: ((measured/M)^L - 1)/(L*S)
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured lung volume value in liters (or ratio for RV/TLC)
#' @param param Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
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
#' # Calculate z-score for measured TLC of 6.5 L
#' compute_gli_lv_zscore(sex = "Male", ht = 175, age = 45, 
#'                       measured = 6.5, param = "TLC")
compute_gli_lv_zscore <- function(sex, ht, ht_unit = "cm", age, measured, 
                                  param = "FRC", ...) {
  stopifnot(param %in% c("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_lv(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "FRC" = ((measured / exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline))^0.3416 - 1) / 
        (0.3416 * exp(-1.60197 + 0.01513 * log(age) + sspline)),
      "TLC" = ((measured / exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline))^0.9337 - 1) / 
        (0.9337 * exp(-2.0616143 - 0.0008534 * age + sspline)),
      "RV" = ((measured / exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline))^0.5931 - 1) / 
        (0.5931 * exp(-0.878572 - 0.007032 * age + sspline)),
      "RVTLC" = ((measured / exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline))^0.8646 - 1) / 
        (0.8646 * exp(-0.96804 - 0.01004 * age + sspline)),
      "ERV" = ((measured / exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline))^0.5517 - 1) / 
        (0.5517 * exp(-1.307616 + 0.009177 * age)),
      "IC" = ((measured / exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline))^1.146 - 1) / 
        (1.146 * exp(-1.856546 + 0.002008 * age)),
      "VC" = ((measured / exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline))^0.8611 - 1) / 
        (0.8611 * exp(-2.1367411 + 0.0009367 * age))
    ),
    # Female equations
    switch(
      param,
      "FRC" = ((measured / exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline))^0.2898 - 1) / 
        (0.2898 * exp(-1.48310 - 0.03372 * log(age) + sspline)),
      "TLC" = ((measured / exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline))^0.4636 - 1) / 
        (0.4636 * exp(-2.0999321 + 0.0001564 * age + sspline)),
      "RV" = ((measured / exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline))^0.4197 - 1) / 
        (0.4197 * exp(-0.902550 - 0.006005 * age + sspline)),
      "RVTLC" = ((measured / exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline))^0.8037 - 1) /
        (0.8037 * exp(-0.976602 - 0.009679 * age + sspline)),
      "ERV" = ((measured / exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline))^0.5326 - 1) / 
        (0.5326 * exp(-1.54992 + 0.01409 * age)),
      "IC" = ((measured / exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline))^0.9726 - 1) / 
        (0.9726 * exp(-1.775276 + 0.002673 * age)),
      "VC" = ((measured / exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline))^1.038 - 1) / 
        (1.038 * exp(-2.220260 + 0.002956 * age))
    )
  )
  
  return(ret)
}


#' Compute GLI 2021 Lung Volume Percent Predicted
#'
#' Calculate percent predicted for measured lung volume values.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured lung volume value in liters (or ratio for RV/TLC)
#' @param param Character. Lung volume parameter ("FRC", "TLC", "RV", "RVTLC", "ERV", "IC", "VC")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Percent predicted value
#'
#' @export
#' @examples
#' # Calculate percent predicted for measured TLC of 6.5 L
#' compute_gli_lv_percent_pred(sex = "Male", ht = 175, age = 45, 
#'                             measured = 6.5, param = "TLC")
compute_gli_lv_percent_pred <- function(sex, ht, ht_unit = "cm", age, measured, 
                                        param = "FRC", ...) {
  pred <- compute_gli_lv_pred(sex = sex, ht = ht, ht_unit = ht_unit, 
                              age = age, param = param)
  return((measured / pred) * 100)
}