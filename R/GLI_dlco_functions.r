#' Lookup GLI DLCO Spline Values
#'
#' Helper function to extract M spline and S spline values from DLCO lookup tables
#' based on age, sex, and DLCO parameter.
#'
#' @param age Numeric. Age in years
#' @param sex Character. Sex ("M", "Male", "MALE", "F", "Female", "FEMALE")
#' @param variable Character. DLCO parameter ("DLCO", "KCO", "VA")
#'
#' @return List with Mspline and Sspline values
#' @keywords internal
lookup_spline_dlco <- function(age, sex, variable) {
  # SplineSheetsDLCO should be available from sysdata.rda
  
  if (variable == "DLCO") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsDLCO$TLCO_male[, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsDLCO$TLCO_female[, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "KCO") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsDLCO$KCO_male[, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsDLCO$KCO_female[, c("age", "Mspline", "Sspline")]
    }
  } else if (variable == "VA") {
    if (sex %in% c("M", "Male", "MALE")) {
      spline_tab <- SplineSheetsDLCO$VA_male[, c("age", "Mspline", "Sspline")]
    } else {
      spline_tab <- SplineSheetsDLCO$VA_female[, c("age", "Mspline", "Sspline")]
    }
  }
  
  # Find the closest age from the lookup table
  age_delta <- abs(spline_tab$age - age)
  s <- which.min(age_delta)
  
  ret <- list(Mspline = spline_tab$Mspline[s], 
              Sspline = spline_tab$Sspline[s])
  return(ret)
}


#' Compute GLI DLCO Predicted Values
#'
#' Calculate predicted DLCO values using GLI Global equations.
#' DLCO (also called TLCO) measures diffusing capacity of the lungs for carbon monoxide.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. DLCO parameter ("DLCO", "KCO", "VA")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Predicted value in mmol/min/kPa (DLCO), mmol/min/kPa/L (KCO), or L (VA)
#' 
#' @details
#' DLCO parameters:
#' \itemize{
#'   \item DLCO (TLCO): Transfer factor (diffusing capacity) of the lung for CO
#'   \item KCO: Transfer coefficient (DLCO corrected for alveolar volume)
#'   \item VA: Alveolar volume
#' }
#'
#' @references
#' Stanojevic S, et al. GLI-2017 ERS/ATS standards for single-breath carbon 
#' monoxide uptake in the lung. Eur Respir J. 2017.
#'
#' @export
#' @examples
#' # Calculate predicted DLCO for a 45-year-old male, 175 cm tall
#' compute_gli_dlco_pred(sex = "Male", ht = 175, age = 45, param = "DLCO")
#' 
#' # Calculate predicted KCO for a 60-year-old female, 65 inches tall
#' compute_gli_dlco_pred(sex = "Female", ht = 65, ht_unit = "in", age = 60, param = "KCO")
compute_gli_dlco_pred <- function(sex, ht, ht_unit = "cm", age, param = "DLCO", ...) {
  stopifnot(param %in% c("DLCO", "KCO", "VA"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54  # Convert inches to cm
  }
  
  # Look up values for Mspline and Sspline
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_dlco(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "DLCO" = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline),
      "KCO" = exp(4.088408 - 0.415334 * log(ht) - 0.113166 * log(age) + mspline),
      "VA" = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline)
    ),
    # Female equations
    switch(
      param,
      "DLCO" = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline),
      "KCO" = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline),
      "VA" = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline)
    )
  )
  
  return(ret)
}


#' Compute GLI DLCO Lower Limit of Normal (LLN)
#'
#' Calculate lower limit of normal (5th percentile) for DLCO using GLI Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. DLCO parameter ("DLCO", "KCO", "VA")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Lower limit of normal
#'
#' @export
#' @examples
#' # Calculate LLN for DLCO
#' compute_gli_dlco_lln(sex = "Male", ht = 175, age = 45, param = "DLCO")
compute_gli_dlco_lln <- function(sex, ht, ht_unit = "cm", age, param = "DLCO", ...) {
  stopifnot(param %in% c("DLCO", "KCO", "VA"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_dlco(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "DLCO" = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline +
                     log(1 - 1.645 * 0.39482 * 
                           exp(-1.98996 + 0.03536 * log(age) + sspline)) / 0.39482),
      "KCO" = exp(4.088408 - 0.415334 * log(ht) - 0.113166 * log(age) + mspline +
                    log(1 - 1.645 * 0.67330 * 
                          exp(-1.98186 + 0.01460 * log(age) + sspline)) / 0.67330),
      "VA" = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline +
                   log(1 - 1.645 * 0.62559 * 
                         exp(-2.20953 + 0.01937 * log(age) + sspline)) / 0.62559)
    ),
    # Female equations
    switch(
      param,
      "DLCO" = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline +
                     log(1 - 1.645 * 0.24160 * 
                           exp(-1.82905 - 0.01815 * log(age) + sspline)) / 0.24160),
      "KCO" = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline +
                    log(1 - 1.645 * 0.48963 * 
                          exp(-1.63787 - 0.07757 * log(age) + sspline)) / 0.48963),
      "VA" = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline +
                   log(1 - 1.645 * 0.51919 * 
                         exp(-2.08839 - 0.01334 * log(age) + sspline)) / 0.51919)
    )
  )
  
  return(ret)
}


#' Compute GLI DLCO Upper Limit of Normal (ULN)
#'
#' Calculate upper limit of normal (95th percentile) for DLCO using GLI Global equations.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param param Character. DLCO parameter ("DLCO", "KCO", "VA")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Upper limit of normal
#'
#' @export
#' @examples
#' # Calculate ULN for KCO
#' compute_gli_dlco_uln(sex = "Female", ht = 165, age = 55, param = "KCO")
compute_gli_dlco_uln <- function(sex, ht, ht_unit = "cm", age, param = "DLCO", ...) {
  stopifnot(param %in% c("DLCO", "KCO", "VA"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_dlco(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "DLCO" = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline +
                     log(1 + 1.645 * 0.39482 * 
                           exp(-1.98996 + 0.03536 * log(age) + sspline)) / 0.39482),
      "KCO" = exp(4.088408 - 0.415334 * log(ht) - 0.113166 * log(age) + mspline +
                    log(1 + 1.645 * 0.67330 * 
                          exp(-1.98186 + 0.01460 * log(age) + sspline)) / 0.67330),
      "VA" = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline +
                   log(1 + 1.645 * 0.62559 * 
                         exp(-2.20953 + 0.01937 * log(age) + sspline)) / 0.62559)
    ),
    # Female equations
    switch(
      param,
      "DLCO" = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline +
                     log(1 + 1.645 * 0.24160 * 
                           exp(-1.82905 - 0.01815 * log(age) + sspline)) / 0.24160),
      "KCO" = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline +
                    log(1 + 1.645 * 0.48963 * 
                          exp(-1.63787 - 0.07757 * log(age) + sspline)) / 0.48963),
      "VA" = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline +
                   log(1 + 1.645 * 0.51919 * 
                         exp(-2.08839 - 0.01334 * log(age) + sspline)) / 0.51919)
    )
  )
  
  return(ret)
}


#' Compute GLI DLCO Z-Score
#'
#' Calculate z-score for measured DLCO values using GLI Global equations.
#' Z-score formula: ((measured/M)^L - 1)/(L*S)
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured DLCO value
#' @param param Character. DLCO parameter ("DLCO", "KCO", "VA")
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
#' # Calculate z-score for measured DLCO of 8.5 mmol/min/kPa
#' compute_gli_dlco_zscore(sex = "Male", ht = 175, age = 45, 
#'                         measured = 8.5, param = "DLCO")
compute_gli_dlco_zscore <- function(sex, ht, ht_unit = "cm", age, measured, 
                                    param = "DLCO", ...) {
  stopifnot(param %in% c("DLCO", "KCO", "VA"))
  
  if (ht_unit == "in") {
    ht <- ht * 2.54
  }
  
  lookup_res <- mapply(FUN = function(x, y, z) lookup_spline_dlco(x, y, z), 
                       age, sex, param)
  mspline <- unlist(lookup_res["Mspline", ])
  sspline <- unlist(lookup_res["Sspline", ])
  
  param <- toupper(param)
  
  ret <- ifelse(
    sex %in% c("M", "Male", "MALE"),
    # Male equations
    switch(
      param,
      "DLCO" = (((measured / (exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline)))^0.39482) - 1) / 
        (0.39482 * (exp(-1.98996 + 0.03536 * log(age) + sspline))),
      "KCO" = (((measured / exp(4.088408 - 0.415334 * log(ht) - 0.113166 * log(age) + mspline))^0.67330) - 1) / 
        (0.67330 * exp(-1.98186 + 0.01460 * log(age) + sspline)),
      "VA" = (((measured / exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline))^0.62559) - 1) /
        (0.62559 * (exp(-2.20953 + 0.01937 * log(age) + sspline)))
    ),
    # Female equations
    switch(
      param,
      "DLCO" = (((measured / exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline))^0.24160) - 1) /
        (0.24160 * (exp(-1.82905 - 0.01815 * log(age) + sspline))),
      "KCO" = (((measured / exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline))^0.48963) - 1) /
        (0.48963 * exp(-1.63787 - 0.07757 * log(age) + sspline)),
      "VA" = (((measured / exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline))^0.51919) - 1) /
        (0.51919 * exp(-2.08839 - 0.01334 * log(age) + sspline))
    )
  )
  
  return(ret)
}


#' Compute GLI DLCO Percent Predicted
#'
#' Calculate percent predicted for measured DLCO values.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param ht Numeric. Height value
#' @param ht_unit Character. Height unit ("cm" or "in"). Default is "cm"
#' @param age Numeric. Age in years
#' @param measured Numeric. Measured DLCO value
#' @param param Character. DLCO parameter ("DLCO", "KCO", "VA")
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Percent predicted value
#'
#' @export
#' @examples
#' # Calculate percent predicted for measured DLCO of 8.5 mmol/min/kPa
#' compute_gli_dlco_percent_pred(sex = "Male", ht = 175, age = 45, 
#'                               measured = 8.5, param = "DLCO")
compute_gli_dlco_percent_pred <- function(sex, ht, ht_unit = "cm", age, measured, 
                                          param = "DLCO", ...) {
  pred <- compute_gli_dlco_pred(sex = sex, ht = ht, ht_unit = ht_unit, 
                                age = age, param = param)
  return((measured / pred) * 100)
}


#' Apply Miller Correction to DLCO
#'
#' Correct DLCO for hemoglobin using the Miller correction formula.
#' This adjusts DLCO measurements for anemia or polycythemia.
#'
#' @param sex Character. Sex ("M", "Male", "MALE" for males; "F", "Female", "FEMALE" for females)
#' @param hgb Numeric. Hemoglobin concentration in g/dL
#' @param measured Numeric. Measured DLCO value in mmol/min/kPa
#' @param ... Additional arguments (not currently used)
#'
#' @return Numeric. Hemoglobin-corrected DLCO value
#'
#' @details
#' The Miller correction adjusts DLCO for abnormal hemoglobin levels:
#' \itemize{
#'   \item Males: Uses reference Hgb of 10.22 + measured Hgb
#'   \item Females: Uses reference Hgb of 9.38 + measured Hgb
#' }
#' 
#' Normal hemoglobin ranges:
#' \itemize{
#'   \item Males: 13.5-17.5 g/dL
#'   \item Females: 12.0-15.5 g/dL
#' }
#'
#' @references
#' Miller A, et al. Effect of anemia on pulmonary diffusing capacity. 
#' Am Rev Respir Dis. 1980.
#'
#' @export
#' @examples
#' # Correct DLCO for a male with hemoglobin of 11.0 g/dL (anemic)
#' compute_miller_correction(sex = "Male", hgb = 11.0, measured = 8.5)
#' 
#' # Correct DLCO for a female with hemoglobin of 10.5 g/dL
#' compute_miller_correction(sex = "Female", hgb = 10.5, measured = 7.2)
compute_miller_correction <- function(sex, hgb, measured, ...) {
  dlco_corrected <- measured * (1.7 * hgb / ifelse(
    sex %in% c("M", "Male", "MALE"), 
    (10.22 + hgb), 
    (9.38 + hgb)
  ))
  
  return(dlco_corrected)
}