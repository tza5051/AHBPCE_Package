# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

**AHBPCEPredR** is an R package providing standardized clinical prediction equations for:
- Cardiopulmonary exercise testing (CPET): FRIEND VO2, Arena max HR, Ross O2 pulse
- Spirometry: GLI 2021 Global (race-neutral) FEV1, FVC, FEV1/FVC
- Lung volumes: GLI 2021 FRC, TLC, RV, RV/TLC, ERV, IC, VC
- DLCO: GLI 2017 DLCO/TLCO, KCO, VA + Miller hemoglobin correction
- Forced Oscillation Technique (FOT): Oostveen 2013 and Valach/LEAD 2025 equations

## Common Commands

```r
# Install dependencies and load package during development
devtools::load_all()

# Generate documentation from roxygen comments (updates NAMESPACE and man/*.Rd)
devtools::document()

# Build and check the package
devtools::check()

# Run tests (testthat)
devtools::test()

# Rebuild internal package data (after modifying data-raw/ scripts or Excel source files)
source("data-raw/prepare_sysdata.R")
```

## Architecture

### Internal Data (`R/sysdata.rda`)
All prediction coefficients and spline tables are stored as internal data objects in `sysdata.rda`. These are prepared from Excel source files in `data-raw/` using `data-raw/prepare_sysdata.R` (the master orchestration script). When adding or modifying prediction equations that require lookup tables, update the relevant `data-raw/prepare_*.R` script and re-run `prepare_sysdata.R`.

Internal data objects:
- `SplineSheets` — GLI spirometry spline tables
- `SplineSheetsLV` — GLI lung volume spline tables
- `SplineSheetsDLCO` — GLI DLCO spline tables
- `fot_resistance_table`, `fot_reactance_table` — Oostveen FOT coefficients

### Function Naming Convention
All exported functions follow `compute_<source>_<parameter>_<output>()`:
- Sources: `friend`, `gli`, `gli_lv`, `gli_dlco`, `oostveen`, `valach`
- Outputs: `pred`, `lln`, `uln`, `zscore`, `percent_pred`
- Example: `compute_gli_pred()`, `compute_oostveen_r_zscore()`, `compute_valach_x_lln()`

### Statistical Output Pattern
Every prediction domain implements 5 output types: predicted value, LLN (5th percentile, z = -1.645), ULN (95th percentile, z = +1.645), z-score, and percent predicted. When adding a new equation set, implement all 5.

### Unit Handling
Functions accept both metric and imperial inputs with internal conversion:
- Height: cm (default) or inches
- Weight: kg (default) or pounds
- FOT pressure: hPa (default) or cmH₂O

### Documentation
All functions use roxygen2 (`@param`, `@return`, `@examples`, `@export`). After editing function documentation, run `devtools::document()` to regenerate `NAMESPACE` and `man/*.Rd` files. Do not manually edit these generated files.
