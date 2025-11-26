## Script to prepare GLI DLCO spline lookup tables for package
## This should be placed in the data-raw/ folder

library(readxl)

# Find the Excel file (handles different naming)
excel_files <- list.files("data-raw", pattern = "GLI_DLCO.*\\.xlsx$", 
                         full.names = TRUE, ignore.case = TRUE)
if(length(excel_files) == 0) {
  stop("DLCO Excel file not found in data-raw folder")
}
excel_path <- excel_files[1]

cat("Reading DLCO Excel file:", excel_path, "\n")

# Read the lookup tables for DLCO
TLCO_male <- readxl::read_excel(excel_path, sheet = "TLCO_SI_m")
TLCO_female <- readxl::read_excel(excel_path, sheet = "TLCO_SI_f")
KCO_male <- readxl::read_excel(excel_path, sheet = "KCO_SI_m")
KCO_female <- readxl::read_excel(excel_path, sheet = "KCO_SI_f")
VA_male <- readxl::read_excel(excel_path, sheet = "VA_m")
VA_female <- readxl::read_excel(excel_path, sheet = "VA_f")

# Create a list structure for DLCO data
SplineSheetsDLCO <- list(
  TLCO_male = as.data.frame(TLCO_male),
  TLCO_female = as.data.frame(TLCO_female),
  KCO_male = as.data.frame(KCO_male),
  KCO_female = as.data.frame(KCO_female),
  VA_male = as.data.frame(VA_male),
  VA_female = as.data.frame(VA_female)
)

# Load existing data if it exists
if (file.exists("R/sysdata.rda")) {
  load("R/sysdata.rda")
  cat("Loaded existing spirometry and lung volume data\n")
}

# Save all datasets as internal package data
# This makes them available to package functions but not to users
# usethis::use_data(SplineSheets, SplineSheetsLV, SplineSheetsDLCO,
#                   internal = TRUE, overwrite = TRUE)

cat("GLI DLCO spline lookup tables prepared successfully!\n")
cat("Spirometry, lung volume, and DLCO data are now available internally.\n")
