library(yfR)
library(blastula)
library(rugarch)
library(data.table)
library(readr)

nome_acao1 <- "UGPA3.SA"   # CC3digo no Yahoo Finance
data_ini1  <- "2018-01-01" # Data de inicio
data_fim1  <- Sys.Date() # Data de fim
precos <- yf_get(tickers = nome_acao1, first_date = data_ini1, last_date = data_fim1)
precos <- precos[-1,]


retornos_c = (precos$ret_adjusted_prices) - mean(precos$ret_adjusted_prices, na.rm = T)

spec <- ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE),
                   variance.model = list(model = 'eGARCH', garchOrder = c(1, 1)),
                   distribution = 'sstd')
fit = ugarchfit(spec, retornos_c, solver = "hybrid")

forecast = ugarchforecast(fit, data = df, n.ahead = 1)

new_forecast = data.frame(data = Sys.Date() + 1,
                          previsao_retorno = round(forecast@forecast$seriesFor[1], 4),
                          previsao_sigma = round(forecast@forecast$sigmaFor[1], 4))

# salva o novo arquivo .csv
write_csv(new_forecast, file = "_previsao.csv", 
          append = FALSE, col_names = TRUE)



#create_smtp_creds_file(file = "cred", user = "trabalho_series@outlook.com", provider = "outlook")


corpo = compose_email(body = md("Previsão da ação da empresa Grupo Ultra (UGPA3) um passo a frente, Grupo:Antonio Felipe de Paula Nunes RA:213192, Bianca Barbosa Schorles RA:232117, Lucas Tomaz RA:239931"))


corpo %>% 
  add_attachment(file = "_previsao.csv",filename = "_previsao.csv") %>% 
  smtp_send(from = "trabalho_series@outlook.com",
            to = c(),
            subject = "ME607 - Previsão UGPA3",
            credentials = creds_file("cred"))










