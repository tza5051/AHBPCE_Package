# Data preparation script for GLI splines
# This script loads the GLI spline data from Excel and saves it as internal package data

library(readxl)
library(usethis)

# Read the GLI splines from Excel file
gli_splines <- readxl::read_excel("data-raw/gli_global_lookuptables_dec6 2.xlsx")

# Save as internal package data
# usethis::use_data(gli_splines, internal = TRUE, overwrite = TRUE)