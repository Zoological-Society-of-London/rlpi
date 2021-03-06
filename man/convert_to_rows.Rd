% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_infile.R
\name{convert_to_rows}
\alias{convert_to_rows}
\title{Converts wide data (population per row, many columns) to long data: popvalue/year per row}
\usage{
convert_to_rows(in_data, start_col_name = "X1950",
  end_col_name = "X2017")
}
\arguments{
\item{in_data}{- the dataframe containing the data (population per row with cols for data from 1950)}
}
\value{
Returns a data frame with (Binomial, ID, year, popvalue) columns
}
\description{
Converts wide data (population per row, many columns) to long data: popvalue/year per row
}
