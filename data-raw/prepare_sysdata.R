
## -------------------------------------------------------------------
## AHBPCEPredR: Prepare ALL internal data (GLI + FOT) for sysdata.rda
## -------------------------------------------------------------------

suppressPackageStartupMessages({
  library(usethis)
  library(readxl)
})

cat("=== AHBPCEPredR: Preparing internal data (GLI + FOT) ===\n\n")

## 1. Build / load GLI spline lookup tables ---------------------------

cat("Step 1/3: Running GLI data preparation scripts...\n")

# These scripts should ultimately create:
#   - SplineSheets      (spirometry)
#   - SplineSheetsLV    (lung volumes)
#   - SplineSheetsDLCO  (DLCO)
#
# They will use the following Excel files in data-raw:
#   - gli_global_lookuptables_dec6 2.xlsx
#   - GLI_lung_volume-supplementary-material-2.xlsx
#   - GLI_DLCO-supplementary-material-2.xlsx

# If gli_splines.R is needed by the others, source it first:
if (file.exists("data-raw/gli_splines.R")) {
  source("data-raw/gli_splines.R")
}

# Spirometry / global splines
if (file.exists("data-raw/prepare_spline_tables.R")) {
  source("data-raw/prepare_spline_tables.R")
}

# Lung volume splines
if (file.exists("data-raw/prepare_lv_spline_tables.R")) {
  source("data-raw/prepare_lv_spline_tables.R")
}

# DLCO splines
if (file.exists("data-raw/prepare_dlco_spline_tables.R")) {
  source("data-raw/prepare_dlco_spline_tables.R")
}

# Sanity check: make sure objects exist
required_gli_objs <- c("SplineSheets", "SplineSheetsLV", "SplineSheetsDLCO")
missing_gli <- required_gli_objs[!vapply(required_gli_objs, exists, logical(1))]

if (length(missing_gli) > 0) {
  stop(
    "The following GLI objects were not created by the prep scripts: ",
    paste(missing_gli, collapse = ", "),
    "\nCheck the data-raw GLI scripts."
  )
}

cat("  ✓ GLI objects available:",
    paste(required_gli_objs, collapse = ", "),
    "\n\n")

## 2. Read FOT coefficient tables from Excel --------------------------

cat("Step 2/3: Reading FOT coefficient tables from Excel...\n")

fot_excel_path <- "data-raw/FOT_predictions_coefficient_tables_2024-02-16.xlsx"

if (!file.exists(fot_excel_path)) {
  stop("FOT Excel file not found at: ", fot_excel_path)
}

fot_resistance_table <- read_excel(
  fot_excel_path,
  sheet = "Resistance"
)

fot_reactance_table <- read_excel(
  fot_excel_path,
  sheet = "Reactance"
)

cat("  ✓ Resistance sheet rows:", nrow(fot_resistance_table), "\n")
cat("  ✓ Reactance sheet rows :", nrow(fot_reactance_table), "\n\n")

## 3. Save ALL internal data in one shot ------------------------------

cat("Step 3/3: Saving all internal objects to R/sysdata.rda...\n")

usethis::use_data(
  SplineSheets,
  SplineSheetsLV,
  SplineSheetsDLCO,
  fot_resistance_table,
  fot_reactance_table,
  internal  = TRUE,
  overwrite = TRUE
)

cat("  ✓ Internal data saved to R/sysdata.rda\n\n")
cat("=== Done: GLI + FOT internal data prepared ===\n")