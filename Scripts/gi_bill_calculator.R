#-------------------------#
# GI Bill Calculator      #
#-------------------------#

library(dplyr)
library(rvest)
library(formattable)

url <- "https://www.liberty.edu/military/gi-bill/veterans-affairs-monthly-pay-rates/"
page <- read_html(url)
table <- html_table(page)

max_tuition <- currency(table[[1]][[2,2]])
max_LUO_MHA <- currency(table[[4]][[3,2]])
max_RES_MHA <- currency(table[[5]][[3,2]])
stipend_30plus <- currency(table[[7]][[2,2]])
stipend_30 <- currency(table[[7]][[3,2]])
stipend_35 <- currency(table[[7]][[4,2]])
stipend_16 <- currency(table[[7]][[5,2]])


sub_term <- c("A","B","C","D")
semester <- c("Fall","Spring","Summer")
credits <- 1:22
level <- c("UG","GR","DR")
campus <- c("RES","LUO")
PoE <- seq(50,100, by = 10) %>% sprintf("%1.0f%%", .)
GI_Bill <- c("VA30","VA30+","VA31","VA33","VA35","VA1606","VAFS")

x <- 1:12
y <- 1:17
z <- round(outer(x,y,FUN ="/"),3)

#-------------#
# UG (CH/S)   #
#-------------#
status_matrix <- function(x,y){
  z <- round(outer(x,y, FUN = "/"),3)
  return(z)}

# .647 ratio full-time UG (exclusive min.)     |  .647 ratio 100% RoP
# .470 ratio 3/4 time UG less .647             |  .625 ratio - .646 90% RoP
# .3131 ratio 1/2 time UG less .470            |  .50 ratio - 624 80% RoP
# less than or equal .313 ratio < 1/2 time UG  |  .471 ratio - .499 70% RoP
#                                              |  .411 ratio - .469 60% RoP
#                                              |  .353 ratio - .409 51% RoP
#                                              |  less than .353 ratio < 50% RoP

#-------#
# GR    #
#-------#
x <- 1:9; status_matrix(x,y)

# .471 ratio full time GR (exclusive min)    |  .471 ratio 100% RoP
# .313 ratio 3/4 time GR less than .470      |  .413 ratio - .469 90% RoP 
# .154 ratio 1/2 time GR less than .3129     |  .354 ratio - .411 80% RoP
#  less than or equal .154 < 1/2 time GR     |  .295 ratio - .353 70% RoP
#                                            |  .235 ratio - .294 60% RoP
#                                            |  .206 ratio- .234 51% RoP
#                                            |  . less than .205 ratio < 50% RoP

#-------#
# DR    #
#-------#
x <- 1:6; status_matrix(x,y)

# .294 ratio full time DR (exclusive min)   |   .309 ratio 100% RoP
# .264 ratio 3/4 time DR less than .294     |   .
# .176 ratio 1/2 time DR less than .264     |
# less than .176 ratio DR < 1/2             |
#                                           |
#                                           |
#                                           |


MHA <- function(PoE,credits,term, semester,level){
  if(PoE < 50 | PoE > 100){
    sop("PoE must be greater than 50% and less or equal to 100%")
  }
  if(credits < 0|| credits > 22||credits != round(credits)|| !length(limit) == 1){
    stop("Number of credits must be greater than zero") 
  }
  if(!semester %in% semester){
    stop("Not a valid semester")
  }
  if(!term %in% sub_term){
    stop("Not a valid sub-term")
  }
  if(!level %in% level){
    stop("Not a valid level")
  }
  if( term = A & semester != "Summer"){
    A <- 17
  } else {
    A <- 14
  }
  if(term == B | term == D){
    B <- 8
    D <- 8
  } else {
    C <- 1/4*A + 1/4*A
  }
  ug_ratio <- c(.647,.625,.501,.471,.411,.353)
  breaks <- c(0,.353,.411,.471,.501,.625,.647,1)
  ug_status <- cut(ug_ratio, breaks = breaks,labels =c("less than 51%","51%","60%","70%","80%","90%","100%") )
  status <- credits/term
  if(level == "UG" & status > .647){
    
  }
}

