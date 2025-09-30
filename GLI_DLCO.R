## +++++++++++++++++++++ Compute Predictive Value Modules+++++++++++++++++++++++++++ ##
#   Siyang Zeng
#   01/02/2024                      
#   Local Module 
##------
# Various Wrapper Function for Computing the predictive values in PFT based
#   on GLI Reference Equations for TLCO
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

import(dplyr)
import(stringr)

## ---------------------------- Lookup Table Values ------------------------------
# Values coming from the GLI2021 publication SI Look-up tables
# 
import(readxl)
TLCO_DLCO_male <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx", 
                             sheet = "TLCO_SI_m")
TLCO_DLCO_female <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx",
                               sheet = "TLCO_SI_f")
KCO_male <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx", 
                             sheet = "KCO_SI_m")
KCO_female <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx",
                               sheet = "KCO_SI_f")
VA_male <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx", 
                                                sheet = "VA_m")
VA_female <- read_excel("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_DLCO-supplementary-material-2.xlsx",
                        sheet = "VA_f")


## ---------------------------- Functions ------------------------------


Lookup_Spline = function(age,sex,variable){
  ## Helper function to extract Mspline and Sspline value based on Age
  if(variable=="DLCO"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = TLCO_DLCO_male[,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = TLCO_DLCO_female[,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="KCO"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = KCO_male[,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = KCO_female[,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="VA"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = VA_male[,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = VA_female[,c("age","Mspline","Sspline")]
    }
  }
  # first find the closest age from the look up table age
  age_delta = abs(spline_tab$age - age)
  # find the index of the closest age
  s = which.min(age_delta)
  
  ret = list(spline_tab$Mspline[s], spline_tab$Sspline[s] )
  names(ret) = c('Mspline', 'Sspline')
  return(ret)
  
}

export('Compute_Pred') # Predicted Values in L
Compute_Pred = function(sex, ht, ht_unit = 'cm', age, param = 'DLCO', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('DLCO','VA', 'KCO'))
  stopifnot(ht_unit %in% c('cm', 'in'))
  
  if(ht_unit == "in") {
    ht <- ht * 2.54 #convert in to cm
  } 
  
  # Look up values for Mspline and Sspline:
  lookup_res = mapply(FUN = function(x,y,z) Lookup_Spline(x,y,z),age,sex,param)
  mspline = unlist(lookup_res['Mspline', ])
  sspline = unlist(lookup_res['Sspline', ])
  
  param = str_to_upper(param)
  ret = ifelse(
    sex %in% c("M", 'Male', 'MALE'),  
    # Male version
    switch(
      param,
      # Lung Volume:
      'DLCO' = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline),
      'KCO' = exp(4.088408 - 0.415334* log(ht) - 0.113166 * log(age) + mspline),
      'VA' = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'DLCO' = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline),
      'KCO' = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline),
      'VA' = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline)
    )
  )
  return(ret)
}

export('Compute_LLN') # Lower Limit of Norm
Compute_LLN = function(sex, ht, ht_unit = 'cm', age, param = 'DLCO', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('DLCO', 'KCO', 'VA'))
  stopifnot(ht_unit %in% c('cm', 'in'))
  
  if(ht_unit == "in") {
    ht <- ht * 2.54 #convert in to cm
  } 
  
  # Look up values for Mspline and Sspline:
  lookup_res = mapply(FUN = function(x,y,z) Lookup_Spline(x,y,z),age,sex,param)
  mspline = unlist(lookup_res['Mspline', ])
  sspline = unlist(lookup_res['Sspline', ])
  
  param = str_to_upper(param)
  ret = ifelse(
    sex %in% c("M", 'Male', 'MALE'),  
    # Male version
    switch(
      param,
      # lung volume
      'DLCO' = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline +
                     log(1 - 1.645 * 0.39482 * 
                           exp(-1.98996 + 0.03536 * log(age) + sspline)) / 0.39482),
      
      'KCO' = exp(4.088408 - 0.415334* log(ht) - 0.113166 * log(age) + mspline +
                     log(1 - 1.645 * 0.67330 * 
                           exp(-1.98186 + 0.01460 * log(age) + sspline)) / 0.67330),
      
      'VA' = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline +
                   log(1 - 1.645 * 0.62559 * 
                         exp(-2.20953 + 0.01937 * log(age) +sspline)) / 0.62559)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'DLCO' = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline +
                     log(1 - 1.645 * 0.24160 * 
                           exp(-1.82905 - 0.01815 * log(age) + sspline)) / 0.24160),
      
      'KCO' = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline +
                    log(1 - 1.645 * 0.48963 * 
                          exp(-1.63787 - 0.07757 * log(age) + sspline)) / 0.48963),
      
      'VA' = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline +
                   log(1 - 1.645 * 0.51919 * 
                         exp(-2.08839 - 0.01334 * log(age) + sspline)) / 0.51919)
    )
  )
  return(ret)
}

export('Compute_ULN') # Upper Limit of Norm
Compute_ULN = function(sex, ht, ht_unit = 'cm', age, param = 'DLCO', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('DLCO', 'kCO', 'VA') )
  stopifnot(ht_unit %in% c('cm', 'in'))
  
  if(ht_unit == "in") {
    ht <- ht * 2.54 #convert in to cm
  } 
  
  # Look up values for Mspline and Sspline:
  lookup_res = mapply(FUN = function(x,y,z) Lookup_Spline(x,y,z),age,sex,param)
  mspline = unlist(lookup_res['Mspline', ])
  sspline = unlist(lookup_res['Sspline', ])
  
  param = str_to_upper(param)
  ret = ifelse(
    sex %in% c("M", 'Male', 'MALE'),  
    # Male version
    switch(
      param,
      # lung volume
      'DLCO' = exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline +
                     log(1 + 1.645 * 0.39482 * 
                           exp(-1.98996 + 0.03536 * log(age) + sspline)) / 0.39482),
      
      'KCO' = exp(4.088408 - 0.415334* log(ht) - 0.113166 * log(age) + mspline +
                    log(1 + 1.645 * 0.67330 * 
                          exp(-1.98186 + 0.01460 * log(age) + sspline)) / 0.67330),
      
      'VA' = exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline +
                   log(1 + 1.645 * 0.62559 * 
                         exp(-2.20953 + 0.01937 * log(age) +sspline)) / 0.62559)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'DLCO' = exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline +
                     log(1 + 1.645 * 0.24160 * 
                           exp(-1.82905 - 0.01815 * log(age) + sspline)) / 0.24160),
      
      'KCO' = exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline +
                    log(1 + 1.645 * 0.48963 * 
                          exp(-1.63787 - 0.07757 * log(age) + sspline)) / 0.48963),
      
      'VA' = exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline +
                   log(1 + 1.645 * 0.51919 * 
                         exp(-2.08839 - 0.01334 * log(age) + sspline)) / 0.51919)
    )
  )
  return(ret)
}

export('Compute_Zscore') # Upper Limit of Norm
Compute_Zscore = function(sex, ht, age, ht_unit = 'cm', measured, param = 'DLCO', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('DLCO', 'KCO', 'VA'))
  stopifnot(ht_unit %in% c('cm', 'in'))
  
  if(ht_unit == "in") {
    ht <- ht * 2.54 #convert in to cm
  } 
  
  # Look up values for Mspline and Sspline:
  lookup_res = mapply(FUN = function(x,y,z) Lookup_Spline(x,y,z),age,sex,param)
  mspline = unlist(lookup_res['Mspline', ])
  sspline = unlist(lookup_res['Sspline', ])
  
  param = str_to_upper(param)
  ret = ifelse(
    sex %in% c("M", 'Male', 'MALE'),  
    # Male version
    switch(
      param,
      # lung volume
      'DLCO' = (((measured/(exp(-7.034920 + 2.018368 * log(ht) - 0.012425 * log(age) + mspline)))^0.39482) - 1) 
                / (0.39482 * (exp(-1.98996 + 0.03536 * log(age) + sspline))),
      
      'KCO' = (((measured/exp(4.088408 - 0.415334 * log(ht) - 0.113166 * log(age) + mspline))^0.67330) - 1) 
                / 0.67330 * exp(-1.98186 + 0.01460 * log(age) + sspline),
      
      'VA' = (((measured/exp(-11.086573 + 2.430021 * log(ht) + 0.097047 * log(age) + mspline))^0.62559) - 1)
                / (0.62559 * (exp(-2.20953 + 0.01937 * log(age) + sspline)))
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'DLCO' = (((measured/exp(-5.159451 + 1.618697 * log(ht) - 0.015390 * log(age) + mspline))^0.24160) - 1)
                     / (0.24160 * (exp(-1.82905 + 0.01815 * log(age) + sspline))),
      
      'KCO' = (((measured/exp(5.131492 - 0.645656 * log(ht) - 0.097395 * log(age) + mspline))^0.48963) - 1)
                    / 0.48963 * exp(-1.63787 - 0.07757 * log(age) + sspline),
      
      'VA' = (((measured/exp(-9.873970 + 2.182316 * log(ht) + 0.082868 * log(age) + mspline))^0.51919) - 1)
                    /0.51919 * exp(-2.08839 + 0.01334 * log(age) + sspline)
    )
  )
  return(ret)
}

#Miller Correction
export('Compute_Miller_Corrected')
Compute_Miller_Corrected = function(sex, hgb, measured, ...){
#sex as string, "Male" or "Female"
  DLCO.corrected <- measured * (1.7*hgb / ifelse(sex == "Male", (10.22 + hgb), (9.38 + hgb)))
  
  return(DLCO.corrected)
}







