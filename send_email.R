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

