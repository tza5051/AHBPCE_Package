## +++++++++++++++++++++ Compute Predictive Value Modules+++++++++++++++++++++++++++ ##
#   Jianhong Chen, Siyang Zeng
#   01/02/2024                      
#   Local Module 
##------
# Various Wrapper Function for Computing the predictive values in PFT based
#   on GLI 2021 Reference Equations
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ##

import(dplyr)
import(stringr)

## ---------------------------- Lookup Table Values ------------------------------
# Values coming from the GLI2021 publication SI Look-up tables
import(readxl)
read_excel_allsheets = function(filename, tibble = FALSE) {
  sheets = readxl::excel_sheets(filename)
  x = lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x = lapply(x, as.data.frame)
  names(x) = sheets
  x
}

SplineSheets = read_excel_allsheets("R:/Principal_Investigators/Falvo/MATLAB SCRIPTS_Falvo/R_modules/GLI_lung_volume-supplementary-material-2.xlsx")

## ---------------------------- Functions ------------------------------


Lookup_Spline = function(age,sex,variable){
  ## Helper function to extract Mspline and Sspline value based on Age
  if(variable=="FRC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[1]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[2]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="TLC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[3]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[4]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="RV"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[5]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[6]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="RVTLC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[7]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[8]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="ERV"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[9]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[10]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="IC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[11]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[12]][,c("age","Mspline","Sspline")]
    }
  }
  else if(variable=="VC"){
    if(sex %in% c("M", 'Male', 'MALE')){
      spline_tab = SplineSheets[[13]][,c("age","Mspline","Sspline")]
    }
    else{
      spline_tab = SplineSheets[[14]][,c("age","Mspline","Sspline")]
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
Compute_Pred = function(sex, ht, ht_unit = 'cm', age, param = 'FRC', ...){
  ## NOTE: unit for height(ht):[cm], takes [in] and converts to [cm], unit for age:[year]
  stopifnot(param %in% c('FRC', 'TLC', 'RV', 'RVTLC', 'ERV', 'IC', 'VC') )
  
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
      'FRC' = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline),
      'TLC' = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline),
      'RV' = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline ),
      'RVTLC' = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline),
      'ERV' = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline),
      'IC' = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline),
      'VC' = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FRC' = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline),
      'TLC' = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline),
      'RV' =  exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline ),
      'RVTLC' = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline),
      'ERV' = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline),
      'IC' = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline),
      'VC' = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline)
    )
  )
  return(ret)
}

export('Compute_LLN') # Lower Limit of Norm
Compute_LLN = function(sex, ht, ht_unit = 'cm', age, param = 'FRC', ...){
  ## NOTE: unit for height(ht):[cm], takes [in] and converts to [cm], unit for age:[year]
  stopifnot(param %in% c('FRC', 'TLC', 'RV', 'RVTLC', 'ERV', 'IC', 'VC') )
  
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
      'FRC' = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.3416 * 
                          exp(-1.60197 + 0.01513 * log(age) + sspline)) / 0.3416),
      'TLC' = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline +
                    log(1 - 1.645 * 0.9337 * 
                          exp(-2.0616143 - 0.0008534 * age + sspline)) / 0.9337),
      'RV' = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline + 
                   log(1 - 1.645 * 0.5931 * 
                         exp(-0.878572 - 0.007032 * age + sspline)) / 0.5931),
      'RVTLC' = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline + 
                      log(1 - 1.645 * 0.8646 * 
                            exp(-0.96804 - 0.01004 * age + sspline)) / 0.8646),
      'ERV' = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline +
                    log(1 - 1.645 * 0.5517 * 
                          exp(-1.307616 + 0.009177 * age)) / 0.5517),
      'IC' = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline + 
                   log(1 - 1.645 * 1.146 * 
                         exp(-1.856546 + 0.002008 * age)) / 1.146),
      'VC' = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline +
                   log(1 - 1.645 * 0.8611 * 
                         exp(-2.1367411 + 0.0009367 * age)) / 0.8611)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FRC' = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.2898 * 
                          exp(-1.48310 - 0.03372 * log(age) + sspline)) / 0.2898),
      'TLC' = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline + 
                    log(1 - 1.645 * 0.4636 * 
                          exp(-2.0999321 + 0.0001564 * age + sspline)) / 0.4636),
      'RV' =  exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline + 
                    log(1 - 1.645 * 0.4197 * 
                          exp(-0.902550 - 0.006005 * age + sspline)) / 0.4197),
      'RVTLC' = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline +
                      log(1 - 1.645 * 0.8037 * 
                            exp(-0.976602 - 0.009679 * age + sspline)) / 0.8037),
      'ERV' = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline +
                    log(1 - 1.645 * 0.5326 * 
                          exp(-1.54992 + 0.01409 * age)) / 0.5326),
      'IC' = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline +
                   log(1 - 1.645 * 0.9726 * 
                         exp(-1.775276 + 0.002673 * age)) / 0.9726),
      'VC' = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline +
                   log(1 - 1.645 * 1.038 * 
                         exp(-2.220260 + 0.002956 * age)) / 1.038)
    )
  )
  return(ret)
}

export('Compute_ULN') # Upper Limit of Norm
Compute_ULN = function(sex, ht, ht_unit = 'cm', age, param = 'FRC', ...){
  ## NOTE: unit for height(ht):[cm], takes [in] and converts to [cm], unit for age:[year]
  stopifnot(param %in% c('FRC', 'TLC', 'RV', 'RVTLC', 'ERV', 'IC', 'VC') )
  
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
      'FRC' = exp(-13.4898 + 0.1111 * log(age) + 2.7634 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.3416 * 
                          exp(-1.60197 + 0.01513 * log(age) + sspline)) / 0.3416),
      'TLC' = exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline +
                    log(1 + 1.645 * 0.9337 * 
                          exp(-2.0616143 - 0.0008534 * age + sspline)) / 0.9337),
      'RV' = exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline + 
                   log(1 + 1.645 * 0.5931 * 
                         exp(-0.878572 - 0.007032 * age + sspline)) / 0.5931),
      'RVTLC' = exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline + 
                      log(1 + 1.645 * 0.8646 * 
                            exp(-0.96804 - 0.01004 * age + sspline)) / 0.8646),
      'ERV' = exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline +
                    log(1 + 1.645 * 0.5517 * 
                          exp(-1.307616 + 0.009177 * age)) / 0.5517),
      'IC' = exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline + 
                   log(1 + 1.645 * 1.146 * 
                         exp(-1.856546 + 0.002008 * age)) / 1.146),
      'VC' = exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline +
                   log(1 + 1.645 * 0.8611 * 
                         exp(-2.1367411 + 0.0009367 * age)) / 0.8611)
    ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FRC' = exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.2898 * 
                          exp(-1.48310 - 0.03372 * log(age) + sspline)) / 0.2898),
      'TLC' = exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline + 
                    log(1 + 1.645 * 0.4636 * 
                          exp(-2.0999321 + 0.0001564 * age + sspline)) / 0.4636),
      'RV' =  exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline + 
                    log(1 + 1.645 * 0.4197 * 
                          exp(-0.902550 - 0.006005 * age + sspline)) / 0.4197),
      'RVTLC' = exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline +
                      log(1 + 1.645 * 0.8037 * 
                            exp(-0.976602 - 0.009679 * age + sspline)) / 0.8037),
      'ERV' = exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline +
                    log(1 + 1.645 * 0.5326 * 
                          exp(-1.54992 + 0.01409 * age)) / 0.5326),
      'IC' = exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline +
                   log(1 + 1.645 * 0.9726 * 
                         exp(-1.775276 + 0.002673 * age)) / 0.9726),
      'VC' = exp(-9.230600 - 0.005517 * age + 2.116822 * log(ht) + mspline +
                   log(1 + 1.645 * 1.038 * 
                         exp(-2.220260 + 0.002956 * age)) / 1.038)
    )
  )
  return(ret)
}


export('Compute_Zscore') # Upper Limit of Norm
Compute_Zscore = function(sex, ht, ht_unit = 'cm', age, measured, param = 'FRC', ...){
  ## NOTE: unit for height(ht):[cm], takes [in] and converts to [cm], unit for age:[year]
  stopifnot(param %in% c('FRC', 'TLC', 'RV', 'RVTLC', 'ERV', 'IC', 'VC'))
  
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
      'FRC' =  ((measured/exp(-13.4898 + 0.1111 * log(age) +2.7634 * log(ht) + mspline))^0.3416 - 1) / 
        (0.3416 * exp(-1.60197 + 0.01513 * log(age) + sspline)),
      
      'TLC' = ((measured/exp(-10.5861 + 0.1433 * log(age) + 2.3155 * log(ht) + mspline))^0.9337 - 1) / 
        (0.9337 * exp(-2.0616143 - 0.0008534 * age + sspline)),
      
      'RV' = ((measured/exp(-2.37211 + 0.01346 * age + 0.01307 * ht + mspline))^0.5931 - 1) / 
        (0.5931 * exp(-0.878572 - 0.007032 * age + sspline)),
      
      'RVTLC' = ((measured/exp(2.634 + 0.01302 * age - 0.00008862 * ht + mspline))^0.8646 - 1) / 
        (0.8646 * exp(-0.96804 - 0.01004 * age + sspline)),
      
      'ERV' = ((measured/exp(-17.328650 - 0.006288 * age + 3.478116 * log(ht) + mspline))^0.5517 - 1) / 
        (0.5517 * exp(-1.307616 + 0.009177 * age)),
      
      'IC' = ((measured/exp(-10.121688 + 0.001265 * age + 2.188801 * log(ht) + mspline))^1.146 - 1) / 
        (1.146 * exp(-1.856546 + 0.002008 * age)),
      
      'VC' = ((measured/exp(-10.134371 - 0.003532 * age + 2.307980 * log(ht) + mspline))^0.8611 - 1) / 
        (0.8611 * exp(-2.1367411 + 0.0009367 * age))
      ),
    
    # Female version
    switch(
      param,
      # lung volume
      'FRC' =  ((measured / exp(-12.7674 + 0.1251 * log(age) + 2.6049 * log(ht) + mspline))^0.2898 -1 ) / 
        (0.2898 * exp(-1.48310 - 0.03372 * log(age) + sspline)),
      
      'TLC' =  ((measured / exp(-10.1128 + 0.1062 * log(age) + 2.2259 * log(ht) + mspline))^0.4636 - 1) / 
        (0.4636 * exp(-2.0999321 + 0.0001564 * age + sspline)),
      
      'RV' =   ((measured / exp(-2.50593 + 0.01307 * age + 0.01379 * ht + mspline))^0.4197 - 1) / 
        (0.4197 * exp(-0.902550 - 0.006005 * age + sspline)),
      
      'RVTLC' =  ((measured / exp(2.666 + 0.01411 * age - 0.00003689 * ht + mspline))^0.8037 - 1) /
        (0.8037 * exp(-0.976602 - 0.009679 * age + sspline)),
      
      'ERV' =  ((measured / exp(-14.145513 - 0.009573 * age + 2.871446 * log(ht) + mspline))^0.5326 - 1) / 
        (0.5326 * exp(-1.54992 + 0.01409 * age)),
      
      'IC' =  ((measured/ exp(-9.4438787 - 0.0002484 * age + 2.0312769 * log(ht) + mspline))^0.9726 - 1) / 
        (0.9726 * exp(-1.775276 + 0.002673 * age)),
      
      'VC' =  ((measured/ exp(-9.230600 - 0.005517 *age + 2.116822 * log(ht) + mspline))^1.038 - 1) / 
        (1.038 * exp(-2.220260 + 0.002956 * age))
    )
  )
  return(ret)
}






