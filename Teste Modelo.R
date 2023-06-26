library(dplyr)
library(tidyverse)
library(yfR)
library(rugarch)
library(tseries)
library(quantmod)
library(xts)
library(PerformanceAnalytics)
library(nortest)
library(GAS)
library(ggpubr)
library(kableExtra)

nome_acao1 <- "UGPA3.SA"   # Código no Yahoo Finance
data_ini1  <- "2018-01-01" # Data de inicio
data_fim1  <- Sys.Date() # Data de fim
UGPA <- yf_get(tickers = nome_acao1, first_date = data_ini1, last_date = data_fim1)
UGPA <- UGPA[-1,]

centrada1 <- na.omit(UGPA$ret_adjusted_prices) - mean(UGPA$ret_adjusted_prices, na.rm = T)

# EGarch(1,1) std
spec1 <- ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
                    variance.model = list(model = 'sGARCH', garchOrder = c(1,1)),
                    distribution = 'std')

fit1 <- ugarchfit(spec1, centrada1, solver = 'hybrid')

fore <- ugarchforecast(fit1, n.ahead = 1)
fore

