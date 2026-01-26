# AHBPCEPredR Package Installation Script
# This script ensures proper installation with working help documentation

cat("Installing AHBPCEPredR package from GitHub...\n")

# Check if required packages are installed
required_packages <- c("remotes")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing required packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
}

# Load remotes
library(remotes)

# Install the package from GitHub with documentation build
cat("Installing from GitHub...\n")
remotes::install_github(
  "tza5051/AHBPCE_Package", 
  force = TRUE,
  build_vignettes = FALSE,
  upgrade = "never"  # Prevents interruption for package updates
)

# Load the package
cat("Loading AHBPCEPredR...\n")
library(AHBPCEPredR)

# Test installation
cat("\n=== Testing Installation ===\n")

# Test functions work
vo2_test <- compute_friend_vo2(age = 45, sex = "Male", weight = 75, height = 175, mode = "Treadmill")
cat("✓ Functions working - VO2 prediction:", round(vo2_test, 1), "ml/kg/min\n")

# Test help system
cat("✓ Available functions:\n")
exported_functions <- ls("package:AHBPCEPredR")
cpet_functions <- exported_functions[grepl("compute_", exported_functions)]
cat("  -", paste(cpet_functions, collapse = "\n  - "), "\n")

cat("\n=== Accessing Help Documentation ===\n")
cat("To get help for any function, use:\n")
cat("  ?compute_friend_vo2\n")
cat("  ?compute_max_hr\n")
cat("  help(package = 'AHBPCEPredR')\n")

cat("\n=== Package Successfully Installed! ===\n")
cat("Your AHBPCEPredR package is ready to use.\n")

cat("\n=== Updating the Package ===\n")
cat("To update AHBPCEPredR to the latest version, run:\n\n")
cat("  remotes::install_github('tza5051/AHBPCE_Package', force = TRUE)\n\n")
cat("Or simply re-run this installation script.\n")
cat("The 'force = TRUE' option ensures you get the latest version even if already installed.\n")