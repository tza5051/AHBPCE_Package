## Script to prepare GLI 2021 spline lookup tables for package
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

# Read the lookup tables
# Make sure gli_global_lookuptables_dec6.xlsx is in the data-raw folder
SplineSheets <- read_excel_allsheets("data-raw/gli_global_lookuptables_dec6.xlsx")

# Save as internal package data
# This makes it available to package functions but not to users
usethis::use_data(SplineSheets, internal = TRUE, overwrite = TRUE)

# Alternative: If you want users to access the data
# usethis::use_data(SplineSheets, overwrite = TRUE)

cat("GLI 2021 spline lookup tables prepared successfully!\n")
cat("The data is now available internally to package functions.\n")