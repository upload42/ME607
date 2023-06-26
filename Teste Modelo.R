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
library(emayili)

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

# Salve o forecast como um CSV
write.csv(fore, "forecast.csv")

# Configurar o e-mail
sender <- envelope(
  from = "seriestrabalho1@gmail.com",
  to = "a213192@dac.unicamp.br",
  subject = "Forecast Diário",
  body = "Segue em anexo o forecast de um passo à frente."
)

# Anexe o CSV
sender <- sender$attach_part("forecast.csv")

# Autenticação SMTP
smtp <- server(
  host = "smtp.gmail.com",
  port = 465,
  username = "seriestrabalho1@gmail.com",
  password = "Senha_teste01",
  secure = "ssl"
)

# Envie o e-mail
smtp$send(sender)
