# AHBPCEPredR

<!-- badges: start -->
[![R-CMD-check](https://github.com/tza5051/AHBPCE_Package/workflows/R-CMD-check/badge.svg)](https://github.com/tza5051/AHBPCE_Package/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

## AHB Pulmonary Clinical Exercise Predictions in R

AHBPCEPredR is a comprehensive R package designed for cardiopulmonary exercise testing (CPET) calculations and pulmonary function predictions used in clinical practice. The package provides standardized implementations of widely-used prediction equations and quality control functions for pulmonary function laboratories and exercise physiology clinics.

## Features

### CPET Calculations
- **FRIEND VO2 Predictions**: Based on Silva et al. 2020 equation
- **Maximum Heart Rate**: Using Arena et al. 2016 formula
- **O2 Pulse Calculations**: Based on Ross et al. 2020
- **Peak Ventilation (VE)**: Using Kaminsky et al. 2018 equation  
- **Maximum Voluntary Ventilation (MVV)**: ATS 2003 guidelines
- **Ventilatory Reserve**: Clinical calculation for exercise limitation assessment

### Pulmonary Function Testing (PFT) - GLI 2021 Global Equations

#### Spirometry
- **Race-Neutral Reference Equations**: GLI 2021 Global (race-neutral) spirometry equations
- **FEV1 Predictions**: Forced Expiratory Volume in 1 second
- **FVC Predictions**: Forced Vital Capacity
- **FEV1/FVC Ratio**: Airflow obstruction assessment
- **Lower Limit of Normal (LLN)**: 5th percentile reference values
- **Upper Limit of Normal (ULN)**: 95th percentile reference values
- **Z-Score Calculations**: Standardized deviation from predicted values
- **Percent Predicted**: Clinical interpretation of measured values

#### Lung Volumes
- **Race-Neutral Lung Volume Equations**: GLI 2021 Global lung volume equations
- **FRC**: Functional Residual Capacity
- **TLC**: Total Lung Capacity
- **RV**: Residual Volume
- **RV/TLC Ratio**: Restrictive pattern assessment
- **ERV**: Expiratory Reserve Volume
- **IC**: Inspiratory Capacity
- **VC**: Vital Capacity
- **Complete Statistical Analysis**: LLN, ULN, z-scores, and percent predicted for all parameters

### Quality Control Functions
- Standardized QC checks for pulmonary function testing
- Data validation and error detection
- Clinical decision support tools

## Installation

### Method 1: Easy Installation (Recommended)
Download and run the installation script for best results:

```r
# Install required packages first
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install from GitHub
devtools::install_github("tza5051/AHBPCE_Package", upgrade = "never")

# Load the package
library(AHBPCEPredR)
```

### Method 2: Local Installation
If you have the package file:
```r
# Install from local tar.gz file
install.packages("AHBPCEPredR_0.3.0.tar.gz", repos = NULL, type = "source")
```

## Quick Start

### CPET Examples

```r
library(AHBPCEPredR)

# Calculate FRIEND VO2 prediction for a 45-year-old male
vo2_pred <- compute_friend_vo2(age = 45, sex = "Male", 
                               weight = 75, height = 175, 
                               mode = "Treadmill")
print(vo2_pred)

# Calculate maximum heart rate
max_hr <- compute_max_hr(age = 45)
print(max_hr)

# Calculate predicted O2 pulse
o2_pulse <- compute_o2_pulse(age = 45, sex = "Male", 
                             weight = 75, height = 175)
print(o2_pulse)
```

### Pulmonary Function Testing Examples

#### Spirometry
```r
# Calculate predicted FEV1 for a 45-year-old male, 175 cm tall
fev1_pred <- compute_gli_pred(sex = "Male", ht = 175, age = 45, param = "FEV1")
print(fev1_pred)

# Calculate lower limit of normal for FVC
fvc_lln <- compute_gli_lln(sex = "Female", ht = 165, age = 55, param = "FVC")
print(fvc_lln)

# Calculate z-score for a measured FEV1 of 3.2 L
fev1_zscore <- compute_gli_zscore(sex = "Male", ht = 175, age = 45, 
                                  measured = 3.2, param = "FEV1")
print(fev1_zscore)

# Calculate percent predicted for measured FVC of 4.5 L
fvc_percent <- compute_gli_percent_pred(sex = "Female", ht = 165, age = 55,
                                        measured = 4.5, param = "FVC")
print(fvc_percent)

# Using inches for height
fev1_pred_in <- compute_gli_pred(sex = "Male", ht = 69, ht_unit = "in", 
                                 age = 45, param = "FEV1")
print(fev1_pred_in)
```

#### Lung Volumes
```r
# Calculate predicted TLC for a 45-year-old male, 175 cm tall
tlc_pred <- compute_gli_lv_pred(sex = "Male", ht = 175, age = 45, param = "TLC")
print(tlc_pred)

# Calculate lower limit of normal for RV
rv_lln <- compute_gli_lv_lln(sex = "Female", ht = 165, age = 55, param = "RV")
print(rv_lln)

# Calculate z-score for a measured FRC of 3.5 L
frc_zscore <- compute_gli_lv_zscore(sex = "Male", ht = 175, age = 45, 
                                    measured = 3.5, param = "FRC")
print(frc_zscore)

# Calculate percent predicted for measured TLC of 6.5 L
tlc_percent <- compute_gli_lv_percent_pred(sex = "Male", ht = 175, age = 45,
                                           measured = 6.5, param = "TLC")
print(tlc_percent)

# Calculate RV/TLC ratio
rvtlc_pred <- compute_gli_lv_pred(sex = "Female", ht = 165, age = 55, param = "RVTLC")
print(rvtlc_pred)
```

## Function Reference

### CPET Functions
- `compute_friend_vo2()`: FRIEND VO2 prediction equation
- `compute_max_hr()`: Age-predicted maximum heart rate
- `compute_o2_pulse()`: Predicted O2 pulse calculation
- `compute_peak_ve()`: Predicted peak ventilation
- `compute_mvv()`: Maximum voluntary ventilation from FEV1
- `compute_ventilatory_reserve()`: Ventilatory reserve calculation

### GLI 2021 Global (Race-Neutral) PFT Functions

#### Spirometry Functions
- `compute_gli_pred()`: Calculate predicted values for FEV1, FVC, or FEV1/FVC
- `compute_gli_lln()`: Calculate lower limit of normal (5th percentile)
- `compute_gli_uln()`: Calculate upper limit of normal (95th percentile)
- `compute_gli_zscore()`: Calculate z-score for measured values
- `compute_gli_percent_pred()`: Calculate percent predicted

#### Lung Volume Functions
- `compute_gli_lv_pred()`: Calculate predicted values for FRC, TLC, RV, RV/TLC, ERV, IC, or VC
- `compute_gli_lv_lln()`: Calculate lower limit of normal (5th percentile) for lung volumes
- `compute_gli_lv_uln()`: Calculate upper limit of normal (95th percentile) for lung volumes
- `compute_gli_lv_zscore()`: Calculate z-score for measured lung volumes
- `compute_gli_lv_percent_pred()`: Calculate percent predicted for lung volumes

### Quality Control Functions
- Various QC functions for data validation and clinical decision support

## Getting Help

After installation, you can access help documentation:

```r
# Package overview
help(package = "AHBPCEPredR")

# Function-specific help - CPET
?compute_friend_vo2
?compute_max_hr
?compute_o2_pulse
?compute_peak_ve
?compute_mvv
?compute_ventilatory_reserve

# Function-specific help - GLI PFT Spirometry
?compute_gli_pred
?compute_gli_lln
?compute_gli_uln
?compute_gli_zscore
?compute_gli_percent_pred

# Function-specific help - GLI Lung Volumes
?compute_gli_lv_pred
?compute_gli_lv_lln
?compute_gli_lv_uln
?compute_gli_lv_zscore
?compute_gli_lv_percent_pred

# List all available functions
ls("package:AHBPCEPredR")
```

## Clinical Interpretation

### GLI 2021 Z-Scores
- **Z-score < -1.645**: Below lower limit of normal (LLN) - may indicate impairment
- **Z-score between -1.645 and +1.645**: Within normal range
- **Z-score > +1.645**: Above upper limit of normal (ULN)

### Percent Predicted Guidelines
- **≥80%**: Generally considered normal (but use LLN for definitive interpretation)
- **70-79%**: Mild impairment
- **60-69%**: Moderate impairment
- **<60%**: Severe impairment

**Note**: Z-scores and LLN/ULN provide more accurate clinical interpretation than percent predicted alone.

### Lung Volume Parameters
- **FRC** (Functional Residual Capacity): Volume of air in lungs at end of normal expiration
- **TLC** (Total Lung Capacity): Maximum volume of air lungs can hold
- **RV** (Residual Volume): Volume remaining after maximal expiration
- **RV/TLC**: Ratio for assessing air trapping (elevated in obstructive disease)
- **ERV** (Expiratory Reserve Volume): Additional air that can be expired after normal expiration
- **IC** (Inspiratory Capacity): Maximum air that can be inspired from FRC
- **VC** (Vital Capacity): Maximum air that can be expired after maximal inspiration

## Clinical References

The equations implemented in this package are based on peer-reviewed clinical literature:

### CPET References
- **Silva AM, et al.** A reference equation for maximal aerobic power for treadmill and cycle ergometer exercise testing: Analysis from the FRIEND registry. *Eur J Prev Cardiol.* 2020;25(7):742-750.

- **Arena R, et al.** Assessment of functional capacity in clinical and research settings. *Circulation.* 2016;134(23):e705-e725.

- **Ross R, et al.** Importance of assessing cardiorespiratory fitness in clinical practice. *Circulation.* 2020;142(3):184-196.

- **Kaminsky LA, et al.** Peak ventilation reference standards from exercise testing from the FRIEND Registry. *Med Sci Sports Exerc.* 2018;50(12):2603-2608.

- **ATS/ACCP Statement** on cardiopulmonary exercise testing. *Am J Respir Crit Care Med.* 2003;167(2):211-277.

### Pulmonary Function Testing References
- **Bowerman C, et al.** A race-neutral approach to the interpretation of lung function measurements. *Am J Respir Crit Care Med.* 2023. [GLI 2021 Global Equations - Spirometry]

- **Stanojevic S, et al.** Global Lung Function Initiative 2021: Race-neutral spirometry equations. *Am J Respir Crit Care Med.* 2022.

- **GLI 2021 Lung Volume Equations.** Global Lung Function Initiative reference equations for lung volumes. [Supplementary material]

## Support

For questions about clinical applications or bug reports, please open an issue on GitHub at https://github.com/tza5051/AHBPCE_Package/issues.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Authors

- **Tom Alexander** - *Lead Developer* - thomas.alexander3@va.gov
- **Shobhik Chakraborty** - *Developer* - shobhik.chakraborty@va.gov

## Version History

- **v0.3.0** - Added GLI 2021 lung volume equations (FRC, TLC, RV, RV/TLC, ERV, IC, VC)
- **v0.2.0** - Added GLI 2021 Global spirometry equations (FEV1, FVC, FEV1/FVC)
- **v0.1.0** - Initial release with CPET calculations