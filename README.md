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

### Quality Control Functions
- Standardized QC checks for pulmonary function testing
- Data validation and error detection
- Clinical decision support tools

## Installation

### Method 1: Easy Installation (Recommended)
Download and run the installation script for best results:

```r
# Download and run the installation script
source("https://raw.githubusercontent.com/tza5051/AHBPCE_Package/main/install_ahbpcepredr.R")
```

### Method 2: Manual Installation
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

### Method 3: Local Installation
If you have the package file:
```r
# Install from local tar.gz file
install.packages("AHBPCEPredR_0.1.0.tar.gz", repos = NULL, type = "source")
```

## Quick Start

```r
library(AHBPCEPredR)

# Calculate FRIEND VO2 prediction for a 45-year-old male
## Function Reference

### CPET Functions
- `compute_friend_vo2()`: FRIEND VO2 prediction equation
- `compute_max_hr()`: Age-predicted maximum heart rate
- `compute_o2_pulse()`: Predicted O2 pulse calculation
- `compute_peak_ve()`: Predicted peak ventilation
- `compute_mvv()`: Maximum voluntary ventilation from FEV1
- `compute_ventilatory_reserve()`: Ventilatory reserve calculation

## Getting Help

After installation, you can access help documentation:

```r
# Package overview
help(package = "AHBPCEPredR")

# Function-specific help
?compute_friend_vo2
?compute_max_hr
?compute_o2_pulse
?compute_peak_ve
?compute_mvv
?compute_ventilatory_reserve

# List all available functions
ls("package:AHBPCEPredR")
```

### Quality Control Functions
- Various QC functions for data validation and clinical decision support

# Calculate O2 pulse for a female patient
o2_pulse <- compute_o2_pulse(age = 45, sex = "Female")
print(paste("Predicted O2 Pulse:", round(o2_pulse, 1), "ml/beat"))
```

## Function Reference

## Support

For questions about clinical applications or bug reports, please open an issue on GitHub at https://github.com/tza5051/AHBPCE_Package/issues.

## Troubleshooting

**Problem**: "No package index found" error when using `help(package = "AHBPCEPredR")`

**Solution**: Use the installation script (Method 1) or try:
```r
# Rebuild help indices manually
.rs.restartR()  # Restart R session
library(AHBPCEPredR)
```
- `compute_o2_pulse()`: Predicted O2 pulse calculation
- `compute_peak_ve()`: Predicted peak ventilation
- `compute_mvv()`: Maximum voluntary ventilation from FEV1
- `compute_ventilatory_reserve()`: Ventilatory reserve calculation

### Quality Control Functions
- Various QC functions for data validation and clinical decision support

## Clinical References

The equations implemented in this package are based on peer-reviewed clinical literature:

- **Silva AM, et al.** A reference equation for maximal aerobic power for treadmill and cycle ergometer exercise testing: Analysis from the FRIEND registry. *Eur J Prev Cardiol.* 2020;25(7):742-750.

- **Arena R, et al.** Assessment of functional capacity in clinical and research settings. *Circulation.* 2016;134(23):e705-e725.

- **Ross R, et al.** Importance of assessing cardiorespiratory fitness in clinical practice. *Circulation.* 2020;142(3):184-196.

- **Kaminsky LA, et al.** Peak ventilation reference standards from exercise testing from the FRIEND Registry. *Med Sci Sports Exerc.* 2018;50(12):2603-2608.

- **ATS/ACCP Statement** on cardiopulmonary exercise testing. *Am J Respir Crit Care Med.* 2003;167(2):211-277.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

This package is developed for clinical use in pulmonary function laboratories. Please contact the authors for contributions or suggestions.

## Authors

- **Tom Alexander** - *Lead Developer* - thomas.alexander3@va.gov
- **Shobhik Rajaram** - *Developer*

## Support

For questions about clinical applications or bug reports, please open an issue on GitHub at https://github.com/tza5051/AHBPCE_Package/issues.