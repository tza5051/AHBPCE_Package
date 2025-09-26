#' Compute FRIEND VO2 Prediction
#'
#' Calculate predicted peak VO2 using the FRIEND equation from Silva et al. 2020.
#' Formula: 45.2 - (0.35*age) - (10.9 * sex) - (0.15 * weight) + (0.68 * height) - (0.46 * exercise_mode)
#'
#' @param age Age in years (numeric)
#' @param sex Sex as character string: "Male" or "Female" 
#' @param weight Body weight (numeric)
#' @param mode Exercise mode: "Treadmill" or "Bike"
#' @param weight_unit Weight units: "kg" (default) or "lbs"
#' @param height Height (numeric)
#' @param height_unit Height units: "cm" (default) or "in"
#' @param ... Additional arguments (ignored)
#' 
#' @return Predicted peak VO2 in ml/kg/min
#' 
#' @references Silva AM, et al. A reference equation for maximal aerobic power 
#' for treadmill and cycle ergometer exercise testing: Analysis from the FRIEND registry. 
#' Eur J Prev Cardiol. 2020;25(7):742-750.
#' 
#' @export
#' @examples
#' # Calculate predicted VO2 for a 45-year-old male
#' compute_friend_vo2(age = 45, sex = "Male", weight = 80, height = 180, mode = "Treadmill")
compute_friend_vo2 <- function(age, sex, weight, mode, weight_unit = "kg", height, height_unit = "cm", ...) {
  
  # Input validation
  if (!sex %in% c("Male", "Female")) {
    stop("sex must be 'Male' or 'Female'")
  }
  if (!mode %in% c("Treadmill", "Bike")) {
    stop("mode must be 'Treadmill' or 'Bike'")
  }
  if (!weight_unit %in% c("kg", "lbs")) {
    stop("weight_unit must be 'kg' or 'lbs'")
  }
  if (!height_unit %in% c("cm", "in")) {
    stop("height_unit must be 'cm' or 'in'")
  }
  
  # Convert sex to numeric: Male = 1, Female = 2
  sex_code <- ifelse(sex == "Male", 1, 2)
  
  # Convert mode to numeric: Treadmill = 1, Bike = 2
  mode_code <- ifelse(mode == "Treadmill", 1, 2)
  
  # Convert height to inches if needed
  if (height_unit == "cm") {
    height <- height * 0.393701
  }
  
  # Convert weight to pounds if needed
  if (weight_unit == "kg") {
    weight <- weight * 2.20462
  }
  
  # Calculate predicted VO2
  vo2_predicted <- 45.2 - (0.35 * age) - (10.9 * sex_code) - (0.15 * weight) + 
                   (0.68 * height) - (0.46 * mode_code)
  
  return(vo2_predicted)
}

#' Compute Predicted O2 Pulse
#'
#' Calculate predicted O2 pulse using the equation from Ross et al. 2020.
#' Formula: 23.2 - 0.09(age) - 6.6(sex)
#'
#' @param age Age in years (numeric)
#' @param sex Sex as character string: "Male" or "Female"
#' @param ... Additional arguments (ignored)
#' 
#' @return Predicted O2 pulse in ml/beat
#' 
#' @references Ross R, et al. Importance of assessing cardiorespiratory fitness 
#' in clinical practice. Circulation. 2020;142(3):184-196.
#' 
#' @export
#' @examples
#' compute_o2_pulse(age = 45, sex = "Female")
compute_o2_pulse <- function(age, sex, ...) {
  
  # Input validation
  if (!sex %in% c("Male", "Female")) {
    stop("sex must be 'Male' or 'Female'")
  }
  
  # Convert sex to numeric: Male = 0, Female = 1
  sex_code <- ifelse(sex == "Male", 0, 1)
  
  # Calculate predicted O2 pulse
  o2_pulse_predicted <- 23.2 - (0.09 * age) - (6.6 * sex_code)
  
  return(o2_pulse_predicted)
}

#' Compute Predicted Peak Ventilation (VE)
#'
#' Calculate predicted peak ventilation using equation from Kaminsky et al. 2018.
#' Formula: 17.32 - 28.33(sex) - 0.79(age) + 1.85(height)
#'
#' @param age Age in years (numeric)
#' @param sex Sex as character string: "Male" or "Female"
#' @param height Height (numeric)
#' @param height_unit Height units: "cm" (default) or "in"
#' @param ... Additional arguments (ignored)
#' 
#' @return Predicted peak VE in L/min
#' 
#' @references Kaminsky LA, et al. Peak ventilation reference standards from exercise 
#' testing from the FRIEND Registry. Med Sci Sports Exerc. 2018;50(12):2603-2608.
#' 
#' @export
#' @examples
#' compute_peak_ve(age = 45, sex = "Male", height = 180)
compute_peak_ve <- function(age, sex, height, height_unit = "cm", ...) {
  
  # Input validation
  if (!sex %in% c("Male", "Female")) {
    stop("sex must be 'Male' or 'Female'")
  }
  if (!height_unit %in% c("cm", "in")) {
    stop("height_unit must be 'cm' or 'in'")
  }
  
  # Convert height to inches if needed
  if (height_unit == "cm") {
    height <- height * 0.393701
  }
  
  # Convert sex to numeric: Male = 0, Female = 1
  sex_code <- ifelse(sex == "Male", 0, 1)
  
  # Calculate predicted VE
  ve_predicted <- 17.32 - (28.33 * sex_code) - (0.79 * age) + (height * 1.85)
  
  return(ve_predicted)
}

#' Compute Predicted Maximum Heart Rate
#'
#' Calculate age-predicted maximum heart rate using Arena et al. 2016 equation.
#' Formula: 209.3 - (0.72 * age)
#'
#' @param age Age in years (numeric)
#' @param ... Additional arguments (ignored)
#' 
#' @return Predicted maximum heart rate in beats per minute
#' 
#' @references Arena R, et al. Assessment of functional capacity in clinical and research 
#' settings. Circulation. 2016;134(23):e705-e725.
#' 
#' @export
#' @examples
#' compute_max_hr(age = 45)
compute_max_hr <- function(age, ...) {
  hr_predicted <- 209.3 - (0.72 * age)
  return(hr_predicted)
}

#' Compute Calculated Maximum Voluntary Ventilation (MVV)
#'
#' Calculate MVV using the ATS 2003 recommendation: FEV1 * 40
#'
#' @param fev1 Forced Expiratory Volume in 1 second (numeric)
#' @param fev1_units FEV1 units: "L" (default) or "mL"
#' @param ... Additional arguments (ignored)
#' 
#' @return Calculated MVV in L/min
#' 
#' @references ATS/ACCP Statement on cardiopulmonary exercise testing. 
#' Am J Respir Crit Care Med. 2003;167(2):211-277.
#' 
#' @export
#' @examples
#' compute_mvv(fev1 = 3.5)
compute_mvv <- function(fev1, fev1_units = "L", ...) {
  
  # Input validation
  if (!fev1_units %in% c("L", "mL")) {
    stop("fev1_units must be 'L' or 'mL'")
  }
  
  # Convert to liters if needed
  if (fev1_units == "mL") {
    fev1 <- fev1 / 1000
  }
  
  # Calculate MVV
  mvv <- fev1 * 40
  
  return(mvv)
}

#' Compute Ventilatory Reserve
#'
#' Calculate ventilatory reserve using ATS 2003 formula: (1 - VE_peak/cMVV) * 100
#'
#' @param ve_peak Peak ventilation (numeric)
#' @param ve_units VE units: "L" (default) or "mL"
#' @param fev1 Forced Expiratory Volume in 1 second (numeric)
#' @param fev1_units FEV1 units: "L" (default) or "mL"
#' @param ... Additional arguments (ignored)
#' 
#' @return Ventilatory reserve as percentage
#' 
#' @references ATS/ACCP Statement on cardiopulmonary exercise testing. 
#' Am J Respir Crit Care Med. 2003;167(2):211-277.
#' 
#' @export
#' @examples
#' compute_ventilatory_reserve(ve_peak = 120, fev1 = 3.5)
compute_ventilatory_reserve <- function(ve_peak, ve_units = "L", fev1, fev1_units = "L", ...) {
  
  # Input validation
  if (!ve_units %in% c("L", "mL")) {
    stop("ve_units must be 'L' or 'mL'")
  }
  if (!fev1_units %in% c("L", "mL")) {
    stop("fev1_units must be 'L' or 'mL'")
  }
  
  # Convert to liters if needed
  if (ve_units == "mL") {
    ve_peak <- ve_peak / 1000
  }
  if (fev1_units == "mL") {
    fev1 <- fev1 / 1000
  }
  
  # Calculate ventilatory reserve
  vr <- (1 - ve_peak / (fev1 * 40)) * 100
  
  return(vr)
}