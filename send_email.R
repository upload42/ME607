library(dplyr)
library(tsibble)
library(rugarch)
library(readr)
library(yfR)
library(blastula)

password <- Sys.getenv("Senha_teste01")

create_smtp_creds_file(file="forecast",
                       user = "trabalho_series@outlook.com",
                       provider = "outlook",
                       password = password)

my_email_object <- render_connect_email("C:/Users/adepaula/OneDrive - Alvarez and Marsal/Documents/Faculdade/Trabalho/Forecast.qmd")

smtp_send(my_email_object,
          from = "trabalho_series@outlook.com",
          to = "trabalho_series@outlook.com",
          subject = "Teste",
          credentials = creds_file("forecast"))

# leitura dos dados
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

#Base de dados
df_forecast = data.frame(data = Sys.Date() + 1,
                          previsao_retorno = round(fore@forecast$seriesFor[1], 4),
                          previsao_sigma = round(fore@forecast$sigmaFor[1], 4))

# salva o novo arquivo .csv
write_csv(df_forecast, file = paste0(df_forecast$data, "_previsao.csv"), 
          append = FALSE, col_names = TRUE)
