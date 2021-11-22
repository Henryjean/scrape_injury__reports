local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org/" 
  options(repos = r)
})

install.packages("dplyr")
install.packages("lubridate")
install.packages("tidyr")
install.packages("remotes")
remotes::install_github(c("remotes/tabulizerjars", "remotes/tabulizer"), INSTALL_opts = "--no-multiarch", dependencies = c("Depends", "Imports"))
