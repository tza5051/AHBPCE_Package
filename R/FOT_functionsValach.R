## +++++++++++++++++++++ FOT Valach Resistance Functions +++++++++++++++++++++++++++ ##
#   Package: AHBPCEPredR
#   Forced Oscillation Technique - Valach/LEAD 2025 Reference Equations
##------
# Reference equations for respiratory resistance at 5, 11, and 19 Hz
# Based on: Valach et al., Austrian LEAD study population
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

#' Calculate Predicted Resistance (Valach/LEAD)
#'
#' Computes predicted respiratory system resistance using Valach et al. reference equations
#' from the Austrian LEAD study population. Resistance measurements reflect total respiratory
#' system resistance (airways + tissue).
#'
#' @param sex Character string: "Male" or "Female"
#' @param ht Numeric: Height value
#' @param ht_unit Character: "cm" (default) or "in" for height units
#' @param age Numeric: Age in years
#' @param weight Numeric: Weight value
#' @param weight_unit Character: "kg" (default) or "lbs" for weight units
#' @param frequency Character: Oscillation frequency - "5", "11", or "19" (Hz)
#' @param ... Additional arguments (ignored)
#'
#' @return Numeric: Predicted resistance (hPa·s·L⁻¹)
#'
#' @details
#' The Valach equations use GAMLSS methodology with BMI as a predictor.
#' Valid frequencies: 5, 11, 19 Hz
#' 
#' Equation incorporates:
#' - Sex-specific coefficients
#' - Height (log-transformed for some frequencies)
#' - Age (log-transformed for some frequencies)
#' - BMI (log-transformed for some frequencies)
#'
#' @references
#' Valach et al. Austrian LEAD study (2025)
#'
#' @examples
#' # Male, 180 cm, 50 years, 80 kg at 5 Hz
#' compute_valach_r_pred(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
#'
#' # Female using imperial units at 11 Hz
#' compute_valach_r_pred(sex = "Female", ht = 65, ht_unit = "in", 
#'                       age = 45, weight = 140, weight_unit = "lbs", frequency = "11")
#'
#' @export
compute_valach_r_pred <- function(sex, ht, ht_unit = "cm", age, weight, 
                                   weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate predicted resistance based on frequency and sex
  predicted <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ 
      exp(9.10454079 + (-1.94365016 * height_log) + (-0.13493079 * age_log) + (0.73359356 * bmi_log)),
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ 
      exp(1.00281496 + (-0.01146274 * ht) + (-0.00236143 * age) + (0.62277905 * bmi_log)),
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ 
      exp(1.27951905 + (-0.00820938 * ht) + (-0.0039901 * age) + (0.37558144 * bmi_log)),
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ 
      exp(1.51176089 + (-0.00581226 * ht) + (-0.00194815 * age) + (0.02946239 * bmi)),
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ 
      exp(1.55468797 + (-0.00579631 * ht) + (-0.00128173 * age) + (0.02334934 * bmi)),
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ 
      exp(1.39302074 + (-0.00335726 * ht) + (-0.0031946 * age) + (0.01774499 * bmi)),
    
    TRUE ~ NA_real_
  )
  
  return(predicted)
}


#' Calculate Lower Limit of Normal for Resistance (Valach/LEAD)
#'
#' Computes the lower limit of normal (5th percentile, z-score = -1.645) for respiratory
#' resistance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_r_pred
#'
#' @return Numeric: LLN for resistance (hPa·s·L⁻¹)
#'
#' @details
#' LLN calculated using GAMLSS Box-Cox transformation:
#' LLN = M × (-1.645 × S × L + 1)^(1/L)
#' where M = predicted median, S = coefficient of variation, L = Box-Cox parameter
#'
#' @examples
#' # Check if measured resistance is below LLN
#' lln <- compute_valach_r_lln(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
#' measured <- 0.25
#' is_below_lln <- measured < lln
#'
#' @export
compute_valach_r_lln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate LLN using GAMLSS equations
  lln <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.10454079 + (-1.94365016 * height_log) + (-0.13493079 * age_log) + (0.73359356 * bmi_log))
      S <- exp(3.39897015 + (-0.89954098 * height_log) + (0.18722026 * age_log) + (-0.2363505 * bmi_log))
      L <- 22.96212585 + (-4.19150238 * height_log) + (0.23357827 * age_log) + (-0.74956753 * bmi_log)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.00281496 + (-0.01146274 * ht) + (-0.00236143 * age) + (0.62277905 * bmi_log))
      S <- exp(0.14838989 + (-0.00468145 * ht) + (0.00174169 * age) + (-0.25023483 * bmi_log))
      L <- 11.53948419 + (-0.02258354 * ht) + (0.00181158 * age) + (-2.45928703 * bmi_log)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.27951905 + (-0.00820938 * ht) + (-0.0039901 * age) + (0.37558144 * bmi_log))
      S <- exp(-0.14097405 + (-0.00801434 * ht) + (0.00087917 * age) + (0.00209106 * bmi_log))
      L <- 15.63479312 + (-0.02224631 * ht) + (0.00523639 * age) + (-3.80871449 * bmi_log)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.51176089 + (-0.00581226 * ht) + (-0.00194815 * age) + (0.02946239 * bmi))
      S <- exp(-1.62848204 + (-3.48e-05 * ht) + (0.00684834 * age) + (-0.00141105 * bmi))
      L <- 0.04517853 + (-0.01529633 * ht) + (0.01618496 * age) + (0.05140252 * bmi)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.55468797 + (-0.00579631 * ht) + (-0.00128173 * age) + (0.02334934 * bmi))
      S <- exp(-1.50409754 + (-0.00159016 * ht) + (0.00538724 * age) + (0.0039368 * bmi))
      L <- 0.0580996 + (-0.02320459 * ht) + (0.02235644 * age) + (0.08854164 * bmi)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.39302074 + (-0.00335726 * ht) + (-0.0031946 * age) + (0.01774499 * bmi))
      S <- exp(-1.33716494 + (-0.00342657 * ht) + (0.00579859 * age) + (0.00435456 * bmi))
      L <- 0.40685746 + (-0.03221751 * ht) + (0.01570796 * age) + (0.14510401 * bmi)
      M * (-1.645 * S * L + 1)^(1/L)
    },
    
    TRUE ~ NA_real_
  )
  
  return(lln)
}


#' Calculate Upper Limit of Normal for Resistance (Valach/LEAD)
#'
#' Computes the upper limit of normal (95th percentile, z-score = +1.645) for respiratory
#' resistance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_r_pred
#'
#' @return Numeric: ULN for resistance (hPa·s·L⁻¹)
#'
#' @details
#' ULN calculated using GAMLSS Box-Cox transformation:
#' ULN = M × (1.645 × S × L + 1)^(1/L)
#' 
#' Values above ULN suggest elevated respiratory resistance.
#'
#' @examples
#' # Check if measured resistance is elevated
#' uln <- compute_valach_r_uln(sex = "Female", ht = 165, age = 55, weight = 65, frequency = "5")
#' measured <- 0.50
#' is_elevated <- measured > uln
#'
#' @export
compute_valach_r_uln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate ULN using GAMLSS equations
  uln <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.10454079 + (-1.94365016 * height_log) + (-0.13493079 * age_log) + (0.73359356 * bmi_log))
      S <- exp(3.39897015 + (-0.89954098 * height_log) + (0.18722026 * age_log) + (-0.2363505 * bmi_log))
      L <- 22.96212585 + (-4.19150238 * height_log) + (0.23357827 * age_log) + (-0.74956753 * bmi_log)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.00281496 + (-0.01146274 * ht) + (-0.00236143 * age) + (0.62277905 * bmi_log))
      S <- exp(0.14838989 + (-0.00468145 * ht) + (0.00174169 * age) + (-0.25023483 * bmi_log))
      L <- 11.53948419 + (-0.02258354 * ht) + (0.00181158 * age) + (-2.45928703 * bmi_log)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.27951905 + (-0.00820938 * ht) + (-0.0039901 * age) + (0.37558144 * bmi_log))
      S <- exp(-0.14097405 + (-0.00801434 * ht) + (0.00087917 * age) + (0.00209106 * bmi_log))
      L <- 15.63479312 + (-0.02224631 * ht) + (0.00523639 * age) + (-3.80871449 * bmi_log)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.51176089 + (-0.00581226 * ht) + (-0.00194815 * age) + (0.02946239 * bmi))
      S <- exp(-1.62848204 + (-3.48e-05 * ht) + (0.00684834 * age) + (-0.00141105 * bmi))
      L <- 0.04517853 + (-0.01529633 * ht) + (0.01618496 * age) + (0.05140252 * bmi)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.55468797 + (-0.00579631 * ht) + (-0.00128173 * age) + (0.02334934 * bmi))
      S <- exp(-1.50409754 + (-0.00159016 * ht) + (0.00538724 * age) + (0.0039368 * bmi))
      L <- 0.0580996 + (-0.02320459 * ht) + (0.02235644 * age) + (0.08854164 * bmi)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.39302074 + (-0.00335726 * ht) + (-0.0031946 * age) + (0.01774499 * bmi))
      S <- exp(-1.33716494 + (-0.00342657 * ht) + (0.00579859 * age) + (0.00435456 * bmi))
      L <- 0.40685746 + (-0.03221751 * ht) + (0.01570796 * age) + (0.14510401 * bmi)
      M * (1.645 * S * L + 1)^(1/L)
    },
    
    TRUE ~ NA_real_
  )
  
  return(uln)
}


#' Calculate Z-Score for Resistance (Valach/LEAD)
#'
#' Computes the z-score for measured respiratory resistance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_r_pred
#' @param measured Numeric: Measured resistance value (hPa·s·L⁻¹)
#'
#' @return Numeric: Z-score (standard deviation units)
#'
#' @details
#' Z-score formula: ((measured/M)^L - 1) / (S × L)
#' 
#' Interpretation:
#' - Z < -1.645: Below LLN (unusually low resistance)
#' - -1.645 ≤ Z ≤ +1.645: Normal range
#' - Z > +1.645: Above ULN (elevated resistance)
#'
#' @examples
#' # Calculate z-score for measured resistance
#' zscore <- compute_valach_r_zscore(sex = "Male", ht = 180, age = 50, weight = 80,
#'                                   measured = 0.45, frequency = "5")
#' print(zscore)
#'
#' @export
compute_valach_r_zscore <- function(sex, ht, ht_unit = "cm", age, weight,
                                     weight_unit = "kg", measured, frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate z-score
  z_score <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.10454079 + (-1.94365016 * height_log) + (-0.13493079 * age_log) + (0.73359356 * bmi_log))
      S <- exp(3.39897015 + (-0.89954098 * height_log) + (0.18722026 * age_log) + (-0.2363505 * bmi_log))
      L <- 22.96212585 + (-4.19150238 * height_log) + (0.23357827 * age_log) + (-0.74956753 * bmi_log)
      ((measured / M)^L - 1) / (S * L)
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.00281496 + (-0.01146274 * ht) + (-0.00236143 * age) + (0.62277905 * bmi_log))
      S <- exp(0.14838989 + (-0.00468145 * ht) + (0.00174169 * age) + (-0.25023483 * bmi_log))
      L <- 11.53948419 + (-0.02258354 * ht) + (0.00181158 * age) + (-2.45928703 * bmi_log)
      ((measured / M)^L - 1) / (S * L)
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(1.27951905 + (-0.00820938 * ht) + (-0.0039901 * age) + (0.37558144 * bmi_log))
      S <- exp(-0.14097405 + (-0.00801434 * ht) + (0.00087917 * age) + (0.00209106 * bmi_log))
      L <- 15.63479312 + (-0.02224631 * ht) + (0.00523639 * age) + (-3.80871449 * bmi_log)
      ((measured / M)^L - 1) / (S * L)
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.51176089 + (-0.00581226 * ht) + (-0.00194815 * age) + (0.02946239 * bmi))
      S <- exp(-1.62848204 + (-3.48e-05 * ht) + (0.00684834 * age) + (-0.00141105 * bmi))
      L <- 0.04517853 + (-0.01529633 * ht) + (0.01618496 * age) + (0.05140252 * bmi)
      ((measured / M)^L - 1) / (S * L)
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.55468797 + (-0.00579631 * ht) + (-0.00128173 * age) + (0.02334934 * bmi))
      S <- exp(-1.50409754 + (-0.00159016 * ht) + (0.00538724 * age) + (0.0039368 * bmi))
      L <- 0.0580996 + (-0.02320459 * ht) + (0.02235644 * age) + (0.08854164 * bmi)
      ((measured / M)^L - 1) / (S * L)
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.39302074 + (-0.00335726 * ht) + (-0.0031946 * age) + (0.01774499 * bmi))
      S <- exp(-1.33716494 + (-0.00342657 * ht) + (0.00579859 * age) + (0.00435456 * bmi))
      L <- 0.40685746 + (-0.03221751 * ht) + (0.01570796 * age) + (0.14510401 * bmi)
      ((measured / M)^L - 1) / (S * L)
    },
    
    TRUE ~ NA_real_
  )
  
  return(z_score)
}


#' Calculate Percent Predicted for Resistance (Valach/LEAD)
#'
#' Computes percent of predicted for measured respiratory resistance.
#'
#' @inheritParams compute_valach_r_zscore
#'
#' @return Numeric: Percent predicted (%)
#'
#' @details
#' Formula: (measured / predicted) × 100
#' 
#' Note: Z-scores are preferred over percent predicted for clinical interpretation
#' of resistance measurements.
#'
#' @examples
#' pct <- compute_valach_r_percent_pred(sex = "Female", ht = 165, age = 55, weight = 65,
#'                                      measured = 0.35, frequency = "5")
#' print(pct)
#'
#' @export
compute_valach_r_percent_pred <- function(sex, ht, ht_unit = "cm", age, weight,
                                           weight_unit = "kg", measured, frequency, ...) {
  
  predicted <- compute_valach_r_pred(
    sex = sex,
    ht = ht,
    ht_unit = ht_unit,
    age = age,
    weight = weight,
    weight_unit = weight_unit,
    frequency = frequency
  )
  
  percent_pred <- (measured / predicted) * 100
  
  return(percent_pred)
}

## +++++++++++++++++++++ FOT Valach Reactance Functions +++++++++++++++++++++++++++ ##
#   Package: AHBPCEPredR
#   Forced Oscillation Technique - Valach/LEAD 2025 Reference Equations
##------
# Reference equations for respiratory reactance at 5, 11, 19 Hz and derived parameters
# Based on: Valach et al., Austrian LEAD study population
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

#' Calculate Predicted Reactance (Valach/LEAD)
#'
#' Computes predicted respiratory system reactance using Valach et al. reference equations
#' from the Austrian LEAD study population. Reactance measurements reflect elastic and
#' inertial properties of the respiratory system.
#'
#' @param sex Character string: "Male" or "Female"
#' @param ht Numeric: Height value
#' @param ht_unit Character: "cm" (default) or "in" for height units
#' @param age Numeric: Age in years
#' @param weight Numeric: Weight value
#' @param weight_unit Character: "kg" (default) or "lbs" for weight units
#' @param frequency Character: Oscillation frequency - "5", "11", "19", "fres" (resonant frequency), or "AX5" (reactance area)
#' @param ... Additional arguments (ignored)
#'
#' @return Numeric: Predicted reactance (hPa·s·L⁻¹) or derived parameter
#'
#' @details
#' The Valach equations use GAMLSS methodology with BMI as a predictor.
#' Valid frequencies: 5, 11, 19 Hz, plus fres (resonant frequency in Hz) and AX5 (area under reactance curve)
#' 
#' Reactance is typically negative at low frequencies and becomes less negative (more positive)
#' at higher frequencies. The equations apply transformations to handle this:
#' - For X5, X11, X19: Returns -(predicted_value - offset)
#' - For fres and AX5: Returns predicted_value - 1
#'
#' @references
#' Valach et al. Austrian LEAD study (2025)
#'
#' @examples
#' # Male, 180 cm, 50 years, 80 kg at 5 Hz
#' compute_valach_x_pred(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
#'
#' # Resonant frequency
#' compute_valach_x_pred(sex = "Female", ht = 165, age = 45, weight = 65, frequency = "fres")
#'
#' # Reactance area
#' compute_valach_x_pred(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "AX5")
#'
#' @export
compute_valach_x_pred <- function(sex, ht, ht_unit = "cm", age, weight,
                                   weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19', 'fres', 'AX5')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19, fres, AX5")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate predicted reactance based on frequency and sex
  predicted <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ 
      -(exp(9.4589637 + (-1.71656853 * height_log)) - 1),
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ 
      -(exp(0.13752425 + (-0.00529987 * ht) + (0.00181132 * age) + (0.4404226 * bmi_log)) - 2),
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ 
      -(exp(4.67984333 + (-0.82989887 * height_log) + (0.00213489 * age) + (0.01357915 * bmi)) - 3),
    
    frequency == "fres" & sex %in% c("M", "Male", "MALE") ~ 
      exp(8.851027 + (-1.36576357 * height_log) + (0.00275046 * age) + (0.02457601 * bmi)) - 1,
    
    frequency == "AX5" & sex %in% c("M", "Male", "MALE") ~ 
      exp(20.91145761 + (-4.03054991 * height_log) + (0.00493653 * age) + (0.03880709 * bmi)) - 1,
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ 
      -(exp(2.15122728 + (-0.01007245 * ht) + (0.00253771 * age) + (0.00522028 * bmi)) - 1),
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ 
      -(exp(1.29563176 + (-0.00665404 * ht) + (0.00288121 * age) + (0.01672132 * bmi)) - 2),
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ 
      -(exp(0.83979527 + (-0.00387311 * ht) + (0.00396443 * age) + (0.01643385 * bmi)) - 3),
    
    frequency == "fres" & sex %in% c("F", "Female", "FEMALE") ~ 
      exp(3.26022419 + (-0.00786778 * ht) + (0.00346721 * age) + (0.01842025 * bmi)) - 1,
    
    frequency == "AX5" & sex %in% c("F", "Female", "FEMALE") ~ 
      exp(4.38084913 + (-0.02397973 * ht) + (0.00781428 * age) + (0.03123407 * bmi)) - 1,
    
    TRUE ~ NA_real_
  )
  
  return(predicted)
}


#' Calculate Lower Limit of Normal for Reactance (Valach/LEAD)
#'
#' Computes the lower limit of normal (5th percentile, z-score = -1.645) for respiratory
#' reactance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_x_pred
#'
#' @return Numeric: LLN for reactance (hPa·s·L⁻¹) or derived parameter
#'
#' @details
#' LLN calculated using GAMLSS Box-Cox transformation with special handling for
#' negative reactance values (X5, X11, X19) versus positive derived parameters (fres, AX5).
#' 
#' More negative reactance than LLN suggests increased capacitance or reduced compliance.
#'
#' @examples
#' # Check if reactance is more negative than LLN
#' lln <- compute_valach_x_lln(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
#' measured <- -0.25
#' is_abnormal <- measured < lln  # More negative than LLN
#'
#' @export
compute_valach_x_lln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19', 'fres', 'AX5')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19, fres, AX5")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate LLN
  lln <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.4589637 + (-1.71656853 * height_log))
      S <- exp(-0.31655849 + (-0.29607484 * height_log))
      L <- (-48.35479093 + (9.04155502 * height_log))
      -(M * (1.645 * S * L + 1)^(1/L) - 1)
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(0.13752425 + (-0.00529987 * ht) + (0.00181132 * age) + (0.4404226 * bmi_log))
      S <- exp(-2.35407112 + (-0.0015002 * ht) + (-0.00049056 * age) + (0.22463087 * bmi_log))
      L <- -17.43071466 + (0.01869517 * ht) + (-0.02854541 * age) + (4.60218203 * bmi_log)
      -(M * (1.645 * S * L + 1)^(1/L) - 2)
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(4.67984333 + (-0.82989887 * height_log) + (0.00213489 * age) + (0.01357915 * bmi))
      S <- exp(0.75597345 + (-0.00319543 * ht) + (-0.0048328 * age) + (-0.54907627 * bmi_log))
      L <- -7.94388629 + (0.03431916 * ht) + (-0.02686528 * age) + (1.1337555 * bmi_log)
      -(M * (1.645 * S * L + 1)^(1/L) - 3)
    },
    
    frequency == "fres" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(8.851027 + (-1.36576357 * height_log) + (0.00275046 * age) + (0.02457601 * bmi))
      S <- exp(-3.36340912 + (0.00578775 * ht) + (0.00406375 * age) + (0.02124452 * bmi))
      L <- -22.70414733 + (0.08760471 * ht) + (0.01426116 * age) + (0.21255987 * bmi)
      M * (-1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "AX5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(20.91145761 + (-4.03054991 * height_log) + (0.00493653 * age) + (0.03880709 * bmi))
      S <- exp(-2.73623813 + (0.00648946 * ht) + (0.00439438 * age) + (0.02372895 * bmi))
      L <- -6.16727771 + (0.02410694 * ht) + (0.00095903 * age) + (0.05306513 * bmi)
      M * (-1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(2.15122728 + (-0.01007245 * ht) + (0.00253771 * age) + (0.00522028 * bmi))
      S <- exp(-2.10352672 + (-0.00247685 * ht) + (0.0043698 * age) + (0.02227286 * bmi))
      L <- 1.60615653 + (-0.01674539 * ht) + (0.01796927 * age) + (-0.01506559 * bmi)
      -(M * (1.645 * S * L + 1)^(1/L) - 1)
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.29563176 + (-0.00665404 * ht) + (0.00288121 * age) + (0.01672132 * bmi))
      S <- exp(-2.20100707 + (0.0008043 * ht) + (0.00205894 * age) + (0.01010552 * bmi))
      L <- 2.18048689 + (-0.01465916 * ht) + (-0.00571084 * age) + (0.00327076 * bmi)
      -(M * (1.645 * S * L + 1)^(1/L) - 2)
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(0.83979527 + (-0.00387311 * ht) + (0.00396443 * age) + (0.01643385 * bmi))
      S <- exp(-1.44128809 + (0.00051256 * ht) + (-0.00288493 * age) + (-0.00179092 * bmi))
      L <- 4.63067019 + (-0.02507764 * ht) + (0.01257941 * age) + (-0.023041 * bmi)
      -(M * (1.645 * S * L + 1)^(1/L) - 3)
    },
    
    frequency == "fres" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(3.26022419 + (-0.00786778 * ht) + (0.00346721 * age) + (0.01842025 * bmi))
      S <- exp(-2.69541069 + (0.00254021 * ht) + (0.0053061 * age) + (0.01888391 * bmi))
      L <- 1.99915858 + (-0.03013993 * ht) + (0.01303588 * age) + (0.05661649 * bmi)
      M * (-1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "AX5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(4.38084913 + (-0.02397973 * ht) + (0.00781428 * age) + (0.03123407 * bmi))
      S <- exp(-2.11476391 + (0.00442156 * ht) + (0.00434425 * age) + (0.02072464 * bmi))
      L <- 1.27383151 + (-0.01148621 * ht) + (0.0009999 * age) + (0.01348385 * bmi)
      M * (-1.645 * S * L + 1)^(1/L) - 1
    },
    
    TRUE ~ NA_real_
  )
  
  return(lln)
}


#' Calculate Upper Limit of Normal for Reactance (Valach/LEAD)
#'
#' Computes the upper limit of normal (95th percentile, z-score = +1.645) for respiratory
#' reactance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_x_pred
#'
#' @return Numeric: ULN for reactance (hPa·s·L⁻¹) or derived parameter
#'
#' @details
#' ULN calculated using GAMLSS Box-Cox transformation with special handling for
#' negative reactance values versus positive derived parameters.
#'
#' @examples
#' # Check ULN for reactance
#' uln <- compute_valach_x_uln(sex = "Female", ht = 165, age = 55, weight = 65, frequency = "5")
#' measured <- -0.05
#' is_above_uln <- measured > uln  # Less negative than ULN (unusual)
#'
#' @export
compute_valach_x_uln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19', 'fres', 'AX5')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19, fres, AX5")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate ULN
  uln <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.4589637 + (-1.71656853 * height_log))
      S <- exp(-0.31655849 + (-0.29607484 * height_log))
      L <- (-48.35479093 + (9.04155502 * height_log))
      -(M * (-1.645 * S * L + 1)^(1/L) - 1)
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(0.13752425 + (-0.00529987 * ht) + (0.00181132 * age) + (0.4404226 * bmi_log))
      S <- exp(-2.35407112 + (-0.0015002 * ht) + (-0.00049056 * age) + (0.22463087 * bmi_log))
      L <- -17.43071466 + (0.01869517 * ht) + (-0.02854541 * age) + (4.60218203 * bmi_log)
      -(M * (-1.645 * S * L + 1)^(1/L) - 2)
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(4.67984333 + (-0.82989887 * height_log) + (0.00213489 * age) + (0.01357915 * bmi))
      S <- exp(0.75597345 + (-0.00319543 * ht) + (-0.0048328 * age) + (-0.54907627 * bmi_log))
      L <- -7.94388629 + (0.03431916 * ht) + (-0.02686528 * age) + (1.1337555 * bmi_log)
      -(M * (-1.645 * S * L + 1)^(1/L) - 3)
    },
    
    frequency == "fres" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(8.851027 + (-1.36576357 * height_log) + (0.00275046 * age) + (0.02457601 * bmi))
      S <- exp(-3.36340912 + (0.00578775 * ht) + (0.00406375 * age) + (0.02124452 * bmi))
      L <- -22.70414733 + (0.08760471 * ht) + (0.01426116 * age) + (0.21255987 * bmi)
      M * (1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "AX5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(20.91145761 + (-4.03054991 * height_log) + (0.00493653 * age) + (0.03880709 * bmi))
      S <- exp(-2.73623813 + (0.00648946 * ht) + (0.00439438 * age) + (0.02372895 * bmi))
      L <- -6.16727771 + (0.02410694 * ht) + (0.00095903 * age) + (0.05306513 * bmi)
      M * (1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(2.15122728 + (-0.01007245 * ht) + (0.00253771 * age) + (0.00522028 * bmi))
      S <- exp(-2.10352672 + (-0.00247685 * ht) + (0.0043698 * age) + (0.02227286 * bmi))
      L <- 1.60615653 + (-0.01674539 * ht) + (0.01796927 * age) + (-0.01506559 * bmi)
      -(M * (-1.645 * S * L + 1)^(1/L) - 1)
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.29563176 + (-0.00665404 * ht) + (0.00288121 * age) + (0.01672132 * bmi))
      S <- exp(-2.20100707 + (0.0008043 * ht) + (0.00205894 * age) + (0.01010552 * bmi))
      L <- 2.18048689 + (-0.01465916 * ht) + (-0.00571084 * age) + (0.00327076 * bmi)
      -(M * (-1.645 * S * L + 1)^(1/L) - 2)
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(0.83979527 + (-0.00387311 * ht) + (0.00396443 * age) + (0.01643385 * bmi))
      S <- exp(-1.44128809 + (0.00051256 * ht) + (-0.00288493 * age) + (-0.00179092 * bmi))
      L <- 4.63067019 + (-0.02507764 * ht) + (0.01257941 * age) + (-0.023041 * bmi)
      -(M * (-1.645 * S * L + 1)^(1/L) - 3)
    },
    
    frequency == "fres" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(3.26022419 + (-0.00786778 * ht) + (0.00346721 * age) + (0.01842025 * bmi))
      S <- exp(-2.69541069 + (0.00254021 * ht) + (0.0053061 * age) + (0.01888391 * bmi))
      L <- 1.99915858 + (-0.03013993 * ht) + (0.01303588 * age) + (0.05661649 * bmi)
      M * (1.645 * S * L + 1)^(1/L) - 1
    },
    
    frequency == "AX5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(4.38084913 + (-0.02397973 * ht) + (0.00781428 * age) + (0.03123407 * bmi))
      S <- exp(-2.11476391 + (0.00442156 * ht) + (0.00434425 * age) + (0.02072464 * bmi))
      L <- 1.27383151 + (-0.01148621 * ht) + (0.0009999 * age) + (0.01348385 * bmi)
      M * (1.645 * S * L + 1)^(1/L) - 1
    },
    
    TRUE ~ NA_real_
  )
  
  return(uln)
}


#' Calculate Z-Score for Reactance (Valach/LEAD)
#'
#' Computes the z-score for measured respiratory reactance using Valach et al. reference equations.
#'
#' @inheritParams compute_valach_x_pred
#' @param measured Numeric: Measured reactance value (hPa·s·L⁻¹) or derived parameter
#'
#' @return Numeric: Z-score (standard deviation units)
#'
#' @details
#' Z-score calculation with special handling for transformed reactance values:
#' - For X5, X11, X19: Applies transformation -(measured - offset) before z-score calculation
#' - For fres, AX5: Applies transformation (measured + 1) before z-score calculation
#' 
#' Interpretation:
#' - For X5, X11, X19: More negative z-scores indicate more negative reactance (increased capacitance)
#' - For fres, AX5: Standard z-score interpretation applies
#'
#' @examples
#' # Calculate z-score for reactance at 5 Hz
#' zscore <- compute_valach_x_zscore(sex = "Male", ht = 180, age = 50, weight = 80,
#'                                   measured = -0.20, frequency = "5")
#' print(zscore)
#'
#' # Calculate z-score for resonant frequency
#' zscore_fres <- compute_valach_x_zscore(sex = "Female", ht = 165, age = 45, weight = 65,
#'                                        measured = 12.5, frequency = "fres")
#'
#' @export
compute_valach_x_zscore <- function(sex, ht, ht_unit = "cm", age, weight,
                                     weight_unit = "kg", measured, frequency, ...) {
  
  # Frequency validation
  allowed_frequency <- c('5', '11', '19', 'fres', 'AX5')
  if (!frequency %in% allowed_frequency) {
    stop("Invalid frequency. Must be one of: 5, 11, 19, fres, AX5")
  }
  
  # Unit conversions
  if (ht_unit == "in") ht <- ht * 2.54
  if (weight_unit == "lbs") weight <- weight * 0.453592
  
  # Calculate BMI and log transformations
  bmi <- weight / (ht / 100)^2
  bmi_log <- log(bmi)
  height_log <- log(ht)
  age_log <- log(age)
  
  # Calculate z-score with appropriate transformations
  z_score <- dplyr::case_when(
    frequency == "5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(9.4589637 + (-1.71656853 * height_log))
      S <- exp(-0.31655849 + (-0.29607484 * height_log))
      L <- (-48.35479093 + (9.04155502 * height_log))
      x5_trans <- -(measured - 1)
      -((((x5_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "11" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(0.13752425 + (-0.00529987 * ht) + (0.00181132 * age) + (0.4404226 * bmi_log))
      S <- exp(-2.35407112 + (-0.0015002 * ht) + (-0.00049056 * age) + (0.22463087 * bmi_log))
      L <- -17.43071466 + (0.01869517 * ht) + (-0.02854541 * age) + (4.60218203 * bmi_log)
      x11_trans <- -(measured - 2)
      -((((x11_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "19" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(4.67984333 + (-0.82989887 * height_log) + (0.00213489 * age) + (0.01357915 * bmi))
      S <- exp(0.75597345 + (-0.00319543 * ht) + (-0.0048328 * age) + (-0.54907627 * bmi_log))
      L <- -7.94388629 + (0.03431916 * ht) + (-0.02686528 * age) + (1.1337555 * bmi_log)
      x19_trans <- -(measured - 3)
      -((((x19_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "fres" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(8.851027 + (-1.36576357 * height_log) + (0.00275046 * age) + (0.02457601 * bmi))
      S <- exp(-3.36340912 + (0.00578775 * ht) + (0.00406375 * age) + (0.02124452 * bmi))
      L <- -22.70414733 + (0.08760471 * ht) + (0.01426116 * age) + (0.21255987 * bmi)
      (((measured + 1) / M)^L - 1) / (S * L)
    },
    
    frequency == "AX5" & sex %in% c("M", "Male", "MALE") ~ {
      M <- exp(20.91145761 + (-4.03054991 * height_log) + (0.00493653 * age) + (0.03880709 * bmi))
      S <- exp(-2.73623813 + (0.00648946 * ht) + (0.00439438 * age) + (0.02372895 * bmi))
      L <- -6.16727771 + (0.02410694 * ht) + (0.00095903 * age) + (0.05306513 * bmi)
      (((measured + 1) / M)^L - 1) / (S * L)
    },
    
    frequency == "5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(2.15122728 + (-0.01007245 * ht) + (0.00253771 * age) + (0.00522028 * bmi))
      S <- exp(-2.10352672 + (-0.00247685 * ht) + (0.0043698 * age) + (0.02227286 * bmi))
      L <- 1.60615653 + (-0.01674539 * ht) + (0.01796927 * age) + (-0.01506559 * bmi)
      x5_trans <- -(measured - 1)
      -((((x5_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "11" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(1.29563176 + (-0.00665404 * ht) + (0.00288121 * age) + (0.01672132 * bmi))
      S <- exp(-2.20100707 + (0.0008043 * ht) + (0.00205894 * age) + (0.01010552 * bmi))
      L <- 2.18048689 + (-0.01465916 * ht) + (-0.00571084 * age) + (0.00327076 * bmi)
      x11_trans <- -(measured - 2)
      -((((x11_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "19" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(0.83979527 + (-0.00387311 * ht) + (0.00396443 * age) + (0.01643385 * bmi))
      S <- exp(-1.44128809 + (0.00051256 * ht) + (-0.00288493 * age) + (-0.00179092 * bmi))
      L <- 4.63067019 + (-0.02507764 * ht) + (0.01257941 * age) + (-0.023041 * bmi)
      x19_trans <- -(measured - 3)
      -((((x19_trans / M)^L) - 1) / (S * L))
    },
    
    frequency == "fres" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(3.26022419 + (-0.00786778 * ht) + (0.00346721 * age) + (0.01842025 * bmi))
      S <- exp(-2.69541069 + (0.00254021 * ht) + (0.0053061 * age) + (0.01888391 * bmi))
      L <- 1.99915858 + (-0.03013993 * ht) + (0.01303588 * age) + (0.05661649 * bmi)
      (((measured + 1) / M)^L - 1) / (S * L)
    },
    
    frequency == "AX5" & sex %in% c("F", "Female", "FEMALE") ~ {
      M <- exp(4.38084913 + (-0.02397973 * ht) + (0.00781428 * age) + (0.03123407 * bmi))
      S <- exp(-2.11476391 + (0.00442156 * ht) + (0.00434425 * age) + (0.02072464 * bmi))
      L <- 1.27383151 + (-0.01148621 * ht) + (0.0009999 * age) + (0.01348385 * bmi)
      (((measured + 1) / M)^L - 1) / (S * L)
    },
    
    TRUE ~ NA_real_
  )
  
  return(z_score)
}


#' Calculate Percent Predicted for Reactance (Valach/LEAD)
#'
#' Computes percent of predicted for measured respiratory reactance.
#'
#' @inheritParams compute_valach_x_zscore
#'
#' @return Numeric: Percent predicted (%)
#'
#' @details
#' Formula: (measured / predicted) × 100
#' 
#'
#' @examples
#' pct <- compute_valach_x_percent_pred(sex = "Female", ht = 165, age = 55, weight = 65,
#'                                      measured = -0.18, frequency = "5")
#' print(pct)
#'
#' @export
compute_valach_x_percent_pred <- function(sex, ht, ht_unit = "cm", age, weight,
                                           weight_unit = "kg", measured, frequency, ...) {
  
  predicted <- compute_valach_x_pred(
    sex = sex,
    ht = ht,
    ht_unit = ht_unit,
    age = age,
    weight = weight,
    weight_unit = weight_unit,
    frequency = frequency
  )
  
  percent_pred <- (measured / predicted) * 100
  
  return(percent_pred)
}