local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org/" 
  options(repos = r)
})

install.packages("dplyr")
install.packages("lubridate")
install.packages("tidyr")
install.packages("tabulizer")
