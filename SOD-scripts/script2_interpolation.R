#     script2_interpolation.R Interpolate outputs from script1_index_calculation.R
#     for Atlas Product Reproducibility.
#
#     Copyright (C) 2020 Santander Meteorology Group (http://www.meteo.unican.es)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.


# This script uses bash interpolation scripts:
# https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts

# The interpolation procedure followed is the one used in EURO-CORDEX
# It is a Conservative Remapping procedure in which parameters sensitive to land-sea transitions
# are dually interpolated, i.e. land-sea separated, and then re-combined in one file.
# Residual missing values (NaN) in the interior domain are filled with values from a straighforward remap.
# Land fraction thresholds used were > 0.999 and < 0.001 for land and sea respectively.
# The interpolation bash scripts are available at the 'bash-interpolation-scripts' directory
# at <https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts>

# Misc utilities for remote repo interaction:
library(devtools)

# USER PARAMETER SETTING -------------------------------------------------------

# Bash script performing the interpolation available at https://github.com/SantanderMetGroup/ATLAS/tree/mai-devel/SOD-scripts, e.g.: 
script <- "AtlasCDOremappeR_CMIP.sh"
# Path to the destination mask, available at https://github.com/SantanderMetGroup/ATLAS/tree/master/reference_masks, e.g.:
refmask <- "land_sea_mask_2degree.nc4"
# Path to the directory containing the NetCDFs to be interpolated
source.dir <- getwd()
# Output path, e.g.:
out.dir <- getwd()
# Path to the NetCDFs of the original masks (variable sftlf), e.g.:
mask.dir <- paste0(getwd(), "/masks")

# INTERPOLATION ----------------------------------------------------------------

# List of nectcdf files containing the land/sea masks of each model
orig.masks <- list.files(mask.dir, full.names = TRUE)
gridsdir <- list.files(source.dir, pattern = "nc4", full.names = TRUE)
grids <- list.files(source.dir, pattern = "nc4")

# The loop iterates over models and performs the Conservative Remapping described above,
# writing the interpolated files in the output directory (out.dir):

for (m in 1:length(grids)) {
  grid <- grids[m]
  griddir <- gridsdir[m]
  model <- strsplit(grid, "_")[[1]][2]
  newgrid <- gsub(model, paste0(model, "i"), grid)
  gridmask <- orig.masks[grep(model, orig.masks)]
  if (!file.exists(paste0(out.dir, "/", newgrid))) {
    print(paste0(out.dir, "/", newgrid))
    if (length(gridmask) > 0) {
      system(paste("bash", script, griddir, paste0(out.dir, "/", newgrid), gridmask, refmask))
    } else {
      system(paste0("cdo remapcon,", refmask, " ", griddir, " ", paste0(out.dir, "/", newgrid)))
    }
  }
}
# End
