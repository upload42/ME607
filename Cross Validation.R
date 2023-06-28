library(tidyverse)
library(lubridate)
library(ggplot2)
library(forecast)
library(tseries)
library(caret)
library(tsibble)
library(tsibbledata)
library(fpp3)
library(GAS)
library(yfR)
library(rugarch)

nome_acao1 <- "UGPA3.SA"   # CC3digo no Yahoo Finance
data_ini1  <- "2018-01-01" # Data de inicio
data_fim1  <- Sys.Date() # Data de fim
UGPA <- yf_get(tickers = nome_acao1, first_date = data_ini1, last_date = data_fim1)
UGPA <- UGPA[-1,]

centrada1 <- na.omit(UGPA$ret_adjusted_prices) - mean(UGPA$ret_adjusted_prices, na.rm = T)

# EGarch(1,1) sstd
spec1 <- ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
                    variance.model = list(model = 'eGARCH', garchOrder = c(1,1)),
                    distribution = 'sstd')

fit1 <- ugarchfit(spec1, centrada1, solver = 'hybrid')

fore1 <- ugarchforecast(fit1, n.ahead = 1)

xf = function(x, mu_, sigma_, skew_, shape_) {
  x*ddist(distribution = "sstd", 
          y = x,
          mu = mu_, 
          sigma = sigma_, 
          skew = skew_,
          shape = shape_)
}

retornos <- UGPA$ret_adjusted_prices
ntotal <- length(retornos)
InS <- 1000
OoS <- ntotal - InS
alpha = 0.01

var <- c()
es <- c()
for (i in 1:OoS) {
  print(i)
  ret <- retornos[i:(InS + i - 1)]
  fit <- ugarchfit(spec1, ret, solver = 'hybrid')
  fore <- ugarchforecast(fit, n.ahead = 1)
  var[i] <- qdist(distribution = "std", alpha, mu = fore@forecast[["seriesFor"]][1], sigma = sigma(fore)[1], skew = 0, shape = coef(fit)["shape"])
  es[i] <- integrate(xf, 
                     -Inf, 
                     var[i], 
                     mu_ = fore@forecast[["seriesFor"]][1],
                     sigma_ = sigma(fore)[1],
                     skew_ = coef(fit)["skew"],
                     shape_ = coef(fit)["shape"])$value/alpha
  
}

ret_oos <- retornos[(InS + 1) : (InS + 358)]

BacktestVaR(ret_oos, head(var, 358), alpha = 0.01, Lags = 4)
ESTest(alpha = 0.01, ret_oos, head(es, 358), head(var, 358), conf.level = 0.95,  boot = FALSE)
