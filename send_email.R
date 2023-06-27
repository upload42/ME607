library(blastula)

my_email_object <- render_connect_email("Forecast.qmd")

smtp_send(my_email_object,
          from = "trabalho_series@outlook.com",
          to = "trabalho_series@outlook.com",
          subject = "Teste",
          credentials = creds_file("forecast1"))

