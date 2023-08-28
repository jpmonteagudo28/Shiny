#-------------------------#
# GI Bill Calculator      #
#-------------------------#

library(dplyr)
library(rvest)
url <- "https://www.liberty.edu/military/gi-bill/veterans-affairs-monthly-pay-rates/"
page <- read_html(url)
table <- html_table(page)

term <- c("A","B","C","D")
semester <- c("Fall","Spring","Summer")
credits <- 1:22
level <- c("UG","GR","DR")
campus <- c("RES","LUO")
PoE <- seq(50,100, by = 10) %>% sprintf("%1.0f%%", .)
GI_Bill <- c("VA30","VA30+","VA31","VA33","VA35","VA1606","VAFS")



