# GLI 2021 Global Functions - Quick Reference

## Function Overview

| Function | Purpose | Returns |
|----------|---------|---------|
| `compute_gli_pred()` | Predicted value | Liters or ratio |
| `compute_gli_lln()` | Lower limit of normal (5th %ile) | Liters or ratio |
| `compute_gli_uln()` | Upper limit of normal (95th %ile) | Liters or ratio |
| `compute_gli_zscore()` | Standardized score | Z-score (SD units) |
| `compute_gli_percent_pred()` | Percent of predicted | Percentage |

## Common Parameters

All functions share these parameters:

- **sex**: `"Male"` or `"Female"` (also accepts `"M"`, `"F"`, `"MALE"`, `"FEMALE"`)
- **ht**: Height value (numeric)
- **ht_unit**: `"cm"` (default) or `"in"`
- **age**: Age in years (numeric)
- **param**: `"FEV1"`, `"FVC"`, or `"FEV1FVC"`

Additional for z-score and percent predicted:
- **measured**: Measured value in liters (or ratio for FEV1/FVC)

## Usage Examples

### 1. Predicted Values
```r
# Male, 45 years, 175 cm
fev1 <- compute_gli_pred(sex = "Male", ht = 175, age = 45, param = "FEV1")
fvc <- compute_gli_pred(sex = "Male", ht = 175, age = 45, param = "FVC")
ratio <- compute_gli_pred(sex = "Male", ht = 175, age = 45, param = "FEV1FVC")

# Using inches
fev1_in <- compute_gli_pred(sex = "Male", ht = 69, ht_unit = "in", 
                            age = 45, param = "FEV1")
```

### 2. Reference Limits
```r
# Lower limit of normal (LLN)
fev1_lln <- compute_gli_lln(sex = "Female", ht = 165, age = 55, param = "FEV1")

# Upper limit of normal (ULN)
fvc_uln <- compute_gli_uln(sex = "Female", ht = 165, age = 55, param = "FVC")

# Check if measured value is below LLN
measured_fev1 <- 2.8
is_below_lln <- measured_fev1 < fev1_lln
```

### 3. Z-Scores
```r
# Calculate z-score for measured FEV1 = 3.2 L
zscore <- compute_gli_zscore(sex = "Male", ht = 175, age = 45,
                             measured = 3.2, param = "FEV1")

# Interpretation
if (zscore < -1.645) {
  print("Below LLN - possible impairment")
} else if (zscore > 1.645) {
  print("Above ULN")
} else {
  print("Within normal range")
}
```

### 4. Percent Predicted
```r
# Calculate percent predicted for measured FVC = 4.5 L
percent_pred <- compute_gli_percent_pred(sex = "Female", ht = 165, age = 55,
                                         measured = 4.5, param = "FVC")

# Clinical interpretation (NOTE: Use LLN for definitive assessment)
if (percent_pred >= 80) {
  print("Generally normal")
} else if (percent_pred >= 70) {
  print("Mild impairment")
} else if (percent_pred >= 60) {
  print("Moderate impairment")
} else {
  print("Severe impairment")
}
```

### 5. Complete PFT Report
```r
# Generate complete spirometry interpretation
patient_data <- list(
  sex = "Male",
  age = 45,
  height_cm = 175,
  fev1_measured = 3.2,
  fvc_measured = 4.5,
  ratio_measured = 0.71
)

# Calculate all parameters for FEV1
fev1_pred <- compute_gli_pred(sex = patient_data$sex, 
                              ht = patient_data$height_cm,
                              age = patient_data$age, 
                              param = "FEV1")
fev1_lln <- compute_gli_lln(sex = patient_data$sex,
                            ht = patient_data$height_cm,
                            age = patient_data$age,
                            param = "FEV1")
fev1_zscore <- compute_gli_zscore(sex = patient_data$sex,
                                  ht = patient_data$height_cm,
                                  age = patient_data$age,
                                  measured = patient_data$fev1_measured,
                                  param = "FEV1")
fev1_pct <- compute_gli_percent_pred(sex = patient_data$sex,
                                     ht = patient_data$height_cm,
                                     age = patient_data$age,
                                     measured = patient_data$fev1_measured,
                                     param = "FEV1")

# Print report
cat(sprintf("FEV1 Report:\n"))
cat(sprintf("  Measured: %.2f L\n", patient_data$fev1_measured))
cat(sprintf("  Predicted: %.2f L\n", fev1_pred))
cat(sprintf("  LLN: %.2f L\n", fev1_lln))
cat(sprintf("  Percent Predicted: %.1f%%\n", fev1_pct))
cat(sprintf("  Z-score: %.2f\n", fev1_zscore))
cat(sprintf("  Interpretation: %s\n", 
    ifelse(fev1_zscore < -1.645, "Below LLN", "Normal")))
```

### 6. Batch Processing Multiple Patients
```r
# Process multiple patients
patients <- data.frame(
  id = 1:3,
  sex = c("Male", "Female", "Male"),
  age = c(45, 55, 62),
  height_cm = c(175, 165, 180),
  fev1_measured = c(3.2, 2.8, 3.5)
)

# Calculate z-scores for all patients
patients$fev1_zscore <- mapply(
  compute_gli_zscore,
  sex = patients$sex,
  ht = patients$height_cm,
  age = patients$age,
  measured = patients$fev1_measured,
  MoreArgs = list(param = "FEV1")
)

# Flag abnormal results
patients$abnormal <- patients$fev1_zscore < -1.645

print(patients)
```

## Clinical Interpretation Guidelines

### Z-Score Interpretation
- **< -1.645**: Below LLN (5th percentile) - **clinically significant**
- **-1.645 to +1.645**: Normal range (5th to 95th percentile)
- **> +1.645**: Above ULN (95th percentile)

### Why Use Z-Scores?
1. **Standardized**: Comparable across age, sex, and height
2. **Statistical**: Expressed in standard deviation units
3. **Clinical threshold**: -1.645 corresponds to 5th percentile (LLN)
4. **Better than % predicted**: Accounts for variability in predictions

### Severity Classification (if using % predicted)
- **≥80%**: Normal range*
- **70-79%**: Mild impairment
- **60-69%**: Moderate impairment
- **50-59%**: Moderately severe impairment
- **<50%**: Severe impairment

*Note: Always use LLN (z-score < -1.645) as the primary criterion for abnormality

## Parameter Definitions

- **FEV1**: Forced Expiratory Volume in 1 second (L)
- **FVC**: Forced Vital Capacity (L)
- **FEV1/FVC**: Ratio (dimensionless, typically 0.70-0.85)

## Key Advantages of GLI 2021 Global Equations

1. **Race-neutral**: Eliminates problematic race-based corrections
2. **Globally applicable**: Derived from diverse populations worldwide
3. **Continuous predictions**: Smooth curves across all ages (3-95 years)
4. **Modern statistics**: Uses advanced GAMLSS methodology
5. **Evidence-based**: Published in major respiratory journals

## Error Handling

```r
# Check for invalid inputs
tryCatch({
  result <- compute_gli_pred(sex = "Male", ht = 175, age = 45, 
                             param = "INVALID")
}, error = function(e) {
  cat("Error:", e$message, "\n")
})

# Validate age range (equations valid for ages 3-95)
validate_age <- function(age) {
  if (age < 3 || age > 95) {
    warning("Age outside validated range (3-95 years)")
  }
}
```

## References

Bowerman C, Bhakta NR, Brazzale D, et al. A race-neutral approach to the 
interpretation of lung function measurements. Am J Respir Crit Care Med. 2023.
