# creating_infiles, rlpi package
Robin Freeman, IoZ, Zoological Society of London  
`r format(Sys.Date())`  


```
## Loading required package: rlpi
```

The code also provides a means to create infiles from tabular population data. For example, the Living Planet Database can be constructed so that each row represents a population, with columns for each abundance year. NB: The **create_infile** method expects particular columns that define where the abundance data resides, it uses the **convert_to_rows** function that assumes abundance data is in columns between the *X1950* column and a column called *Managed*. This reflects the format used in the Living Planet Database, and in the example data provided here **http://www.livingplanetindex.org/projects?main_page_project=LivingPlanetReport&home_flag=1**.



```r
# Constructing infiles from a populations table...

# First read the population table (this is the Living Planet Database excluding confidential records)
lpi_data <- read.csv("inst/extdata/example_data/LPI_LPR2016data_public.csv", na.strings = "NULL")

# Create an inifle from all the data. All the population data in the 'lpi_data' table will be converted and stored in a file called 'example_data_pops.txt' and a file called 'example_data_infile.txt' will be created that references the first file (the infile name will also be stored in the returned variable 'example_infile_name')

# Here we select the first 100 populations by creating an index vector that's FALSE for all rows, then setting the first 100 rows to TRUE
index_vector = rep(FALSE, nrow(lpi_data))
index_vector[1:100] = TRUE

example_infile_name <- create_infile(lpi_data, index_vector=index_vector, name="example_data")
# An index can be created using this infile, for the period 1970 to 2014 with 100 bootstraps.
example_lpi <- LPIMain(example_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: example_data_pops.txt
## Calculating LPI for Species
## Number of species: 54 (in 100 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |*                                                                |   2%
  |                                                                       
  |**                                                               |   4%
  |                                                                       
  |****                                                             |   6%
  |                                                                       
  |*****                                                            |   7%
  |                                                                       
  |******                                                           |   9%
  |                                                                       
  |*******                                                          |  11%
  |                                                                       
  |********                                                         |  13%
  |                                                                       
  |**********                                                       |  15%
  |                                                                       
  |***********                                                      |  17%
  |                                                                       
  |************                                                     |  19%
  |                                                                       
  |*************                                                    |  20%
  |                                                                       
  |**************                                                   |  22%
  |                                                                       
  |****************                                                 |  24%
  |                                                                       
  |*****************                                                |  26%
  |                                                                       
  |******************                                               |  28%
  |                                                                       
  |*******************                                              |  30%
  |                                                                       
  |********************                                             |  31%
  |                                                                       
  |**********************                                           |  33%
  |                                                                       
  |***********************                                          |  35%
  |                                                                       
  |************************                                         |  37%
  |                                                                       
  |*************************                                        |  39%
  |                                                                       
  |**************************                                       |  41%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |*****************************                                    |  44%
  |                                                                       
  |******************************                                   |  46%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |********************************                                 |  50%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |***********************************                              |  54%
  |                                                                       
  |************************************                             |  56%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |***************************************                          |  59%
  |                                                                       
  |****************************************                         |  61%
  |                                                                       
  |*****************************************                        |  63%
  |                                                                       
  |******************************************                       |  65%
  |                                                                       
  |*******************************************                      |  67%
  |                                                                       
  |*********************************************                    |  69%
  |                                                                       
  |**********************************************                   |  70%
  |                                                                       
  |***********************************************                  |  72%
  |                                                                       
  |************************************************                 |  74%
  |                                                                       
  |*************************************************                |  76%
  |                                                                       
  |***************************************************              |  78%
  |                                                                       
  |****************************************************             |  80%
  |                                                                       
  |*****************************************************            |  81%
  |                                                                       
  |******************************************************           |  83%
  |                                                                       
  |*******************************************************          |  85%
  |                                                                       
  |*********************************************************        |  87%
  |                                                                       
  |**********************************************************       |  89%
  |                                                                       
  |***********************************************************      |  91%
  |                                                                       
  |************************************************************     |  93%
  |                                                                       
  |*************************************************************    |  94%
  |                                                                       
  |***************************************************************  |  96%
  |                                                                       
  |**************************************************************** |  98%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/48ec7239bf79b46becf99282129e669b_splambda.csv
## Saving species lambda to file: example_data_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/48ec7239bf79b46becf99282129e669b_dtemp.csv 
## Saving DTemp to file:  example_data_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'example_data_pops.txt' from MD5 hash: lpi_temp/48ec7239bf79b46becf99282129e669b_splambda.csv
## example_data_pops.txt, Number of species: 54
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/48ec7239bf79b46becf99282129e669b_dtemp.csv
## Saving DTemp Array to file:  example_data_infile_dtemp_array.txt
```

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  example_data_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 3.490000, User: 0.149000, Elapsed: 4.933000
## Group 1 is NA in year 43
## Group 1 is NA in year 44
## Group 1 is NA in year 45
## Group 1 is NA in year 46
## Number of valid index years: 42 (of possible 46)
## [Calculating CIs...] System: 3.542000, User: 0.151000, Elapsed: 5.000000
## ....................................................................................................
## [CIs calculated] System: 6.756000, User: 0.258000, Elapsed: 9.070000
```

![](creating_infiles_files/figure-html/making_infiles-1.png)

```
## Saving final output to file:  example_data_infile_Results.txt 
## Saving Min/Max file to:  example_data_pops_Minmax.txt 
## Saving Plot to PDF:  example_data_infile.pdf 
## [END] System: 6.815000, User: 0.265000, Elapsed: 9.155000
```

```r
# Plot the resulting index
ggplot_lpi(example_lpi, title = "example_lpi", xlims=c(1970, 2012), ylim=c(0, 2))
```

![](creating_infiles_files/figure-html/making_infiles-2.png)

```r
# Plot the resulting index with logged y-axis (note the use of a +ive ymin)
ggplot_lpi(example_lpi, title = "example_lpi", xlims=c(1970, 2012), ylim=c(0.3, 2), trans="log")
```

```
## Warning in self$trans$transform(x): NaNs produced
```

```
## Warning: Transformation introduced infinite values in continuous y-axis
```

```
## Warning in self$trans$transform(x): NaNs produced
```

```
## Warning: Transformation introduced infinite values in continuous y-axis
```

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](creating_infiles_files/figure-html/making_infiles-3.png)

```r
# Here we limit the data to 'Strigiformes' simply by creating a boolean  (true/false) vector which is true for populations (rows) where the Order is "Strigiformes"
Strigiformes = lpi_data$Order == "Strigiformes" 

# Psssing this vector into the create_infile function will select just those populations and create an infile for them
s_infile_name <- create_infile(lpi_data, index_vector=Strigiformes, name="example_data_strig")
# Again, create and index
s_lpi <- LPIMain(s_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: example_data_strig_pops.txt
## Calculating LPI for Species
## Number of species: 21 (in 55 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |***                                                              |   5%
  |                                                                       
  |******                                                           |  10%
  |                                                                       
  |*********                                                        |  14%
  |                                                                       
  |************                                                     |  19%
  |                                                                       
  |***************                                                  |  24%
  |                                                                       
  |*******************                                              |  29%
  |                                                                       
  |**********************                                           |  33%
  |                                                                       
  |*************************                                        |  38%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |****************************************                         |  62%
  |                                                                       
  |*******************************************                      |  67%
  |                                                                       
  |**********************************************                   |  71%
  |                                                                       
  |**************************************************               |  76%
  |                                                                       
  |*****************************************************            |  81%
  |                                                                       
  |********************************************************         |  86%
  |                                                                       
  |***********************************************************      |  90%
  |                                                                       
  |**************************************************************   |  95%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/6951435159501a64e5e4218b6ba556db_splambda.csv
## Saving species lambda to file: example_data_strig_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/6951435159501a64e5e4218b6ba556db_dtemp.csv 
## Saving DTemp to file:  example_data_strig_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'example_data_strig_pops.txt' from MD5 hash: lpi_temp/6951435159501a64e5e4218b6ba556db_splambda.csv
## example_data_strig_pops.txt, Number of species: 21
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/6951435159501a64e5e4218b6ba556db_dtemp.csv
## Saving DTemp Array to file:  example_data_strig_infile_dtemp_array.txt
```

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  example_data_strig_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 2.395000, User: 0.073000, Elapsed: 3.156000
## Group 1 is NA in year 46
## Number of valid index years: 45 (of possible 46)
## [Calculating CIs...] System: 2.448000, User: 0.073000, Elapsed: 3.232000
## ....................................................................................................
## [CIs calculated] System: 5.660000, User: 0.141000, Elapsed: 7.297000
```

![](creating_infiles_files/figure-html/making_infiles-4.png)

```
## Saving final output to file:  example_data_strig_infile_Results.txt 
## Saving Min/Max file to:  example_data_strig_pops_Minmax.txt 
## Saving Plot to PDF:  example_data_strig_infile.pdf 
## [END] System: 5.735000, User: 0.148000, Elapsed: 7.388000
```

```r
# And plot
ggplot_lpi(s_lpi, title = "s_lpi", xlims=c(1970, 2012))
```

![](creating_infiles_files/figure-html/making_infiles-5.png)

```r
# Similarly, this will create an index just for those populations of the Order 'Passeriformes'
Passeriformes = lpi_data$Order == "Passeriformes" 
p_infile_name <- create_infile(lpi_data, index_vector=Passeriformes, name="example_data_pass")
p_lpi <- LPIMain(s_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: example_data_strig_pops.txt
## Calculating LPI for Species
## Number of species: 21 (in 55 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |***                                                              |   5%
  |                                                                       
  |******                                                           |  10%
  |                                                                       
  |*********                                                        |  14%
  |                                                                       
  |************                                                     |  19%
  |                                                                       
  |***************                                                  |  24%
  |                                                                       
  |*******************                                              |  29%
  |                                                                       
  |**********************                                           |  33%
  |                                                                       
  |*************************                                        |  38%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |****************************************                         |  62%
  |                                                                       
  |*******************************************                      |  67%
  |                                                                       
  |**********************************************                   |  71%
  |                                                                       
  |**************************************************               |  76%
  |                                                                       
  |*****************************************************            |  81%
  |                                                                       
  |********************************************************         |  86%
  |                                                                       
  |***********************************************************      |  90%
  |                                                                       
  |**************************************************************   |  95%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/6951435159501a64e5e4218b6ba556db_splambda.csv
## Saving species lambda to file: example_data_strig_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/6951435159501a64e5e4218b6ba556db_dtemp.csv 
## Saving DTemp to file:  example_data_strig_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'example_data_strig_pops.txt' from MD5 hash: lpi_temp/6951435159501a64e5e4218b6ba556db_splambda.csv
## example_data_strig_pops.txt, Number of species: 21
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/6951435159501a64e5e4218b6ba556db_dtemp.csv
## Saving DTemp Array to file:  example_data_strig_infile_dtemp_array.txt
```

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  example_data_strig_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 2.496000, User: 0.049000, Elapsed: 3.537000
## Group 1 is NA in year 46
## Number of valid index years: 45 (of possible 46)
## [Calculating CIs...] System: 2.562000, User: 0.051000, Elapsed: 3.637000
## ....................................................................................................
## [CIs calculated] System: 5.528000, User: 0.132000, Elapsed: 7.458000
```

![](creating_infiles_files/figure-html/making_infiles-6.png)

```
## Saving final output to file:  example_data_strig_infile_Results.txt 
## Saving Min/Max file to:  example_data_strig_pops_Minmax.txt 
## Saving Plot to PDF:  example_data_strig_infile.pdf 
## [END] System: 5.590000, User: 0.137000, Elapsed: 7.528000
```

```r
ggplot_lpi(p_lpi, title = "p_lpi", xlims=c(1970, 2012))
```

![](creating_infiles_files/figure-html/making_infiles-7.png)

```r
# Nearctic mammals
Nearctic_mammals = lpi_data$Class == "Mammalia" & lpi_data$T_realm == "Nearctic"
nm_infile_name <- create_infile(lpi_data, index_vector=Nearctic_mammals, name="terrestrial_Nearctic_Mammalia")

# How many pops...
sum(Nearctic_mammals, na.rm = T)
```

```
## [1] 389
```

```r
nm_lpi <- LPIMain(nm_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: terrestrial_Nearctic_Mammalia_pops.txt
## Calculating LPI for Species
## Number of species: 92 (in 384 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |*                                                                |   1%
  |                                                                       
  |*                                                                |   2%
  |                                                                       
  |**                                                               |   3%
  |                                                                       
  |***                                                              |   4%
  |                                                                       
  |****                                                             |   5%
  |                                                                       
  |****                                                             |   7%
  |                                                                       
  |*****                                                            |   8%
  |                                                                       
  |******                                                           |   9%
  |                                                                       
  |******                                                           |  10%
  |                                                                       
  |*******                                                          |  11%
  |                                                                       
  |********                                                         |  12%
  |                                                                       
  |********                                                         |  13%
  |                                                                       
  |*********                                                        |  14%
  |                                                                       
  |**********                                                       |  15%
  |                                                                       
  |***********                                                      |  16%
  |                                                                       
  |***********                                                      |  17%
  |                                                                       
  |************                                                     |  18%
  |                                                                       
  |*************                                                    |  20%
  |                                                                       
  |*************                                                    |  21%
  |                                                                       
  |**************                                                   |  22%
  |                                                                       
  |***************                                                  |  23%
  |                                                                       
  |****************                                                 |  24%
  |                                                                       
  |****************                                                 |  25%
  |                                                                       
  |*****************                                                |  26%
  |                                                                       
  |******************                                               |  27%
  |                                                                       
  |******************                                               |  28%
  |                                                                       
  |*******************                                              |  29%
  |                                                                       
  |********************                                             |  30%
  |                                                                       
  |********************                                             |  32%
  |                                                                       
  |*********************                                            |  33%
  |                                                                       
  |**********************                                           |  34%
  |                                                                       
  |***********************                                          |  35%
  |                                                                       
  |***********************                                          |  36%
  |                                                                       
  |************************                                         |  37%
  |                                                                       
  |*************************                                        |  38%
  |                                                                       
  |*************************                                        |  39%
  |                                                                       
  |**************************                                       |  40%
  |                                                                       
  |***************************                                      |  41%
  |                                                                       
  |****************************                                     |  42%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |*****************************                                    |  45%
  |                                                                       
  |******************************                                   |  46%
  |                                                                       
  |******************************                                   |  47%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |********************************                                 |  49%
  |                                                                       
  |********************************                                 |  50%
  |                                                                       
  |*********************************                                |  51%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |***********************************                              |  53%
  |                                                                       
  |***********************************                              |  54%
  |                                                                       
  |************************************                             |  55%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |*************************************                            |  58%
  |                                                                       
  |**************************************                           |  59%
  |                                                                       
  |***************************************                          |  60%
  |                                                                       
  |****************************************                         |  61%
  |                                                                       
  |****************************************                         |  62%
  |                                                                       
  |*****************************************                        |  63%
  |                                                                       
  |******************************************                       |  64%
  |                                                                       
  |******************************************                       |  65%
  |                                                                       
  |*******************************************                      |  66%
  |                                                                       
  |********************************************                     |  67%
  |                                                                       
  |*********************************************                    |  68%
  |                                                                       
  |*********************************************                    |  70%
  |                                                                       
  |**********************************************                   |  71%
  |                                                                       
  |***********************************************                  |  72%
  |                                                                       
  |***********************************************                  |  73%
  |                                                                       
  |************************************************                 |  74%
  |                                                                       
  |*************************************************                |  75%
  |                                                                       
  |*************************************************                |  76%
  |                                                                       
  |**************************************************               |  77%
  |                                                                       
  |***************************************************              |  78%
  |                                                                       
  |****************************************************             |  79%
  |                                                                       
  |****************************************************             |  80%
  |                                                                       
  |*****************************************************            |  82%
  |                                                                       
  |******************************************************           |  83%
  |                                                                       
  |******************************************************           |  84%
  |                                                                       
  |*******************************************************          |  85%
  |                                                                       
  |********************************************************         |  86%
  |                                                                       
  |*********************************************************        |  87%
  |                                                                       
  |*********************************************************        |  88%
  |                                                                       
  |**********************************************************       |  89%
  |                                                                       
  |***********************************************************      |  90%
  |                                                                       
  |***********************************************************      |  91%
  |                                                                       
  |************************************************************     |  92%
  |                                                                       
  |*************************************************************    |  93%
  |                                                                       
  |*************************************************************    |  95%
  |                                                                       
  |**************************************************************   |  96%
  |                                                                       
  |***************************************************************  |  97%
  |                                                                       
  |**************************************************************** |  98%
  |                                                                       
  |**************************************************************** |  99%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/7282fa95486d2024ef7a6282067e0100_splambda.csv
## Saving species lambda to file: terrestrial_Nearctic_Mammalia_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/7282fa95486d2024ef7a6282067e0100_dtemp.csv 
## Saving DTemp to file:  terrestrial_Nearctic_Mammalia_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'terrestrial_Nearctic_Mammalia_pops.txt' from MD5 hash: lpi_temp/7282fa95486d2024ef7a6282067e0100_splambda.csv
## terrestrial_Nearctic_Mammalia_pops.txt, Number of species: 92
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/7282fa95486d2024ef7a6282067e0100_dtemp.csv
## Saving DTemp Array to file:  terrestrial_Nearctic_Mammalia_infile_dtemp_array.txt
```

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  terrestrial_Nearctic_Mammalia_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 8.221000, User: 0.207000, Elapsed: 10.692000
## Group 1 is NA in year 45
## Group 1 is NA in year 46
## Number of valid index years: 44 (of possible 46)
## [Calculating CIs...] System: 8.264000, User: 0.207000, Elapsed: 10.738000
## ....................................................................................................
## [CIs calculated] System: 11.416000, User: 0.352000, Elapsed: 14.724000
```

![](creating_infiles_files/figure-html/making_infiles-8.png)

```
## Saving final output to file:  terrestrial_Nearctic_Mammalia_infile_Results.txt 
## Saving Min/Max file to:  terrestrial_Nearctic_Mammalia_pops_Minmax.txt 
## Saving Plot to PDF:  terrestrial_Nearctic_Mammalia_infile.pdf 
## [END] System: 11.597000, User: 0.362000, Elapsed: 14.956000
```

```r
ggplot_lpi(nm_lpi, title = "nm_lpi", xlims=c(1970, 2012))
```

![](creating_infiles_files/figure-html/making_infiles-9.png)

```r
# Nearctic birds
Nearctic_birds = lpi_data$Class == "Aves" & lpi_data$T_realm == "Nearctic"
nb_infile_name <- create_infile(lpi_data, index_vector=Nearctic_birds, name="terrestrial_Nearctic_Aves")

# How many pops...
sum(Nearctic_birds, na.rm = T)
```

```
## [1] 541
```

```r
nb_lpi <- LPIMain(nb_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: terrestrial_Nearctic_Aves_pops.txt
## Calculating LPI for Species
## Number of species: 377 (in 541 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |                                                                 |   1%
  |                                                                       
  |*                                                                |   1%
  |                                                                       
  |*                                                                |   2%
  |                                                                       
  |**                                                               |   2%
  |                                                                       
  |**                                                               |   3%
  |                                                                       
  |**                                                               |   4%
  |                                                                       
  |***                                                              |   4%
  |                                                                       
  |***                                                              |   5%
  |                                                                       
  |****                                                             |   6%
  |                                                                       
  |****                                                             |   7%
  |                                                                       
  |*****                                                            |   7%
  |                                                                       
  |*****                                                            |   8%
  |                                                                       
  |******                                                           |   8%
  |                                                                       
  |******                                                           |   9%
  |                                                                       
  |******                                                           |  10%
  |                                                                       
  |*******                                                          |  10%
  |                                                                       
  |*******                                                          |  11%
  |                                                                       
  |********                                                         |  12%
  |                                                                       
  |********                                                         |  13%
  |                                                                       
  |*********                                                        |  13%
  |                                                                       
  |*********                                                        |  14%
  |                                                                       
  |*********                                                        |  15%
  |                                                                       
  |**********                                                       |  15%
  |                                                                       
  |**********                                                       |  16%
  |                                                                       
  |***********                                                      |  16%
  |                                                                       
  |***********                                                      |  17%
  |                                                                       
  |***********                                                      |  18%
  |                                                                       
  |************                                                     |  18%
  |                                                                       
  |************                                                     |  19%
  |                                                                       
  |*************                                                    |  19%
  |                                                                       
  |*************                                                    |  20%
  |                                                                       
  |*************                                                    |  21%
  |                                                                       
  |**************                                                   |  21%
  |                                                                       
  |**************                                                   |  22%
  |                                                                       
  |***************                                                  |  23%
  |                                                                       
  |***************                                                  |  24%
  |                                                                       
  |****************                                                 |  24%
  |                                                                       
  |****************                                                 |  25%
  |                                                                       
  |*****************                                                |  25%
  |                                                                       
  |*****************                                                |  26%
  |                                                                       
  |*****************                                                |  27%
  |                                                                       
  |******************                                               |  27%
  |                                                                       
  |******************                                               |  28%
  |                                                                       
  |*******************                                              |  29%
  |                                                                       
  |*******************                                              |  30%
  |                                                                       
  |********************                                             |  30%
  |                                                                       
  |********************                                             |  31%
  |                                                                       
  |*********************                                            |  32%
  |                                                                       
  |*********************                                            |  33%
  |                                                                       
  |**********************                                           |  33%
  |                                                                       
  |**********************                                           |  34%
  |                                                                       
  |***********************                                          |  35%
  |                                                                       
  |***********************                                          |  36%
  |                                                                       
  |************************                                         |  36%
  |                                                                       
  |************************                                         |  37%
  |                                                                       
  |************************                                         |  38%
  |                                                                       
  |*************************                                        |  38%
  |                                                                       
  |*************************                                        |  39%
  |                                                                       
  |**************************                                       |  39%
  |                                                                       
  |**************************                                       |  40%
  |                                                                       
  |**************************                                       |  41%
  |                                                                       
  |***************************                                      |  41%
  |                                                                       
  |***************************                                      |  42%
  |                                                                       
  |****************************                                     |  42%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |****************************                                     |  44%
  |                                                                       
  |*****************************                                    |  44%
  |                                                                       
  |*****************************                                    |  45%
  |                                                                       
  |******************************                                   |  46%
  |                                                                       
  |******************************                                   |  47%
  |                                                                       
  |*******************************                                  |  47%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |********************************                                 |  49%
  |                                                                       
  |********************************                                 |  50%
  |                                                                       
  |*********************************                                |  50%
  |                                                                       
  |*********************************                                |  51%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |**********************************                               |  53%
  |                                                                       
  |***********************************                              |  53%
  |                                                                       
  |***********************************                              |  54%
  |                                                                       
  |************************************                             |  55%
  |                                                                       
  |************************************                             |  56%
  |                                                                       
  |*************************************                            |  56%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |*************************************                            |  58%
  |                                                                       
  |**************************************                           |  58%
  |                                                                       
  |**************************************                           |  59%
  |                                                                       
  |***************************************                          |  59%
  |                                                                       
  |***************************************                          |  60%
  |                                                                       
  |***************************************                          |  61%
  |                                                                       
  |****************************************                         |  61%
  |                                                                       
  |****************************************                         |  62%
  |                                                                       
  |*****************************************                        |  62%
  |                                                                       
  |*****************************************                        |  63%
  |                                                                       
  |*****************************************                        |  64%
  |                                                                       
  |******************************************                       |  64%
  |                                                                       
  |******************************************                       |  65%
  |                                                                       
  |*******************************************                      |  66%
  |                                                                       
  |*******************************************                      |  67%
  |                                                                       
  |********************************************                     |  67%
  |                                                                       
  |********************************************                     |  68%
  |                                                                       
  |*********************************************                    |  69%
  |                                                                       
  |*********************************************                    |  70%
  |                                                                       
  |**********************************************                   |  70%
  |                                                                       
  |**********************************************                   |  71%
  |                                                                       
  |***********************************************                  |  72%
  |                                                                       
  |***********************************************                  |  73%
  |                                                                       
  |************************************************                 |  73%
  |                                                                       
  |************************************************                 |  74%
  |                                                                       
  |************************************************                 |  75%
  |                                                                       
  |*************************************************                |  75%
  |                                                                       
  |*************************************************                |  76%
  |                                                                       
  |**************************************************               |  76%
  |                                                                       
  |**************************************************               |  77%
  |                                                                       
  |***************************************************              |  78%
  |                                                                       
  |***************************************************              |  79%
  |                                                                       
  |****************************************************             |  79%
  |                                                                       
  |****************************************************             |  80%
  |                                                                       
  |****************************************************             |  81%
  |                                                                       
  |*****************************************************            |  81%
  |                                                                       
  |*****************************************************            |  82%
  |                                                                       
  |******************************************************           |  82%
  |                                                                       
  |******************************************************           |  83%
  |                                                                       
  |******************************************************           |  84%
  |                                                                       
  |*******************************************************          |  84%
  |                                                                       
  |*******************************************************          |  85%
  |                                                                       
  |********************************************************         |  85%
  |                                                                       
  |********************************************************         |  86%
  |                                                                       
  |********************************************************         |  87%
  |                                                                       
  |*********************************************************        |  87%
  |                                                                       
  |*********************************************************        |  88%
  |                                                                       
  |**********************************************************       |  89%
  |                                                                       
  |**********************************************************       |  90%
  |                                                                       
  |***********************************************************      |  90%
  |                                                                       
  |***********************************************************      |  91%
  |                                                                       
  |***********************************************************      |  92%
  |                                                                       
  |************************************************************     |  92%
  |                                                                       
  |************************************************************     |  93%
  |                                                                       
  |*************************************************************    |  93%
  |                                                                       
  |*************************************************************    |  94%
  |                                                                       
  |**************************************************************   |  95%
  |                                                                       
  |**************************************************************   |  96%
  |                                                                       
  |***************************************************************  |  96%
  |                                                                       
  |***************************************************************  |  97%
  |                                                                       
  |***************************************************************  |  98%
  |                                                                       
  |**************************************************************** |  98%
  |                                                                       
  |**************************************************************** |  99%
  |                                                                       
  |*****************************************************************|  99%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/d99a9bebbe6d94380af43e35d4ef17a3_splambda.csv
## Saving species lambda to file: terrestrial_Nearctic_Aves_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/d99a9bebbe6d94380af43e35d4ef17a3_dtemp.csv 
## Saving DTemp to file:  terrestrial_Nearctic_Aves_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'terrestrial_Nearctic_Aves_pops.txt' from MD5 hash: lpi_temp/d99a9bebbe6d94380af43e35d4ef17a3_splambda.csv
## terrestrial_Nearctic_Aves_pops.txt, Number of species: 377
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/d99a9bebbe6d94380af43e35d4ef17a3_dtemp.csv
## Saving DTemp Array to file:  terrestrial_Nearctic_Aves_infile_dtemp_array.txt
```

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  terrestrial_Nearctic_Aves_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 33.625000, User: 1.086000, Elapsed: 41.791000
## Group 1 is NA in year 46
## Number of valid index years: 45 (of possible 46)
## [Calculating CIs...] System: 33.662000, User: 1.086000, Elapsed: 41.833000
## ....................................................................................................
## [CIs calculated] System: 37.824000, User: 1.275000, Elapsed: 46.920000
```

![](creating_infiles_files/figure-html/making_infiles-10.png)

```
## Saving final output to file:  terrestrial_Nearctic_Aves_infile_Results.txt 
## Saving Min/Max file to:  terrestrial_Nearctic_Aves_pops_Minmax.txt 
## Saving Plot to PDF:  terrestrial_Nearctic_Aves_infile.pdf 
## [END] System: 38.103000, User: 1.285000, Elapsed: 47.236000
```

```r
ggplot_lpi(nb_lpi, title = "nb_lpi", xlims=c(1970, 2012))
```

![](creating_infiles_files/figure-html/making_infiles-11.png)

```r
# Nearctic herps
Nearctic_herps = (lpi_data$Class == "Reptilia" | lpi_data$Class == "Amphibia") & lpi_data$T_realm == "Nearctic"
nh_infile_name <- create_infile(lpi_data, index_vector=Nearctic_herps, name="terrestrial_Nearctic_Herps")

# How many pops...
sum(Nearctic_herps, na.rm = T)
```

```
## [1] 102
```

```r
nh_lpi <- LPIMain(nh_infile_name, REF_YEAR = 1970, PLOT_MAX = 2014, BOOT_STRAP_SIZE = 100)
```

```
## Number of groups:  1 
## processing file: terrestrial_Nearctic_Herps_pops.txt
## Calculating LPI for Species
## Number of species: 58 (in 102 populations)
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |*                                                                |   2%
  |                                                                       
  |**                                                               |   3%
  |                                                                       
  |***                                                              |   5%
  |                                                                       
  |****                                                             |   7%
  |                                                                       
  |******                                                           |   9%
  |                                                                       
  |*******                                                          |  10%
  |                                                                       
  |********                                                         |  12%
  |                                                                       
  |*********                                                        |  14%
  |                                                                       
  |**********                                                       |  16%
  |                                                                       
  |***********                                                      |  17%
  |                                                                       
  |************                                                     |  19%
  |                                                                       
  |*************                                                    |  21%
  |                                                                       
  |***************                                                  |  22%
  |                                                                       
  |****************                                                 |  24%
  |                                                                       
  |*****************                                                |  26%
  |                                                                       
  |******************                                               |  28%
  |                                                                       
  |*******************                                              |  29%
  |                                                                       
  |********************                                             |  31%
  |                                                                       
  |*********************                                            |  33%
  |                                                                       
  |**********************                                           |  34%
  |                                                                       
  |************************                                         |  36%
  |                                                                       
  |*************************                                        |  38%
  |                                                                       
  |**************************                                       |  40%
  |                                                                       
  |***************************                                      |  41%
  |                                                                       
  |****************************                                     |  43%
  |                                                                       
  |*****************************                                    |  45%
  |                                                                       
  |******************************                                   |  47%
  |                                                                       
  |*******************************                                  |  48%
  |                                                                       
  |********************************                                 |  50%
  |                                                                       
  |**********************************                               |  52%
  |                                                                       
  |***********************************                              |  53%
  |                                                                       
  |************************************                             |  55%
  |                                                                       
  |*************************************                            |  57%
  |                                                                       
  |**************************************                           |  59%
  |                                                                       
  |***************************************                          |  60%
  |                                                                       
  |****************************************                         |  62%
  |                                                                       
  |*****************************************                        |  64%
  |                                                                       
  |*******************************************                      |  66%
  |                                                                       
  |********************************************                     |  67%
  |                                                                       
  |*********************************************                    |  69%
  |                                                                       
  |**********************************************                   |  71%
  |                                                                       
  |***********************************************                  |  72%
  |                                                                       
  |************************************************                 |  74%
  |                                                                       
  |*************************************************                |  76%
  |                                                                       
  |**************************************************               |  78%
  |                                                                       
  |****************************************************             |  79%
  |                                                                       
  |*****************************************************            |  81%
  |                                                                       
  |******************************************************           |  83%
  |                                                                       
  |*******************************************************          |  84%
  |                                                                       
  |********************************************************         |  86%
  |                                                                       
  |*********************************************************        |  88%
  |                                                                       
  |**********************************************************       |  90%
  |                                                                       
  |***********************************************************      |  91%
  |                                                                       
  |*************************************************************    |  93%
  |                                                                       
  |**************************************************************   |  95%
  |                                                                       
  |***************************************************************  |  97%
  |                                                                       
  |**************************************************************** |  98%
  |                                                                       
  |*****************************************************************| 100%
## 
## Saving species lambda to file: lpi_temp/ffa9d8ac9ddc787613f91b2f3f82a834_splambda.csv
## Saving species lambda to file: terrestrial_Nearctic_Herps_pops_lambda.csv
## Calculating DTemp
## Saving DTemp to file:  lpi_temp/ffa9d8ac9ddc787613f91b2f3f82a834_dtemp.csv 
## Saving DTemp to file:  terrestrial_Nearctic_Herps_pops_dtemp.csv 
## [debug] Loading previously analysed species lambda file for 'terrestrial_Nearctic_Herps_pops.txt' from MD5 hash: lpi_temp/ffa9d8ac9ddc787613f91b2f3f82a834_splambda.csv
## terrestrial_Nearctic_Herps_pops.txt, Number of species: 58
## [debug] Loading previously analysed dtemp file from MD5 hash: lpi_temp/ffa9d8ac9ddc787613f91b2f3f82a834_dtemp.csv
## Saving DTemp Array to file:  terrestrial_Nearctic_Herps_infile_dtemp_array.txt
```

```
## Warning: Removed 1 rows containing missing values (geom_path).
```

```
## Saving DTemp Array with filesnames to file:  terrestrial_Nearctic_Herps_infile_dtemp_array_named.csv 
## [Calculating LPI...] System: 1.916000, User: 0.057000, Elapsed: 2.520000
## Number of valid index years: 46 (of possible 46)
## [Calculating CIs...] System: 1.972000, User: 0.059000, Elapsed: 2.593000
## ....................................................................................................
## [CIs calculated] System: 5.273000, User: 0.192000, Elapsed: 6.559000
```

![](creating_infiles_files/figure-html/making_infiles-12.png)

```
## Saving final output to file:  terrestrial_Nearctic_Herps_infile_Results.txt 
## Saving Min/Max file to:  terrestrial_Nearctic_Herps_pops_Minmax.txt 
## Saving Plot to PDF:  terrestrial_Nearctic_Herps_infile.pdf 
## [END] System: 5.358000, User: 0.197000, Elapsed: 6.661000
```

```r
ggplot_lpi(nh_lpi, title = "nh_lpi", xlims=c(1970, 2012))
```

![](creating_infiles_files/figure-html/making_infiles-13.png)
