## +++++++++++++++++++++ FOT Prediction Module +++++++++++++++++++++++++++ ##
#   Shobhik Chakraborty
#   11/25/2024                      
#   Local Module 
##------
# Functions for computing FOT (Forced Oscillation Technique) predictions
# Based on Oostveen et al. 2013 equations
#
# Coefficient tables (fot_resistance_table, fot_reactance_table) are stored
# in R/sysdata.rda and loaded automatically when package loads
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##


## ---------------------------- Helper Functions (Not Exported) ------------------------------

Get_Oostveen_Params <- function(table, frequency, sex){
  ## Extract parameters for specific frequency and sex from coefficient table
  freq_data <- subset(table, Frequency == frequency)
  
  if(nrow(freq_data) == 0) {
    stop("Frequency ", frequency, " not found in table")
  }
  
  if(sex %in% c("M", 'Male', 'MALE')){
    list(
      a = freq_data$male_a,
      b = freq_data$male_b,
      c = freq_data$male_c,
      d = freq_data$male_d,
      RSD = freq_data$RSD_male
    )
  } else {
    list(
      a = freq_data$female_a,
      b = freq_data$female_b,
      c = freq_data$female_c,
      d = freq_data$female_d,
      RSD = freq_data$RSD_female
    )
  }
}


## ==================== OOSTVEEN RESISTANCE FUNCTIONS ====================

#' Compute Oostveen Resistance Prediction
#'
#' Calculate predicted airway resistance using Oostveen et al. 2013 equations.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency in Hz: "4", "5", "6", "7", "8", "10", "11", "12", 
#'   "14", "15", "16", "18", "19", "20", "22", "24", "26"
#' @param ... Additional arguments (ignored)
#'
#' @return Predicted resistance in hPa·s·L⁻¹ or cmH₂O·s·L⁻¹
#'
#' @references Oostveen E, et al. The forced oscillation technique in clinical 
#'   practice: methodology, recommendations and future developments. 
#'   Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_r_pred(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
compute_oostveen_r_pred <- function(sex, ht, ht_unit = "cm", age, weight, 
                                   weight_unit = "kg", pressure_unit = "cmh2o",
                                   frequency, ...) {
  ## Oostveen 2013 resistance prediction
  ## NOTE: default units - height:[cm], weight:[kg], pressure:[hpa]
  ## Frequencies: 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 16, 18, 19, 20, 22, 24, 26 Hz
  
  allowed_freq <- c('4','5','6','7','8','10','11','12','14','15','16','18','19','20','22','24','26')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  stopifnot(pressure_unit %in% c('hpa', 'cmh2o'))
  
  # Unit conversions to standard units
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100  # Equation uses meters
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  # Special handling for 11 Hz (average of 10 and 12 Hz)
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_resistance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_resistance_table, 12, sex)
    
    pred_10 <- exp(params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight)
    pred_12 <- exp(params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight)
    
    ret <- ((pred_10 + pred_12) / 2) * press_conv
  } else {
    params <- Get_Oostveen_Params(fot_resistance_table, as.numeric(frequency), sex)
    
    # Oostveen equation: ln(Rrs) = a + b*height + c*age + d*weight
    ret <- exp(params$a + params$b * ht_m + params$c * age + params$d * weight) * press_conv
  }
  
  return(ret)
}


#' Compute Oostveen Resistance Lower Limit of Normal
#'
#' Calculate lower limit of normal (5th percentile) for airway resistance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency in Hz (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Lower limit of normal for resistance
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_r_lln(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
compute_oostveen_r_lln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", pressure_unit = "cmh2o",
                                  frequency, ...) {
  ## Lower limit of normal: exp(ln(predicted) - 1.64*RSD)
  
  allowed_freq <- c('4','5','6','7','8','10','11','12','14','15','16','18','19','20','22','24','26')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_resistance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_resistance_table, 12, sex)
    
    pred_ln_10 <- params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight
    pred_ln_12 <- params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight
    
    pred_ln <- (pred_ln_10 + pred_ln_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- exp(pred_ln - 1.64 * RSD) * press_conv
  } else {
    params <- Get_Oostveen_Params(fot_resistance_table, as.numeric(frequency), sex)
    pred_ln <- params$a + params$b * ht_m + params$c * age + params$d * weight
    ret <- exp(pred_ln - 1.64 * params$RSD) * press_conv
  }
  
  return(ret)
}


#' Compute Oostveen Resistance Upper Limit of Normal
#'
#' Calculate upper limit of normal (95th percentile) for airway resistance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency in Hz (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Upper limit of normal for resistance
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_r_uln(sex = "Male", ht = 180, age = 50, weight = 80, frequency = "5")
compute_oostveen_r_uln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", pressure_unit = "cmh2o",
                                  frequency, ...) {
  ## Upper limit of normal: exp(ln(predicted) + 1.64*RSD)
  
  allowed_freq <- c('4','5','6','7','8','10','11','12','14','15','16','18','19','20','22','24','26')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_resistance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_resistance_table, 12, sex)
    
    pred_ln_10 <- params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight
    pred_ln_12 <- params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight
    
    pred_ln <- (pred_ln_10 + pred_ln_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- exp(pred_ln + 1.64 * RSD) * press_conv
  } else {
    params <- Get_Oostveen_Params(fot_resistance_table, as.numeric(frequency), sex)
    pred_ln <- params$a + params$b * ht_m + params$c * age + params$d * weight
    ret <- exp(pred_ln + 1.64 * params$RSD) * press_conv
  }
  
  return(ret)
}


#' Compute Oostveen Resistance Z-Score
#'
#' Calculate z-score for measured airway resistance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param measured Measured resistance value (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency in Hz (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Z-score (standard deviations from predicted)
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_r_zscore(sex = "Male", ht = 180, age = 50, weight = 80, 
#'                           measured = 0.35, frequency = "5")
compute_oostveen_r_zscore <- function(sex, ht, ht_unit = "cm", age, weight, measured,
                                     weight_unit = "kg", pressure_unit = "cmh2o",
                                     frequency, ...) {
  ## Z-score: (ln(measured) - ln(predicted)) / RSD
  
  allowed_freq <- c('4','5','6','7','8','10','11','12','14','15','16','18','19','20','22','24','26')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_resistance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_resistance_table, 12, sex)
    
    pred_10 <- exp(params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight)
    pred_12 <- exp(params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight)
    
    pred <- (pred_10 + pred_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- (log(measured) - log(pred * press_conv)) / RSD
  } else {
    params <- Get_Oostveen_Params(fot_resistance_table, as.numeric(frequency), sex)
    pred <- exp(params$a + params$b * ht_m + params$c * age + params$d * weight)
    ret <- (log(measured) - log(pred * press_conv)) / params$RSD
  }
  
  return(ret)
}


#' Compute Oostveen Resistance Percent Predicted
#'
#' Calculate percent predicted for measured airway resistance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param measured Measured resistance value (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency in Hz (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Percent predicted (numeric)
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_r_percent_pred(sex = "Male", ht = 180, age = 50, weight = 80,
#'                                 measured = 0.35, frequency = "5")
compute_oostveen_r_percent_pred <- function(sex, ht, ht_unit = "cm", age, weight, measured,
                                           weight_unit = "kg", pressure_unit = "cmh2o",
                                           frequency, ...) {
  ## Percent predicted: (measured / predicted) * 100
  
  pred <- compute_oostveen_r_pred(sex = sex, ht = ht, ht_unit = ht_unit, 
                                 age = age, weight = weight, weight_unit = weight_unit,
                                 pressure_unit = pressure_unit, frequency = frequency)
  
  return((measured / pred) * 100)
}


## ==================== OOSTVEEN REACTANCE FUNCTIONS ====================

#' Compute Oostveen Reactance Prediction
#'
#' Calculate predicted reactance using Oostveen et al. 2013 equations.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa"  (not used for fres)
#' @param frequency Frequency: "4", "5", "6", "8", "10", "11", "12", "14", "fres", "AX4", "AX5"
#' @param ... Additional arguments (ignored)
#'
#' @return Predicted reactance in hPa·s·L⁻¹ (or Hz for fres)
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_x_pred(sex = "Female", ht = 165, age = 55, weight = 65, frequency = "5")
compute_oostveen_x_pred <- function(sex, ht, ht_unit = "cm", age, weight,
                                   weight_unit = "kg", pressure_unit = "cmh2o",
                                   frequency, ...) {
  ## Oostveen 2013 reactance prediction
  ## NOTE: Frequencies: 4, 5, 6, 8, 10, 11, 12, 14, fres, AX4, AX5
  ## For fres (resonant frequency), returns Hz (no pressure conversion)
  ## For Xrs, equation is: X = 4 - exp(a + b*ht + c*age + d*weight)
  
  allowed_freq <- c('4','5','6','8','10','11','12','14','fres','AX4','AX5')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  # Pressure conversion factor
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  # Special handling for 11 Hz (average of 10 and 12 Hz)
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_reactance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_reactance_table, 12, sex)
    
    pred_10 <- 4 - exp(params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight)
    pred_12 <- 4 - exp(params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight)
    
    ret <- ((pred_10 + pred_12) / 2) * press_conv
    return(ret)
  }
  
  # Get parameters for this frequency
  params <- Get_Oostveen_Params(fot_reactance_table, frequency, sex)
  
  # Special handling for fres (no transformation or pressure conversion)
  if(frequency == 'fres'){
    ret <- exp(params$a + params$b * ht_m + params$c * age + params$d * weight)
    return(ret)
  }
  
  # Standard reactance frequencies: X = 4 - exp(...)
  if(frequency %in% c('4','5','6','8','10','12','14')){
    ret <- (4 - exp(params$a + params$b * ht_m + params$c * age + params$d * weight)) * press_conv
    return(ret)
  }
  
  # AX4 and AX5: Area under reactance curve
  if(frequency %in% c('AX4','AX5')){
    ret <- exp(params$a + params$b * ht_m + params$c * age + params$d * weight) * press_conv
    return(ret)
  }
  
  return(ret)
}


#' Compute Oostveen Reactance Lower Limit of Normal
#'
#' Calculate lower limit of normal for reactance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Lower limit of normal for reactance
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_x_lln(sex = "Female", ht = 165, age = 55, weight = 65, frequency = "5")
compute_oostveen_x_lln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", pressure_unit = "cmh2o",
                                  frequency, ...) {
  ## Lower limit of normal for reactance
  ## For Xrs: LLN is MORE NEGATIVE (worse) = 4 - exp(pred + 1.64*RSD)
  ## For fres: LLN uses exp(pred + 1.64*RSD)
  ## For AX: LLN uses exp(pred + 1.64*RSD)
  
  allowed_freq <- c('4','5','6','8','10','11','12','14','fres','AX4','AX5')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  # Special handling for 11 Hz
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_reactance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_reactance_table, 12, sex)
    
    pred_ln_10 <- params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight
    pred_ln_12 <- params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight
    
    pred_ln <- (pred_ln_10 + pred_ln_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- (4 - exp(pred_ln + 1.64 * RSD)) * press_conv
    return(ret)
  }
  
  params <- Get_Oostveen_Params(fot_reactance_table, frequency, sex)
  pred_ln <- params$a + params$b * ht_m + params$c * age + params$d * weight
  
  # fres and AX
  if(frequency %in% c('fres','AX4','AX5')){
    ret <- exp(pred_ln + 1.64 * params$RSD) * ifelse(frequency == 'fres', 1.0, press_conv)
    return(ret)
  }
  
  # Standard reactance frequencies
  ret <- (4 - exp(pred_ln + 1.64 * params$RSD)) * press_conv
  return(ret)
}


#' Compute Oostveen Reactance Upper Limit of Normal
#'
#' Calculate upper limit of normal for reactance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Upper limit of normal for reactance (NA for fres and AX)
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_x_uln(sex = "Female", ht = 165, age = 55, weight = 65, frequency = "5")
compute_oostveen_x_uln <- function(sex, ht, ht_unit = "cm", age, weight,
                                  weight_unit = "kg", pressure_unit = "cmh2o",
                                  frequency, ...) {
  ## Upper limit of normal for reactance
  ## NOTE: ULN not defined for fres or AX in original equations
  
  allowed_freq <- c('4','5','6','8','10','11','12','14','fres','AX4','AX5')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  # Special handling for 11 Hz
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_reactance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_reactance_table, 12, sex)
    
    pred_ln_10 <- params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight
    pred_ln_12 <- params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight
    
    pred_ln <- (pred_ln_10 + pred_ln_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- (4 - exp(pred_ln - 1.64 * RSD)) * press_conv
    return(ret)
  }
  
  # fres and AX - no ULN defined
  if(frequency %in% c('fres','AX4','AX5')){
    warning("ULN not implemented for ", frequency, " in original Oostveen equations")
    return(NA_real_)
  }
  
  # Standard reactance frequencies
  params <- Get_Oostveen_Params(fot_reactance_table, as.numeric(frequency), sex)
  pred_ln <- params$a + params$b * ht_m + params$c * age + params$d * weight
  ret <- (4 - exp(pred_ln - 1.64 * params$RSD)) * press_conv
  
  return(ret)
}


#' Compute Oostveen Reactance Z-Score
#'
#' Calculate z-score for measured reactance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param measured Measured reactance value (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Z-score for reactance
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_x_zscore(sex = "Female", ht = 165, age = 55, weight = 65,
#'                           measured = -0.25, frequency = "5")
compute_oostveen_x_zscore <- function(sex, ht, ht_unit = "cm", age, weight, measured,
                                     weight_unit = "kg", pressure_unit = "cmh2o",
                                     frequency, ...) {
  ## Z-score for reactance
  ## For Xrs: z = -((ln(4-measured) - ln(4-predicted)) / RSD)
  ## For fres and AX: z = (ln(measured) - ln(predicted)) / RSD
  
  allowed_freq <- c('4','5','6','8','10','11','12','14','fres','AX4','AX5')
  frequency <- as.character(frequency)
  stopifnot(frequency %in% allowed_freq)
  stopifnot(ht_unit %in% c('cm', 'in', 'm'))
  stopifnot(weight_unit %in% c('kg', 'lbs'))
  
  # Unit conversions
  if(ht_unit == "in") ht <- ht * 2.54
  if(ht_unit == "m") ht <- ht * 100
  ht_m <- ht / 100
  
  if(weight_unit == "lbs") weight <- weight * 0.453592
  
  press_conv <- ifelse(pressure_unit == "cmh2o", 1.019716, 1.0)
  
  # Special handling for 11 Hz
  if(frequency == '11'){
    params_10 <- Get_Oostveen_Params(fot_reactance_table, 10, sex)
    params_12 <- Get_Oostveen_Params(fot_reactance_table, 12, sex)
    
    pred_10 <- 4 - exp(params_10$a + params_10$b * ht_m + params_10$c * age + params_10$d * weight)
    pred_12 <- 4 - exp(params_12$a + params_12$b * ht_m + params_12$c * age + params_12$d * weight)
    
    pred <- (pred_10 + pred_12) / 2
    RSD <- (params_10$RSD + params_12$RSD) / 2
    
    ret <- -((log(4 - measured) - log(4 - (pred * press_conv))) / RSD)
    return(ret)
  }
  
  params <- Get_Oostveen_Params(fot_reactance_table, frequency, sex)
  
  # fres and AX: standard z-score
  if(frequency %in% c('fres','AX4','AX5')){
    pred <- exp(params$a + params$b * ht_m + params$c * age + params$d * weight)
    ret <- (log(measured) - log(pred * ifelse(frequency == 'fres', 1.0, press_conv))) / params$RSD
    return(ret)
  }
  
  # Standard reactance frequencies: negative z-score formula
  pred <- 4 - exp(params$a + params$b * ht_m + params$c * age + params$d * weight)
  ret <- -((log(4 - measured) - log(4 - (pred * press_conv))) / params$RSD)
  
  return(ret)
}


#' Compute Oostveen Reactance Percent Predicted
#'
#' Calculate percent predicted for measured reactance.
#'
#' @param sex Sex as character string: "Male" or "Female"
#' @param ht Height (numeric)
#' @param ht_unit Height units: "cm" (default), "in", or "m"
#' @param age Age in years (numeric)
#' @param weight Body weight (numeric)
#' @param measured Measured reactance value (numeric)
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param pressure_unit Pressure units: "cmh2o" (default) or "hpa
#' @param frequency Frequency (character)
#' @param ... Additional arguments (ignored)
#'
#' @return Percent predicted for reactance
#'
#' @references Oostveen E, et al. Eur Respir J. 2013;42(6):1513-1523.
#'
#' @export
#' @examples
#' compute_oostveen_x_percent_pred(sex = "Female", ht = 165, age = 55, weight = 65,
#'                                 measured = -0.25, frequency = "5")
compute_oostveen_x_percent_pred <- function(sex, ht, ht_unit = "cm", age, weight, measured,
                                           weight_unit = "kg", pressure_unit = "cmh2o",
                                           frequency, ...) {
  ## Percent predicted for reactance
  
  pred <- compute_oostveen_x_pred(sex = sex, ht = ht, ht_unit = ht_unit,
                                 age = age, weight = weight, weight_unit = weight_unit,
                                 pressure_unit = pressure_unit, frequency = frequency)
  
  return((measured / pred) * 100)
}
