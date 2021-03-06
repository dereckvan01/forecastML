% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lagged_df.R
\name{create_lagged_df}
\alias{create_lagged_df}
\title{Create model training and forecasting datasets with lagged, grouped, dynamic, and static features}
\usage{
create_lagged_df(
  data,
  type = c("train", "forecast"),
  method = c("direct", "multi_output"),
  outcome_col = 1L,
  horizons,
  lookback = NULL,
  lookback_control = NULL,
  dates = NULL,
  frequency = NULL,
  dynamic_features = NULL,
  groups = NULL,
  static_features = NULL,
  use_future = FALSE,
  keep_rows = FALSE
)
}
\arguments{
\item{data}{A data.frame with the (a) target to be forecasted and (b) features/predictors. An optional date column can be given in the
\code{dates} argument (required for grouped time series). Note that forecastML only works with regularly spaced date/time intervals and that missing
rows--usually due to periods when no data was collected--will result in poorly trained models due to incorrect feature lags.
Use \code{\link{fill_gaps}} to fill in any missing rows/data prior to running this function.}

\item{type}{The type of dataset to return--(a) model training or (b) forecast prediction. The default is \code{train}.}

\item{method}{The type of modeling dataset(s) to create. \code{direct} returns 1 data.frame for each forecast horizon and
\code{multi_outcome} returns 1 data.frame for simultaneously modeling all forecast horizons. The default is \code{direct}.}

\item{outcome_col}{The column index--an integer--of the target to be forecasted. Forecasting only one outcome column is allowed at present, however,
groups of time series can be forecasted if they are stacked vertically in a long dataset and the \code{groups}, \code{dates},
and \code{frequency} arguments are specified.}

\item{horizons}{A numeric vector of one or more forecast horizons, h, measured in input dataset rows. For each horizon, 1:h
forecasts are returned (e.g., \code{horizons = 12} trains a model to minimize 1 to 12-step-ahead error and returns forecasts
for 1:12 steps into the future). If \code{dates} are given, a horizon of 1, for example, would equal 1 * \code{frequency} in calendar time.}

\item{lookback}{A numeric vector giving the lags--in dataset rows--for creating the lagged features. All non-grouping,
non-static, and non-dynamic features in the input dataset, \code{data}, are lagged by the same values.
For lagged features, lag values that don't support direct forecasting for a given forecast horizon
(e.g, a lookback of 3 for a 4-step-ahead horizon) are silently dropped from the data.frame.
Either \code{lookback} or \code{lookback_control} need to be specified.}

\item{lookback_control}{A list of numeric vectors, specifying potentially unique lags for each feature. The length
of the list should equal \code{ncol(data)} and be ordered the same as the columns in \code{data}. Lag values for any grouping,
static, or dynamic feature columns are automatically coerced to 0 nd not lagged. \code{list(NULL)} \code{lookback_control} values drop columns
from the input dataset. For lagged features, lag values that don't support direct forecasting for a given forecast horizon
are silently dropped from the data.frame. Either \code{lookback} or \code{lookback_control} need to be specified.}

\item{dates}{A vector or 1-column data.frame of dates/times with class 'Date' or 'POSIXt'. The length
of 'dates' should equal \code{nrow(data)}. Required if \code{groups} are given.}

\item{frequency}{Date/time frequency. Required if \code{dates} are given. A string taking the same input as \code{base::seq.Date(..., by = "frequency")} or
\code{base::seq.POSIXt(..., by = "frequency")} e.g., '1 hour', '1 month', '7 days', '10 years' etc.
The highest frequency supported at present is '1 sec'.}

\item{dynamic_features}{A character vector of column names that identify features that change through time but which are not lagged (e.g., weekday or year).
If \code{type = "forecast"}, these features will receive \code{NA} values; though, they can be filled in by the user after running this function.}

\item{groups}{A character vector of column names that identify the groups/hierarchies when multiple time series are present. These columns are used as model features but
are not lagged. Note that combining feature lags with grouped time series will result in \code{NA} values throughout the data.}

\item{static_features}{For grouped time series only. A character vector of column names that identify features that do not change through time.
These columns are not lagged. If \code{type = "forecast"}, these features will be filled forward using the most recent value for the group.}

\item{use_future}{Boolean. If \code{TRUE}, the \code{future} package is used for creating lagged data.frames.
\code{multisession} or \code{multicore} futures are especially useful for (a) grouped time series with many groups and
(b) high-dimensional datasets with many lags per feature. Run \code{future::plan(future::multiprocess)} prior to this
function to set up multissession or multicore parallel dataset creation.}

\item{keep_rows}{Boolean. For non-grouped time series, keep the \code{1:max(lookback)} rows at the beginning of the time series. These rows will
contain missing values for lagged features that "look back" before the start of the dataset.}
}
\value{
An S3 object of class 'lagged_df' or 'grouped_lagged_df': A list of data.frames with new columns for the lagged/non-lagged features.
The length of the returned list is equal to the number of forecast horizons and is in the order of
horizons supplied to the \code{horizons} argument. Horizon-specific datasets can be accessed with
\code{my_lagged_df$horizon_h} where 'h' gives the forecast horizon.

The contents of the returned data.frames are as follows:

\describe{
  \item{\strong{type = 'train', non-grouped:}}{A data.frame with the outcome and lagged/dynamic features.}
  \item{\strong{type = 'train', grouped:}}{A data.frame with the outcome and unlagged grouping columns followed by lagged, dynamic, and static features.}
  \item{\strong{type = 'forecast', non-grouped:}}{(1) An 'index' column giving the row index or date of the
  forecast periods (e.g., a 100 row non-date-based training dataset would start with an index of 101). (2) A 'horizon' column
  that indicates the forecast period from \code{1:max(horizons)}. (3) Lagged features identical to the
  'train', non-grouped dataset.}
  \item{\strong{type = 'forecast', grouped:}}{(1) An 'index' column giving the date of the
  forecast periods. The first forecast date for each group is the maximum date from the \code{dates} argument
  + 1 * \code{frequency} which is the user-supplied date/time frequency.(2) A 'horizon' column that indicates
  the forecast period from \code{1:max(horizons)}. (3) Lagged, static, and dynamic features identical to the 'train', grouped dataset.}
}
}
\description{
Create a list of datasets with lagged, grouped, dynamic, and static features to (a) train forecasting models for
specified forecast horizons and (b) forecast into the future with a trained ML model.
}
\section{Attributes}{


\itemize{
  \item \code{names}: The horizons-specific datasets that can be accessed by \code{my_lagged_df$horizon_h} where 'h' gives
  the forecast horizons.
  \item \code{type}: Training, \code{train}, or forecasting, \code{forecast}, dataset(s).
  \item \code{horizons}: Forecast horizons measured in dataset rows.
  \item \code{outcome_col}: The column index of the target being forecasted.
  \item \code{outcome_names}: The name of the target being forecasted.
  \item \code{predictor_names}: The predictor or feature names from the input dataset.
  \item \code{row_indices}: The \code{row.names()} of the output dataset. For non-grouped datasets, the first
  \code{lookback} + 1 rows are removed from the beginning of the dataset to remove \code{NA} values in the lagged features.
  \item \code{date_indices}: If \code{dates} are given, the vector of \code{dates}.
  \item \code{frequency}: If \code{dates} are given, the date/time frequency.
  \item \code{data_start}: \code{min(row_indices)} or \code{min(date_indices)}.
  \item \code{data_stop}: \code{max(row_indices)} or \code{max(date_indices)}.
  \item \code{groups}: If \code{groups} are given, a vector of group names.
  \item \code{class}: grouped_lagged_df, lagged_df, list
}
}

\section{Methods and related functions}{


The output of \code{create_lagged_df()} is passed into

\itemize{
  \item \code{\link{create_windows}}
}

and has the following generic S3 methods

\itemize{
  \item \code{\link[=summary.lagged_df]{summary}}
  \item \code{\link[=plot.lagged_df]{plot}}
}
}

\examples{
# Sampled Seatbelts data from the R package datasets.
data("data_seatbelts", package = "forecastML")
#------------------------------------------------------------------------------
# Example 1 - Training data for 2 horizon-specific models w/ common lags per predictor.
horizons <- c(1, 12)
lookback <- 1:15

data <- data_seatbelts

data_train <- create_lagged_df(data_seatbelts, type = "train", outcome_col = 1,
                               horizons = horizons, lookback = lookback)
head(data_train[[length(horizons)]])

# Example 1 - Forecasting dataset
# The last 'nrow(data_seatbelts) - horizon' rows are automatically used from data_seatbelts.
data_forecast <- create_lagged_df(data_seatbelts, type = "forecast", outcome_col = 1,
                                  horizons = horizons, lookback = lookback)
head(data_forecast[[length(horizons)]])

#------------------------------------------------------------------------------
# Example 2 - Training data for one 3-month horizon model w/ unique lags per predictor.
horizons <- 3
lookback <- list(c(3, 6, 9, 12), c(4:12), c(6:15), c(8))

data_train <- create_lagged_df(data_seatbelts, type = "train", outcome_col = 1,
                               horizons = horizons, lookback_control = lookback)
head(data_train[[length(horizons)]])
}
