# AHBPCEPredR

<!-- badges: start -->
[![R-CMD-check](https://github.com/tza5051/AHBPCE_Package/workflows/R-CMD-check/badge.svg)](https://github.com/tza5051/AHBPCE_Package/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->


## AHBPCE Predictions in R

AHBPCEPredR provides standardized implementations of evidence-based prediction equations for cardiopulmonary exercise testing (CPET) and pulmonary function testing (PFT) and more. All equations are derived from peer-reviewed literature and validated in diverse populations.

## Features

### Cardiopulmonary Exercise Testing (CPET)

#### VO2 max/peak Predictions
**`compute_friend_vo2(age, sex, weight, height, mode, ht_unit, weight_unit)`**

FRIEND Registry equation (Silva et al., 2020) for maximal aerobic capacity prediction.

- **Derivation**: 35,765 subjects, ages 20-90 years
- **Exercise modes**: Treadmill and cycle ergometer (separate equations)
- **Model performance**: R² = 0.56-0.60 across modes
- **Inputs**: age (years), sex, weight (kg or lbs), height (cm or in), exercise mode
- **Output**: Predicted VO2max/peak (ml/kg/min)

**Reference**: Silva AM, et al. A reference equation for maximal aerobic power for treadmill and cycle ergometer exercise testing: Analysis from the FRIEND registry. *Eur J Prev Cardiol.* 2020;25(7):742-750.

#### Heart Rate Predictions
**`compute_max_hr(age)`**

Age-predicted maximum heart rate using Arena et al. (2016) meta-regression.

- **Derivation**: Meta-analysis of 25,738 subjects across 57 studies
- **Formula**: 208 - 0.7 × age
- **Advantage**: More accurate than traditional 220 - age formula
- **95% prediction interval**: ±20 bpm
- **Input**: age (years)
- **Output**: Predicted maximum heart rate (bpm)

**Reference**: Arena R, et al. Assessment of functional capacity in clinical and research settings. *Circulation.* 2016;134(23):e705-e725.

#### O2 Pulse
**`compute_o2_pulse(age, sex, weight, height, ht_unit, weight_unit)`**

Predicted peak O2 pulse based on Ross et al. (2020).

- **Inputs**: age (years), sex, weight (kg or lbs), height (cm or in)
- **Output**: Predicted O2 pulse (ml/beat)
- **Sex-specific equations**: Separate formulations for males and females

**Reference**: Ross R, et al. Importance of assessing cardiorespiratory fitness in clinical practice. *Circulation.* 2020;142(3):184-196.

#### Ventilation Predictions
**`compute_peak_ve(age, sex, height, ht_unit)`**

Peak minute ventilation prediction from FRIEND Registry (Kaminsky et al., 2018).

- **Inputs**: age (years), sex, height (cm or in)
- **Output**: Predicted peak VE (L/min)

**`compute_mvv(fev1, method)`**

Maximum voluntary ventilation estimation per ATS/ACCP 2003 guidelines.

- **Methods**: 
  - Standard: FEV1 × 35
  - Alternative: FEV1 × 40
- **Input**: FEV1 (liters)
- **Output**: Estimated MVV (L/min)

**`compute_ventilatory_reserve(peak_ve, mvv)`**

Ventilatory reserve calculation.

- **Formula**: (1 - peak VE / MVV) × 100
- **Inputs**: peak VE (L/min), MVV (L/min)
- **Output**: Ventilatory reserve (%)

**References**: 
- Kaminsky LA, et al. Peak ventilation reference standards from exercise testing from the FRIEND Registry. *Med Sci Sports Exerc.* 2018;50(12):2603-2608.
- ATS/ACCP Statement on cardiopulmonary exercise testing. *Am J Respir Crit Care Med.* 2003;167(2):211-277.

---

### Pulmonary Function Testing (PFT)

## GLI 2021 Global Spirometry (Race-Neutral)

The GLI 2021 Global equations represent the current international standard for race-neutral spirometry interpretation. These equations eliminate race-based corrections while maintaining prediction accuracy across diverse global populations using advanced GAMLSS (Generalized Additive Models for Location, Scale and Shape) methodology.

**Reference**: Bowerman C, et al. A race-neutral approach to the interpretation of lung function measurements. *Am J Respir Crit Care Med.* 2023. | Stanojevic S, et al. Global Lung Function Initiative 2021: Race-neutral spirometry equations. *Am J Respir Crit Care Med.* 2022.

### Available Parameters
- **FEV1** - Forced Expiratory Volume in 1 second (liters)
- **FVC** - Forced Vital Capacity (liters)
- **FEV1/FVC** - Ratio (dimensionless, typically 0.70-0.85)

### Functions

**`compute_gli_pred(sex, ht, ht_unit, age, param)`**

Calculate predicted spirometry values using GLI 2021 Global equations.

- **Methodology**: GAMLSS with Box-Cox transformation
- **Equation form**: M = exp(intercept + β₁·log(height) + β₂·log(age) + Mspline)
- **Spline coefficients**: Age-varying Mspline and Sspline from lookup tables
- **Valid age range**: 3-95 years
- **Inputs**: sex ("Male"/"Female"), height (cm or in), age (years), param ("FEV1"/"FVC"/"FEV1FVC")
- **Output**: Predicted value (L or ratio)

**`compute_gli_lln(sex, ht, ht_unit, age, param)`**

Lower limit of normal (5th percentile) calculation.

- **Statistical basis**: Z-score = -1.645 (5th percentile)
- **Formula**: exp(ln(M) + ln(1 - 1.645·L·S)/L)
- **Lambda (L)**: Box-Cox transformation parameter (parameter-specific)
- **Output**: LLN value (L or ratio)

**`compute_gli_uln(sex, ht, ht_unit, age, param)`**

Upper limit of normal (95th percentile) calculation.

- **Statistical basis**: Z-score = +1.645 (95th percentile)
- **Formula**: exp(ln(M) + ln(1 + 1.645·L·S)/L)
- **Output**: ULN value (L or ratio)

**`compute_gli_zscore(sex, ht, ht_unit, age, measured, param)`**

Z-score calculation for measured spirometry values.

- **Formula**: ((measured/M)^L - 1)/(L·S)
- **Interpretation**: 
  - Z < -1.645: Below LLN
  - -1.645 ≤ Z ≤ +1.645: Normal range
  - Z > +1.645: Above ULN
- **Inputs**: All pred/LLN inputs plus measured value
- **Output**: Z-score (standard deviation units)

**`compute_gli_percent_pred(sex, ht, ht_unit, age, measured, param)`**

Percent predicted calculation.

- **Formula**: (measured/M) × 100
- **Note**: Z-scores preferred over percent predicted for clinical decisions
- **Output**: Percent predicted (%)

---

## GLI 2021 Lung Volumes

Race-neutral lung volume reference equations using GAMLSS framework consistent with GLI 2021 Global spirometry equations.

**Reference**: GLI 2021 Lung Volume supplementary material.

### Available Parameters
- **FRC** - Functional Residual Capacity (L)
- **TLC** - Total Lung Capacity (L)
- **RV** - Residual Volume (L)
- **RV/TLC** - Residual Volume to Total Lung Capacity ratio (%)
- **ERV** - Expiratory Reserve Volume (L)
- **IC** - Inspiratory Capacity (L)
- **VC** - Vital Capacity (L)

### Functions

**`compute_gli_lv_pred(sex, ht, ht_unit, age, param)`**

Calculate predicted lung volumes.

- **Methodology**: Parameter-specific GAMLSS equations
- **Spline tables**: Age-varying coefficients for each parameter
- **Validation**: Multiple measurement techniques (plethysmography, gas dilution)
- **Output**: Predicted volume (L) or ratio (%)

**`compute_gli_lv_lln(sex, ht, ht_unit, age, param)`**

Lower limit of normal for lung volumes (5th percentile).

- **Parameter-specific Lambda values**: Each lung volume has unique L and S coefficients
- **Output**: LLN (L or %)

**`compute_gli_lv_uln(sex, ht, ht_unit, age, param)`**

Upper limit of normal for lung volumes (95th percentile).

- **Output**: ULN (L or %)

**`compute_gli_lv_zscore(sex, ht, ht_unit, age, measured, param)`**

Z-score for measured lung volumes.

- **Transformation**: Uses parameter-specific Lambda (L) values
- **Output**: Z-score (SD units)

**`compute_gli_lv_percent_pred(sex, ht, ht_unit, age, measured, param)`**

Percent predicted for lung volumes.

- **Output**: Percent predicted (%)

---

## GLI 2017 Diffusing Capacity (DLCO/TLCO)

Global reference equations for single-breath carbon monoxide transfer factor, representing the ERS/ATS international standard.

**Reference**: Stanojevic S, et al. GLI-2017 ERS/ATS standards for single-breath carbon monoxide uptake in the lung. *Eur Respir J.* 2017;50(3):1700010.

### Available Parameters
- **DLCO** (TLCO) - Transfer factor for carbon monoxide (mmol/min/kPa or ml/min/mmHg)
- **KCO** - Transfer coefficient, DLCO/VA ratio (mmol/min/kPa/L or ml/min/mmHg/L)
- **VA** - Alveolar volume from single-breath test (L)

### Functions

**`compute_gli_dlco_pred(sex, ht, ht_unit, age, param)`**

Calculate predicted DLCO parameters.

- **Equation structure**: GAMLSS with age-varying splines
- **Internal data**: Spline lookup tables (Mspline, Sspline) from GLI supplementary material
- **Sex-specific**: Separate equations for males and females
- **Output**: Predicted value (mmol/min/kPa or L)

**`compute_gli_dlco_lln(sex, ht, ht_unit, age, param)`**

Lower limit of normal for DLCO parameters (5th percentile).

- **Parameter-specific variance**: Each parameter (DLCO, KCO, VA) has unique L and S values
- **Output**: LLN (units match parameter)

**`compute_gli_dlco_uln(sex, ht, ht_unit, age, param)`**

Upper limit of normal for DLCO parameters (95th percentile).

- **Output**: ULN (units match parameter)

**`compute_gli_dlco_zscore(sex, ht, ht_unit, age, measured, param)`**

Z-score for measured DLCO values.

- **Formula**: Uses Box-Cox transformation with parameter-specific Lambda
- **Output**: Z-score (SD units)

**`compute_gli_dlco_percent_pred(sex, ht, ht_unit, age, measured, param)`**

Percent predicted for DLCO parameters.

- **Output**: Percent predicted (%)

**`compute_miller_correction(sex, hgb, measured)`**

Hemoglobin correction for DLCO measurements (Miller et al., 1980).

- **Purpose**: Adjusts DLCO for abnormal hemoglobin concentration
- **Male formula**: DLCO_corrected = DLCO × (1.7 × Hgb) / (10.22 + Hgb)
- **Female formula**: DLCO_corrected = DLCO × (1.7 × Hgb) / (9.38 + Hgb)
- **Inputs**: sex, hemoglobin (g/dL), measured DLCO
- **Output**: Hemoglobin-corrected DLCO (same units as input)

**Reference**: Miller A, et al. Effect of anemia on pulmonary diffusing capacity. *Am Rev Respir Dis.* 1980;121:441-445.

---

## Forced Oscillation Technique (FOT) - Oostveen 2013

Reference equations for respiratory system impedance measured by forced oscillation technique, based on the ERS Technical Standard (Oostveen et al., 2013).

**Reference**: Oostveen E, MacLeod D, González H, et al. The forced oscillation technique in clinical practice: methodology, recommendations and future developments. *Eur Respir J.* 2013;42(6):1513-1523. doi:10.1183/09031936.00105712

### Study Characteristics
- **Population**: n=270 healthy European adults
- **Age range**: 18-91 years (validated range)
- **Design**: Multi-center study across European sites
- **Measurement**: Impulse oscillometry system (IOS)

### Available Parameters

#### Resistance (R)
Represents total respiratory resistance (airways + tissue).

#### Reactance (X)
Represents elastic and inertial properties (capacitance and inertance).


### Resistance Functions

**`compute_oostveen_r_pred(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Predicted resistance at specified frequency.

- **Equation form**: Sex-specific multiple regression
- **Predictors**: Age, height, weight
- **Frequency options**: "5", "10", "15", "20", "25", "35" (Hz)
- **Unit conversion**: Automatic between hPa·s·L⁻¹ (default) and cmH₂O·s·L⁻¹
- **Interpolation**: Linear interpolation for intermediate frequencies
- **Output**: Predicted R (specified pressure units·s·L⁻¹)

**`compute_oostveen_r_lln(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Lower limit of normal for resistance (5th percentile).

- **Calculation**: Pred - 1.645 × RSD (residual standard deviation)
- **Output**: LLN for R (specified pressure units·s·L⁻¹)

**`compute_oostveen_r_uln(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Upper limit of normal for resistance (95th percentile).

- **Calculation**: Pred + 1.645 × RSD
- **Output**: ULN for R (specified pressure units·s·L⁻¹)

**`compute_oostveen_r_zscore(sex, ht, ht_unit, age, weight, weight_unit, measured, pressure_unit, frequency)`**

Z-score for measured resistance.

- **Formula**: (measured - predicted) / RSD
- **Interpretation**:
  - Z > +1.645: Above ULN (elevated resistance)
  - -1.645 ≤ Z ≤ +1.645: Normal range
  - Z < -1.645: Below LLN (unusually low resistance)
- **Output**: Z-score (SD units)

**`compute_oostveen_r_percent_pred(sex, ht, ht_unit, age, weight, weight_unit, measured, pressure_unit, frequency)`**

Percent predicted for resistance.

- **Formula**: (measured / predicted) × 100
- **Output**: Percent predicted (%)

### Reactance Functions

**`compute_oostveen_x_pred(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Predicted reactance at specified frequency.

- **Frequency dependence**: Reactance becomes less negative (more positive) at higher frequencies
- **Output**: Predicted X (specified pressure units·s·L⁻¹)

**`compute_oostveen_x_lln(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Lower limit of normal for reactance (5th percentile).

- **Calculation**: Pred - 1.645 × RSD
- **Output**: LLN for X (specified pressure units·s·L⁻¹)

**`compute_oostveen_x_uln(sex, ht, ht_unit, age, weight, weight_unit, pressure_unit, frequency)`**

Upper limit of normal for reactance (95th percentile).

- **Calculation**: Pred + 1.645 × RSD
- **Output**: ULN for X (specified pressure units·s·L⁻¹)

**`compute_oostveen_x_zscore(sex, ht, ht_unit, age, weight, weight_unit, measured, pressure_unit, frequency)`**

Z-score for measured reactance.

- **Formula**: (measured - predicted) / RSD
- **Output**: Z-score (SD units)

**`compute_oostveen_x_percent_pred(sex, ht, ht_unit, age, weight, weight_unit, measured, pressure_unit, frequency)`**

Percent predicted for reactance.

- **Note**: Percent predicted less meaningful for reactance due to negative values and zero-crossing
- **Output**: Percent predicted (%)


#### FOT: Valach/LEAD 2025

- **Austrian Population Study**: LEAD cohort
- **Resistance (R)**: 5, 11, 19 Hz
- **Reactance (X)**: 5, 11, 19 Hz, plus fres (resonant frequency) and AX5 (reactance area)
- **Methodology**: GAMLSS (Generalized Additive Models for Location, Scale and Shape)
- **Unique Feature**: Incorporates BMI as predictor variable
- **Predictors**: Age, height, weight/BMI
- **Complete Statistical Analysis**: LLN, ULN, z-scores, and percent predicted

### Quality Control Functions
- Standardized QC checks for pulmonary function testing
- Data validation and error detection
- Clinical decision support tools


### Technical Implementation Details

**Coefficient Storage**:
- Coefficients stored in internal package data (`R/sysdata.rda`)
- Separate tables for resistance and reactance
- Sex-specific coefficients for each frequency
- Residual standard deviations (RSD) for variance estimation

**Interpolation**:
- Linear interpolation for frequencies between reference points
- Preserves exact values at 5, 10, 15, 20, 25, 35 Hz

**Unit Conversions**:
- Pressure: 1 cmH₂O = 0.098 hPa (automatic conversion)
- Height: inches to cm (×2.54)
- Weight: pounds to kg (÷2.205)

**Validation Range**:
- Age: 18-91 years (per original study)
- Functions will compute outside this range but extrapolation accuracy unknown

---

## Installation

### Method 1: GitHub Installation (Recommended)

```r
# Install required packages
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install from GitHub
devtools::install_github("tza5051/AHBPCE_Package", upgrade = "never")

# Load package
library(AHBPCEPredR)
```

### Method 2: Local Installation

```r
# From source tarball
install.packages("AHBPCEPredR_0.5.0.tar.gz", repos = NULL, type = "source")
```

---

## Usage Examples

### CPET Examples

```r
library(AHBPCEPredR)

# VO2 max prediction (treadmill)
vo2_treadmill <- compute_friend_vo2(
  age = 45, 
  sex = "Male", 
  weight = 75,        # kg
  height = 175,       # cm
  mode = "Treadmill"
)
print(vo2_treadmill)  # ml/kg/min

# VO2 max prediction (cycle) with imperial units
vo2_cycle <- compute_friend_vo2(
  age = 45,
  sex = "Male",
  weight = 165,       # lbs
  weight_unit = "lbs",
  height = 69,        # inches
  ht_unit = "in",
  mode = "Cycle"
)

# Maximum heart rate
hr_max <- compute_max_hr(age = 45)
print(hr_max)  # 176.5 bpm

# O2 pulse
o2_pulse <- compute_o2_pulse(
  age = 45,
  sex = "Male",
  weight = 75,
  height = 175
)
print(o2_pulse)  # ml/beat

# Ventilatory reserve
peak_ve <- 120  # L/min (measured)
fev1 <- 3.5     # L (measured)
mvv <- compute_mvv(fev1 = fev1, method = "standard")  # 122.5 L/min
vent_reserve <- compute_ventilatory_reserve(peak_ve = peak_ve, mvv = mvv)
print(vent_reserve)  # 2% (low reserve, suggests ventilatory limitation)
```

### Spirometry Examples

```r
# Predicted FEV1
fev1_pred <- compute_gli_pred(
  sex = "Male",
  ht = 175,
  age = 45,
  param = "FEV1"
)
print(fev1_pred)  # ~3.8 L

# Lower limit of normal for FVC
fvc_lln <- compute_gli_lln(
  sex = "Female",
  ht = 165,
  age = 55,
  param = "FVC"
)
print(fvc_lln)  # ~2.7 L

# Z-score for measured FEV1
fev1_zscore <- compute_gli_zscore(
  sex = "Male",
  ht = 175,
  age = 45,
  measured = 3.2,
  param = "FEV1"
)
print(fev1_zscore)  # ~-0.5 (within normal range)

# Percent predicted
fvc_pct <- compute_gli_percent_pred(
  sex = "Female",
  ht = 165,
  age = 55,
  measured = 3.1,
  param = "FVC"
)
print(fvc_pct)  # ~92%

# Using imperial units
fev1_imperial <- compute_gli_pred(
  sex = "Male",
  ht = 69,           # inches
  ht_unit = "in",
  age = 45,
  param = "FEV1"
)
```

### Lung Volume Examples

```r
# Predicted TLC
tlc_pred <- compute_gli_lv_pred(
  sex = "Male",
  ht = 175,
  age = 45,
  param = "TLC"
)
print(tlc_pred)  # ~6.5 L

# RV/TLC ratio (evaluate air trapping)
rvtlc_pred <- compute_gli_lv_pred(
  sex = "Female",
  ht = 165,
  age = 55,
  param = "RVTLC"
)
rvtlc_uln <- compute_gli_lv_uln(
  sex = "Female",
  ht = 165,
  age = 55,
  param = "RVTLC"
)
measured_rvtlc <- 0.42
if (measured_rvtlc > rvtlc_uln) {
  print("Elevated RV/TLC - suggests air trapping")
}

# Z-score for FRC
frc_zscore <- compute_gli_lv_zscore(
  sex = "Male",
  ht = 175,
  age = 45,
  measured = 3.5,
  param = "FRC"
)
```

### DLCO Examples

```r
# Predicted DLCO
dlco_pred <- compute_gli_dlco_pred(
  sex = "Male",
  ht = 175,
  age = 45,
  param = "DLCO"
)
print(dlco_pred)  # ~9.5 mmol/min/kPa

# Lower limit of normal for KCO
kco_lln <- compute_gli_dlco_lln(
  sex = "Female",
  ht = 165,
  age = 55,
  param = "KCO"
)
print(kco_lln)

# Z-score for measured DLCO
dlco_zscore <- compute_gli_dlco_zscore(
  sex = "Male",
  ht = 175,
  age = 45,
  measured = 8.5,
  param = "DLCO"
)
print(dlco_zscore)

# Miller correction for anemia (Hgb = 11.0 g/dL)
measured_dlco <- 8.5
corrected_dlco <- compute_miller_correction(
  sex = "Male",
  hgb = 11.0,
  measured = measured_dlco
)
print(corrected_dlco)  # ~9.8 mmol/min/kPa (corrected upward)

# Use corrected DLCO to calculate z-score
dlco_zscore_corrected <- compute_gli_dlco_zscore(
  sex = "Male",
  ht = 175,
  age = 45,
  measured = corrected_dlco,
  param = "DLCO"
)
```

### FOT Examples

```r
# Basic resistance prediction at 5 Hz
r5_pred <- compute_oostveen_r_pred(
  sex = "Male",
  ht = 180,
  age = 50,
  weight = 80,
  frequency = "5"
)
print(r5_pred)  # ~0.30 hPa·s·L⁻¹

# Using different units (imperial + cmH2O)
r5_pred_imperial <- compute_oostveen_r_pred(
  sex = "Male",
  ht = 70,               # inches
  ht_unit = "in",
  age = 50,
  weight = 176,          # pounds
  weight_unit = "lbs",
  pressure_unit = "cmh2o",
  frequency = "5"
)
print(r5_pred_imperial)  # ~3.0 cmH₂O·s·L⁻¹

# Check if measured resistance is elevated
measured_r5 <- 0.45
r5_uln <- compute_oostveen_r_uln(
  sex = "Male",
  ht = 180,
  age = 50,
  weight = 80,
  frequency = "5"
)
if (measured_r5 > r5_uln) {
  print("Elevated resistance at 5 Hz")
}

# Calculate z-score for resistance
r5_zscore <- compute_oostveen_r_zscore(
  sex = "Male",
  ht = 180,
  age = 50,
  weight = 80,
  measured = measured_r5,
  frequency = "5"
)
print(r5_zscore)  # Z > 1.645 indicates elevated resistance

# Reactance at 5 Hz (normally negative)
x5_pred <- compute_oostveen_x_pred(
  sex = "Female",
  ht = 165,
  age = 45,
  weight = 65,
  frequency = "5"
)
print(x5_pred)  # ~-0.15 hPa·s·L⁻¹ (negative is normal)

# Check if reactance is more negative than expected
measured_x5 <- -0.25
x5_lln <- compute_oostveen_x_lln(
  sex = "Female",
  ht = 165,
  age = 45,
  weight = 65,
  frequency = "5"
)
if (measured_x5 < x5_lln) {
  print("Reactance more negative than LLN - increased capacitance")
}

# Multiple frequencies
frequencies <- c("5", "10", "15", "20", "25", "35")
r_values <- sapply(frequencies, function(freq) {
  compute_oostveen_r_pred(
    sex = "Male",
    ht = 180,
    age = 50,
    weight = 80,
    frequency = freq
  )
})
print(data.frame(Frequency_Hz = frequencies, Resistance = r_values))
```

---

## Function Reference

### CPET Functions
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_friend_vo2()` | VO2max prediction | age, sex, weight, height, mode | ml/kg/min |
| `compute_max_hr()` | Maximum heart rate | age | bpm |
| `compute_o2_pulse()` | O2 pulse prediction | age, sex, weight, height | ml/beat |
| `compute_peak_ve()` | Peak ventilation | age, sex, height | L/min |
| `compute_mvv()` | Max voluntary ventilation | FEV1, method | L/min |
| `compute_ventilatory_reserve()` | Ventilatory reserve | peak VE, MVV | % |

### GLI Spirometry Functions
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_gli_pred()` | Predicted value | sex, ht, age, param | L or ratio |
| `compute_gli_lln()` | Lower limit normal (5th %ile) | sex, ht, age, param | L or ratio |
| `compute_gli_uln()` | Upper limit normal (95th %ile) | sex, ht, age, param | L or ratio |
| `compute_gli_zscore()` | Z-score | sex, ht, age, measured, param | SD units |
| `compute_gli_percent_pred()` | Percent predicted | sex, ht, age, measured, param | % |

**Parameters**: FEV1, FVC, FEV1FVC

### GLI Lung Volume Functions
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_gli_lv_pred()` | Predicted volume | sex, ht, age, param | L or % |
| `compute_gli_lv_lln()` | Lower limit normal | sex, ht, age, param | L or % |
| `compute_gli_lv_uln()` | Upper limit normal | sex, ht, age, param | L or % |
| `compute_gli_lv_zscore()` | Z-score | sex, ht, age, measured, param | SD units |
| `compute_gli_lv_percent_pred()` | Percent predicted | sex, ht, age, measured, param | % |

**Parameters**: FRC, TLC, RV, RVTLC, ERV, IC, VC

### GLI DLCO Functions
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_gli_dlco_pred()` | Predicted DLCO | sex, ht, age, param | mmol/min/kPa or L |
| `compute_gli_dlco_lln()` | Lower limit normal | sex, ht, age, param | mmol/min/kPa or L |
| `compute_gli_dlco_uln()` | Upper limit normal | sex, ht, age, param | mmol/min/kPa or L |
| `compute_gli_dlco_zscore()` | Z-score | sex, ht, age, measured, param | SD units |
| `compute_gli_dlco_percent_pred()` | Percent predicted | sex, ht, age, measured, param | % |
| `compute_miller_correction()` | Hgb correction | sex, hgb, measured | Corrected DLCO |

**Parameters**: DLCO, KCO, VA

### FOT Functions (Oostveen 2013)
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_oostveen_r_pred()` | Predicted resistance | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_r_lln()` | Lower limit normal (R) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_r_uln()` | Upper limit normal (R) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_r_zscore()` | Z-score (R) | sex, ht, age, weight, measured, freq | SD units |
| `compute_oostveen_r_percent_pred()` | Percent predicted (R) | sex, ht, age, weight, measured, freq | % |
| `compute_oostveen_x_pred()` | Predicted reactance | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_x_lln()` | Lower limit normal (X) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_x_uln()` | Upper limit normal (X) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_oostveen_x_zscore()` | Z-score (X) | sex, ht, age, weight, measured, freq | SD units |
| `compute_oostveen_x_percent_pred()` | Percent predicted (X) | sex, ht, age, weight, measured, freq | % |

**Frequencies**: 5, 10, 15, 20, 25, 35 Hz


### FOT Functions (Valach/LEAD 2025)
| Function | Purpose | Key Inputs | Output |
|----------|---------|------------|--------|
| `compute_valach_r_pred()` | Predicted resistance (GAMLSS) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_valach_r_lln()` | Lower limit normal (R) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_valach_r_uln()` | Upper limit normal (R) | sex, ht, age, weight, freq | hPa·s·L⁻¹ |
| `compute_valach_r_zscore()` | Z-score (R) | sex, ht, age, weight, measured, freq | SD units |
| `compute_valach_r_percent_pred()` | Percent predicted (R) | sex, ht, age, weight, measured, freq | % |
| `compute_valach_x_pred()` | Predicted reactance (GAMLSS) | sex, ht, age, weight, freq | hPa·s·L⁻¹ or Hz |
| `compute_valach_x_lln()` | Lower limit normal (X) | sex, ht, age, weight, freq | hPa·s·L⁻¹ or Hz |
| `compute_valach_x_uln()` | Upper limit normal (X) | sex, ht, age, weight, freq | hPa·s·L⁻¹ or Hz |
| `compute_valach_x_zscore()` | Z-score (X) | sex, ht, age, weight, measured, freq | SD units |
| `compute_valach_x_percent_pred()` | Percent predicted (X) | sex, ht, age, weight, measured, freq | % |


---

## Getting Help

```r
# Package overview
help(package = "AHBPCEPredR")

# Function-specific help
?compute_friend_vo2
?compute_gli_pred
?compute_gli_lv_pred
?compute_gli_dlco_pred
?compute_miller_correction
?compute_oostveen_r_pred
?compute_oostveen_x_pred
?compute_valach_r_pred
?compute_valach_r_lln
?compute_valach_r_zscore

# List all functions
ls("package:AHBPCEPredR")
```

---

## References

### CPET References

**Silva AM, Mattos WL, Freitas VH, et al.** A reference equation for maximal aerobic power for treadmill and cycle ergometer exercise testing: Analysis from the FRIEND registry. *European Journal of Preventive Cardiology.* 2020;25(7):742-750. doi:10.1177/2047487316686442

**Arena R, Sietsema KE, Myers J.** Assessment of functional capacity in clinical and research settings: A scientific statement from the American Heart Association Committee on Exercise, Rehabilitation, and Prevention of the Council on Clinical Cardiology and the Council on Cardiovascular Nursing. *Circulation.* 2016;134(23):e705-e725. doi:10.1161/CIR.0000000000000461

**Ross R, Blair SN, Arena R, et al.** Importance of assessing cardiorespiratory fitness in clinical practice: A case for fitness as a clinical vital sign: A scientific statement from the American Heart Association. *Circulation.* 2020;142(3):e184-e203. doi:10.1161/CIR.0000000000000768

**Kaminsky LA, Arena R, Myers J, et al.** Peak ventilation reference standards from exercise testing from the FRIEND Registry. *Medicine & Science in Sports & Exercise.* 2018;50(12):2603-2608. doi:10.1249/MSS.0000000000001729

**American Thoracic Society; American College of Chest Physicians.** ATS/ACCP Statement on cardiopulmonary exercise testing. *American Journal of Respiratory and Critical Care Medicine.* 2003;167(2):211-277. doi:10.1164/rccm.167.2.211

### Pulmonary Function Testing References

**Bowerman C, Bhakta NR, Brazzale D, et al.** A race-neutral approach to the interpretation of lung function measurements. *American Journal of Respiratory and Critical Care Medicine.* 2023;207(6):768-774. doi:10.1164/rccm.202206-1103OC

**Stanojevic S, Kaminsky DA, Miller MR, et al.** Global Lung Function Initiative 2021: Race-neutral spirometry equations. *American Journal of Respiratory and Critical Care Medicine.* 2022;205(2):228-234. doi:10.1164/rccm.202104-0883OC

**GLI 2021 Supplementary Material.** Global Lung Function Initiative reference equations for lung volumes. Available from: European Respiratory Society publications.

**Stanojevic S, Graham BL, Cooper BG, et al.** GLI-2017 ERS/ATS standards for single-breath carbon monoxide uptake in the lung. *European Respiratory Journal.* 2017;50(3):1700010. doi:10.1183/13993003.00010-2017

**Miller A, Thornton JC, Warshaw R, et al.** Effect of anemia on pulmonary diffusing capacity: The use of a theoretical model. *American Review of Respiratory Disease.* 1980;121(3):441-445. doi:10.1164/arrd.1980.121.3.441

**Oostveen E, MacLeod D, González H, et al.** The forced oscillation technique in clinical practice: methodology, recommendations and future developments. *European Respiratory Journal.* 2013;42(6):1513-1523. doi:10.1183/09031936.00105712

---

## Support

For questions, bug reports, or feature requests, please open an issue on GitHub:
https://github.com/tza5051/AHBPCE_Package/issues

---

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

---

## Authors

- **Tom Alexander** - *Lead Developer* - thomas.alexander3@va.gov
- **Shobhik Chakraborty** - *Developer* - shobhik.chakraborty@va.gov

---

## Version History


- **v0.6.0** - Added FOT Valach/LEAD 2025 equations (resistance and reactance at 5, 11, 19 Hz with GAMLSS methodology)
- **v0.5.0** - Added FOT (Forced Oscillation Technique) equations from Oostveen et al. 2013
- **v0.4.0** - Added GLI 2017 DLCO equations (DLCO, KCO, VA) and Miller hemoglobin correction
- **v0.3.0** - Added GLI 2021 lung volume equations (FRC, TLC, RV, RV/TLC, ERV, IC, VC)
- **v0.2.0** - Added GLI 2021 Global spirometry equations (FEV1, FVC, FEV1/FVC)
- **v0.1.0** - Initial release with CPET calculations