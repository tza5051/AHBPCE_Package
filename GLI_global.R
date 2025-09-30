## +++++++++++++++++++++ Compute Predictive Value Modules+++++++++++++++++++++++++++ ##
#   Thomas Alexander
#   01/02/2024                      
#   Local Module 
##------
# Various Wrapper Function for Computing the predictive values in PFT based
#   on GLI 2021 Reference Equations

## Mspline, Sspline correspond to the age-varying coefficients from 
## the look-up tables provided in the supplementary material. 
## Height and age are expressed as cm and years, respectively. 
## Predicted value: M; 
## lower limit of normal (5th percentile): exp(ln(M) + ln(1 - 1.645*L*S)/L); 
## upper limit of normal (5th percentile): exp(ln(M) + ln(1 + 1.645*L*S)/L); 
## z-score: ((measured/M)L - 1)/(L*S); 
## % predicted: (measured/M)*100; 
## exp: natural exponential; ln: natural logarithm.

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

import(dplyr)
import(stringr)

## ---------------------------- Lookup Table Values ------------------------------
# Values coming from the GLI2021 publication SI Look-up tables
# 
import(readxl)
read_excel_allsheets = function(filename, tibble = FALSE) {
  sheets = readxl::excel_sheets(filename)
  x = lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x = lapply(x, as.data.frame)
  names(x) = sheets
  x
}

SplineSheets = read_excel_allsheets("gli_global_lookuptables_dec6.xlsx")


## ---------------------------- Functions ------------------------------


Lookup_Spline = function(age,sex,variable){
  ## Helper function to extract Mspline and Sspline value based on Age
  if(variable=="FEV1"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[1]][,c("Age","M Spline","S Spline")]
    }
    else{
      spline_tab = SplineSheets[[4]][,c("Age","M Spline","S Spline")]
    }
  }
  else if(variable=="FVC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[2]][,c("Age","M Spline","S Spline")]
    }
    else{
      spline_tab = SplineSheets[[5]][,c("age","M Spline","S Spline")]
    }
  }
  else if(variable=="FEV1FVC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[3]][,c("Age","M Spline","S Spline")]
    }
    else{
      spline_tab = SplineSheets[[6]][,c("Age","M Spline","S Spline")]
    }
  }
  names(spline_tab) = c("age","Mspline","Sspline")
  # first find the closest age from the look up table age
  age_delta = abs(spline_tab$age - age)
  # find the index of the closest age
  s = which.min(age_delta)
  
  ret = list(spline_tab$Mspline[s], spline_tab$Sspline[s] )
  names(ret) = c('Mspline', 'Sspline')
  return(ret)
  
}

export('Compute_Pred') # Predicted Values in L
Compute_Pred = function(sex, ht, ht_unit = 'cm', age, param = 'FEV1', ...){
  ## Predicted value: M
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('FEV1','FVC','FEV1FVC') )
  
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
      'FEV1' = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline),
      'FVC' = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline),
      'FEV1FVC' = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FEV1' = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) +   mspline),
      'FVC' = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline),
      'FEV1FVC' = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline)
    )
  )
  return(ret)
}

export('Compute_LLN') # Lower Limit of Normal: exp(ln(M) + ln(1 - 1.645*L*S)/L)
Compute_LLN = function(sex, ht, ht_unit = 'cm', age, param = 'FEV1', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('FEV1','FVC','FEV1FVC') )
  
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
      'FEV1' = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline +
                     (log(1 - 1.645 * 1.22703 * 
                           exp(-2.256278 + 0.080729*log(age) + sspline)) / 1.22703)),
      'FVC' = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline +
                   (log(1 - 1.645 * 0.9346 * 
                         exp(-2.195595 + 0.068466*log(age) + sspline)) / 0.9346)),
      'FEV1FVC' = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline +
                    (log(1 - 1.645 * (3.8243 - 0.3328*log(age)) * 
                          exp(-2.882025 + 0.068889*log(age) + sspline)) / 
                      (3.8243 - 0.3328*log(age))))
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FEV1' = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) +   mspline +
                     (log(1 - 1.645 * 1.21388 * 
                           exp(-2.364047 + 0.129402*log(age) + sspline)) / 1.21388)),
      'FVC' = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline +
                   (log(1 - 1.645 * 0.899 * 
                         exp(-2.310148 + 0.120428*log(age) + sspline)) / 0.899)),
      'FEV1FVC' = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline +
                    (log(1 - 1.645 * (6.6490  -0.9920*log(age)) * 
                          exp(-3.171582 + 0.144358*log(age) + sspline)) / 
                      (6.6490  -0.9920*log(age))))
    )
  )
  return(ret)
}

export('Compute_ULN') # Upper Limit of Normal: exp(ln(M) + ln(1 + 1.645??L??S)/L)
Compute_ULN = function(sex, ht, ht_unit = 'cm', age, param = 'FEV1', ...){
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('FEV1','FVC','FEV1FVC') )
  
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
      'FEV1' = exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline +
                     (log(1 + 1.645 * 1.22703 * 
                           exp(-2.256278 + 0.080729*log(age) + sspline)) / 1.22703)),
      'FVC' = exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline +
                    (log(1 + 1.645 * 0.9346 * 
                          exp(-2.195595 + 0.068466*log(age) + sspline)) / 0.9346)),
      'FEV1FVC' = exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline +
                        (log(1 + 1.645 * (3.8243 - 0.3328*log(age)) * 
                              exp(-2.882025 + 0.068889*log(age) + sspline)) / 
                        (3.8243 - 0.3328*log(age))))
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FEV1' = exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) +   mspline +
                     (log(1 + 1.645 * 1.21388 * 
                           exp(-2.364047 + 0.129402*log(age) + sspline)) / 1.21388)),
      'FVC' = exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline +
                    log(1 + 1.645 * 0.899 * 
                          exp(-2.310148 + 0.120428*log(age) + sspline)) / 0.899),
      'FEV1FVC' = exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline +
                        (log(1 + 1.645 * (6.6490  -0.9920*log(age)) * 
                              exp(-3.171582 + 0.144358*log(age) + sspline)) / 
                        (6.6490  -0.9920*log(age))))
    )
  )
  return(ret)
}

# ((measured/M)^L - 1)/(L*S)
export('Compute_Zscore') # z-score: ((measured/M)^L - 1)/(L*S)
Compute_Zscore = function(sex, ht, ht_unit = 'cm', age, measured, param = 'FEV1', ...){
  ## Predicted value: M
  ## NOTE: default unit for height(ht):[cm] unless specified to [in], unit for age:[year]
  stopifnot(param %in% c('FEV1','FVC','FEV1FVC') )
  
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
      'FEV1' = (((measured/(exp(-11.399108 + 2.462664*log(ht) - 0.011394*log(age) + mspline)))^1.22703) - 1)/
                  (1.22703*(exp(-2.256278 + 0.080729*log(age) + sspline))),
      
      'FVC' = ((measured/exp(-12.629131 + 2.727421*log(ht) + 0.009174*log(age) + mspline))^0.9346 - 1)/
                  (0.9346*exp(-2.195595 + 0.068466*log(age) + sspline)),
      'FEV1FVC' = ((measured/exp(1.022608 - 0.218592*log(ht) - 0.027586*log(age) + mspline))^(3.8243 - 0.3328*log(age)) - 1)/
                  ((3.8243 - 0.3328*log(age))*exp(-2.882025 + 0.068889*log(age) + sspline))
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FEV1' = ((measured/exp(-10.901689 + 2.385928*log(ht) - 0.076386*log(age) +   mspline))^1.21388 - 1)/
                  (1.21388*exp(-2.364047 + 0.129402*log(age) + sspline)),
      'FVC' = ((measured/exp(-12.055901 + 2.621579*log(ht) - 0.035975*log(age) + mspline))^0.899 - 1)/
                  (0.899*exp(-2.310148 + 0.120428*log(age) + sspline)),
      'FEV1FVC' = ((measured/exp(0.9189568 - 0.1840671*log(ht) - 0.0461306*log(age) + mspline))^ (6.6490  -0.9920*log(age)) - 1)/
                  ((6.6490  -0.9920*log(age))*exp(-3.171582 + 0.144358*log(age) + sspline))
    )
  )
  return(ret)
}








