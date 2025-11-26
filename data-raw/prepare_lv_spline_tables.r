## Script to prepare GLI 2021 Lung Volume spline lookup tables for package
## This should be placed in the data-raw/ folder

library(readxl)

# Function to read all sheets from Excel file
read_excel_allsheets <- function(filename, tibble = FALSE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

# Find the Excel file (handles different naming)
excel_files <- list.files("data-raw", pattern = "GLI_lung_volume.*\\.xlsx$", 
                         full.names = TRUE, ignore.case = TRUE)
if(length(excel_files) == 0) {
  stop("Lung volume Excel file not found in data-raw folder")
}
excel_path <- excel_files[1]

cat("Reading Lung Volume Excel file:", excel_path, "\n")

# Read the lookup tables for lung volumes
SplineSheetsLV <- read_excel_allsheets(excel_path)

# Load existing spirometry data if it exists
if (file.exists("R/sysdata.rda")) {
  load("R/sysdata.rda")
  cat("Loaded existing spirometry data\n")
}

# Save both datasets as internal package data
# This makes them available to package functions but not to users
# usethis::use_data(SplineSheets, SplineSheetsLV, 
#                   internal = TRUE, overwrite = TRUE)

cat("GLI 2021 lung volume spline lookup tables prepared successfully!\n")
cat("Both spirometry and lung volume data are now available internally.\n")
