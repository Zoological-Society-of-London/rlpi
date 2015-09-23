#install.packages("mgcv")
#install.packages("doParallel")
#install.packages("tools")
#install.packages("reshape")

#require(mgcv)
#require(doParallel)
#registerDoParallel()
doParallel:::registerDoParallel()
#require(tools)
#require(reshape)
#require(ggplot2)
#library(plyr)

#curr_d <- getwd()

#this.dir <- dirname(parent.frame(2)$ofile)
#setwd(this.dir)

# Code for each of these now stored in each file
#source("CalcSDev.R")
#source("ProcessFile.R")
#source("bootstrap_lpi.R")
#source("CalcLPI.R")
#source("debug_print.R")
#source("calculate_index.R")
#source("plot_lpi.R")
#source("ggplot_lpi.R")
#source("ggplot_multi_lpi.R")
#source("summarise_lpi.R")
#source("calc_leverage_lpi.R")

# ** OPTIONS ***
# Options are now in here...
#source("lpi_options.R")

# Get back to where we were
#setwd(curr_d)

# Reorganised to now run with a parameter --- LPIMain(infile)
# So to run, now you do
# LPIMain(INPUT_FILE)
# and allowing you to, for example, do:
#
# LPIMain("GlobalInfile.txt")
# LPIMain("TropicalInfile.txt")
#

REF_YEAR = 1970 # Initial reference year for LPI (REF_YEAR=1)
PLOT_MAX = 2012 # final year you want to show on the plot
DEFAULT_BOOT_STRAP_SIZE = 1000  #number of bootstraps you want
DEFAULT_SWITCH_PT_FLAG = 0  #zero means it won't calculate the switchpoints
DEFAULT_CI_FLAG = 1 #zero means it won't calculate Confidence limits
DEFAULT_LEV_FLAG = 0 # By default, don't calculate population leverage
DEFAULT_WEIGHTING = 0 # Whether to use weightings in input file
DEFAULT_WEIGHTING_B = 0 # Whether to use weightings in input file

# Should we save plots from this run
DEFAULT_SAVE_PLOTS = 1
# Should we plot the resulting LPI
DEFAULT_PLOT_LPI = 1

# Flag to force the recalculation of input files (rather than using cache when possible)
DEFAULT_FORCE_RECALCULATION = 0
DEBUG = 1

DEFAULT_MODEL_SELECTION_FLAG = 0
DEFAULT_GAM_GLOBAL_FLAG = 1  # 1 = process by GAM method, 0 = process by chain method
DEFAULT_DATA_LENGTH_MIN = 2
DEFAULT_AVG_TIME_BETWEEN_PTS_MAX = 100
DEFAULT_GLOBAL_GAM_FLAG_SHORT_DATA_FLAG = 0  # set this if GAM model is also to be generated for the short time series else the log linear model will be used.
DEFAULT_AUTO_DIAGNOSTIC_FLAG = 1
DEFAULT_LAMBDA_MIN = -1
DEFAULT_LAMBDA_MAX = 1
DEFAULT_ZERO_REPLACE_FLAG = 2  # 0 = +minimum value; 1 = +1% of mean value; 2 = +1
DEFAULT_OFFSET_ALL = 0 # Add offset to all values, to avoid log(0)
