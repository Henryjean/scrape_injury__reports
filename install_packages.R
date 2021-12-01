local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org/" 
  options(repos = r)
})

install.packages("dplyr")
install.packages("lubridate")
install.packages("tidyr")
install.packages("remotes")
install.packages("devtools")

install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")

