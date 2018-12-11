#model takes a time series object as input
#function to return relevant time series information, series = time series, seasonality = periodicitiy of seasonality, 0 for no seasonality, lags_to_check = number of lags for AR(X) etc. process to check, ahead = number ahead for forecasting
ts_model <- function(series, seasonality, lags_to_check, ahead){
  #importing necessary libraries
  library(astsa)
  library(tseries)
  library(lmtest)
  
  #save original series
  original_series <- series
  
  #testing for heteroskedasticity using Goldfeld-Quandt to see if series needs to be logged
  if (gqtest(series~1)$p.value < 0.05) {
    series <- log(series)
    series_heteroskedasticity <- T
  }else{
    series_heteroskedasticity <- F
  }
  
  #testing for stationarity using the Augmented Dickey-Fuller test with .05 significance level, d is model parameter for eventual SARIMA model
  if(adf.test(series)$p.value <= .05){
    stationarity <- "stationary"
    d <- 0
  #testing for stationarity in first difference
  }else if(adf.test(diff(series))$p.value <= .05){
    stationarity <- "first-difference stationary"
    d <- 1
  }else if(adf.test(diff(diff(series)))$p.value <= .05){
    stationarity <- "second-difference stationary"
    d <- 2
  }else if(adf.test(diff(diff(diff(series))))$p.value <= .05){
    stationarity <- "third-difference stationary"
    d <- 3
  }else if(adf.test(diff(diff(diff(diff(series)))))$p.value <= .05){
    stationarity <- "fourth-difference stationary"
    d <- 4
  }else if(adf.test(diff(diff(diff(diff(diff(series))))))$p.value <= .05){
    stationarity <- "fifth-difference stationary"
    d <- 5
  }else{
    stationarity <- "not stationary at fifth difference"
    d <- 6
  }
  
  #list of parameters to check for seasonal AR, only check seasonal if seasonality != 0
  ar_params <- c(0:lags_to_check)
  if(seasonality == 0){
    sar_params <- 0
  }else{
    sar_params <- c(0:lags_to_check)
  }
  #list of parameters to check for seasonal MA
  ma_params <- c(0:lags_to_check)
  if(seasonality == 0){
    sma_params <- 0
  }else{
    sma_params <- c(0:lags_to_check)
  }
  #list of parameters to check for seasonal differencing
  if(seasonality == 0){
    si <- 0
  }else{
    si <- c(0:3)
  }
  
  #testing permutations of various SARIMA models
  final_p <- 0
  final_q <- 0
  final_P <- 0
  final_D <- 0
  final_Q <- 0
  final_BIC <- 99999999999999999999999999999
  final_AIC <- 99999999999999999999999999999
  for(p in ar_params){
    for(P in sar_params){
      for(q in ma_params){
        for(Q in sma_params){
          for(D in si){
            tryCatch({
              model <- sarima(series, p, d, q, P, D, Q, seasonality)
              #check AIC and BIC
              if(model$BIC < final_BIC){
                final_BIC <- model$BIC
                final_p <- p
                final_q <- q
                final_P <- P
                final_D <- D
                final_Q <- Q
              }
              if(final_AIC <- model$AIC){
                final_AIC <- model$AIC
              }
                #check if they agree
                if(model$BIC < final_BIC & model$AIC < final_AIC){
                  aic_bic_agree <- T
                }else{
                  aic_bic_agree <- F
                }
              }, error=function(e){})
            }
          }
        }
      }
    }
  final_forecast <- sarima.for(series, final_p, d, final_q, final_P, final_D, final_Q, seasonality, n.ahead=ahead)
  final_model <- sarima(series, final_p, d, final_q, final_P, final_D, final_Q, seasonality)
  
  #unlog predictions if necessary
  if(series_heteroskedasticity){
    predictions <- exp(final_forecast$pred)
  }else{
    predictions <- final_forecast$pred
  }
  
  return(list(
    "series"=original_series,
    "transformed_series"=series,
    "stationarity"=stationarity,
    "heteroskedasticity"=series_heteroskedasticity,
    "pred"=predictions,
    "acf"=acf(series),
    "pacf"=pacf(series),
    "model"=final_model,
    "model_name"=paste("SARIMA", "(", final_p, ",", d, ",", final_q, ",", final_P, ",", final_D, ",", final_Q, ")", sep=""),
    "BIC"=final_model$BIC,
    "AIC"=final_model$AIC
    ))
}
