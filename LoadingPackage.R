library(devtools)
library(usethis)

# Prepare the DLCO lookup tables
source("data-raw/prepare_dlco_spline_tables.R")



# Generate documentation
document()

# Load the package
load_all()

# Test DLCO predicted value
dlco_pred <- compute_gli_dlco_pred(sex = "Male", ht = 175, age = 45, param = "DLCO")
print(dlco_pred)

# Test KCO lower limit of normal
kco_lln <- compute_gli_dlco_lln(sex = "Male", ht = 175, age = 45, param = "KCO")
print(kco_lln)

# Test DLCO z-score
dlco_zscore <- compute_gli_dlco_zscore(sex = "Male", ht = 175, age = 45, 
                                       measured = 8.5, param = "DLCO")
print(dlco_zscore)

# Test VA percent predicted
va_percent <- compute_gli_dlco_percent_pred(sex = "Female", ht = 165, age = 55,
                                            measured = 5.2, param = "VA")
print(va_percent)

# Test Miller correction (for anemia: Hgb = 11.0 g/dL)
dlco_corrected <- compute_miller_correction(sex = "Male", hgb = 11.0, measured = 8.5)
print(dlco_corrected)

# Run comprehensive package check
check()
