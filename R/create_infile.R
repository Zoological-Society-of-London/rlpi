
#' Converts wide data (population per row, many columns) to long data: popvalue/year per row
#'
#' @param in_data - the dataframe containing the data (population per row with cols for data from 1950)
#'
#' @return Returns a data frame with (Binomial, ID, year, popvalue) columns
#' @export
#'
convert_to_rows <- function(in_data, start_col_name="X1950", end_col_name="X2015") {
  #Binomial  ID  year  popvalue
  all_data <- data.frame(Binomial = character(0), ID = numeric(0), year = numeric(0), popvalue=numeric(0))
  # In input data, each population is a row, with a series of population sizes

  pop_data_col_start <- which(colnames(in_data)==start_col_name)
  pop_data_col_end <- which(colnames(in_data) == end_col_name)

  # Get names of all years (getting rid of X at beginning)
  dimnames_years <- dimnames(in_data[1, pop_data_col_start:pop_data_col_end])[[2]]
  years = as.numeric(substr(dimnames_years, 2, 5))

  d_names = c("Binomial", "ID", years)
  binomial_col <- which(colnames(in_data)=="Binomial")
  id_col <- which(colnames(in_data) == "ID")

  pop_data = (in_data[, c(binomial_col, id_col, pop_data_col_start:pop_data_col_end)])

  # print(pop_data)

  m_pop_data <- reshape2:::melt.data.frame(pop_data, id=c("Binomial", "ID"), variable.name = "year", value.name="popvalue")
  #colnames(m_pop_data) <- c("Binomial", "ID", "year", "popvalue")

  #print(dimnames(pop_data))
  m_pop_data$year = substr(m_pop_data$year, 2, 5)
  #cat(colnames(m_pop_data), "\n")

  m_pop_data$popvalue[m_pop_data$popvalue == 'NULL'] = NA
  m_pop_data$popvalue = as.numeric(m_pop_data$popvalue)

  return(m_pop_data)
}

#' Creates an infile from a large 'populations per row' table (e.g. the usual LPI data table)
#'
#' @param pop_data_source - the dataframe containing the data (population per row with cols for data from 1950)
#' @param index_vector - vector of TRUE/FALSE for which rows to include in infile output (default==TRUE, e.g. all data)
#' @param name - Name to give infile, default = "default_infile" (gives default_infile.txt)
#' @param CUT_OFF_YEAR - Year before which data is exluded, default 1950 (the first year of lpi data)
#'
#' @return Returns the name of the created infile
#' @export
#'
create_infile <- function(pop_data_source, index_vector=TRUE, name="default_infile", start_col_name="X1950", end_col_name="X2015", CUT_OFF_YEAR = 1950) {
  # If no index vector is suppled, it will just use all the pop_data_source data
  pop_data <- pop_data_source[index_vector, ]
  all_data <- convert_to_rows(pop_data, start_col_name, end_col_name)
  non_null_all_data = all_data[!is.na(all_data$pop), ]
  clean_data = non_null_all_data[non_null_all_data$year >= CUT_OFF_YEAR, ]
  filename <- paste(name, "_pops.txt", sep="")
  write.table(clean_data, filename, sep="\t", row.names=FALSE, quote = F)
  # Write infile
  in_file_data <- data.frame(FileName=filename, Group=1, Weighting=1)
  write.table(in_file_data, gsub("pops.txt", "infile.txt", filename), sep="\t", row.names=FALSE)
  return(paste(name, "_infile.txt", sep=""))
}
