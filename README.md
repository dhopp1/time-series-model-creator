# time-series-model-creator
R function to find best model to fit a time series dataset, similar in functionality to auto.arima (https://www.rdocumentation.org/packages/forecast/versions/8.4/topics/auto.arima). It works by using the SARIMA function of the _astsa_ library to estimate various models and select the best one based on Bayesian Information Criteria, as well as returning info on heteroskedasticity and stationarity. It was written to fulfill my specific needs, so for most people auto.arima should suffice.

<br>

## Prerequisites
<br>
Necessary libraries for the function are:
<br>

1. astsa (for the sarima function to estimate time series models)
2. tseries (for the Augmented Dickey-Fuller Test testing for a unit-root/stationarity)
3. lmtest (for the Goldfeld-Quandt test for heteroskedasticity)

## Use
<br>
The function takes four arguments:
<br>

1. _series_ - the time series object for which a model is to be estimated/forecast
2. _seasonality_ - the periodicity of seasonality if present, e.g. 12 for yearly seasonality on monthly data. Pass 0 for no seasonality
3. _lags_to_check_ - the number of lags to check in the SARIMA model for each argument of the SARIMA() model, similar to autom.arima's max.p etc. arguments
4. _ahead_ - number or periods ahead to predict for forecasting

## Output
<br>
The function returns the following:
<br>

1. _series_ - the original time series
2. _transformed_series_ - the series as it was transformed to fit the SARIMA model (e.g. the logged series, differenced series, etc.)
3. _heteroskedasticity_ - a boolean indicating if the Goldfeld-Quandt found significance at the 5% level and thus the series was logged to estimate the model
4. _pred_ - a vector of predictions based on the model as many periods ahead as specified by the "ahead" argument
5. _acf_ - a vector of auto-correlations of the tranformed series
6. _pacf_ - a vector of partial auto-correlations of the tranformed series
7. _model_ - the SARIMA model object
8. _model_name_ - which SARIMA model was estimated in the format of "SARIMA(p,d,q,P,D,Q)"
9. _BIC_ - the Bayesian Information Criteria
10. _AIC_ - the Akaike Information Criteria
