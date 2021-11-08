# Load packages
library(dplyr)
library(tidyr)
library(tabulizer)
library(lubridate)

# list of NBA teams
tms <- data.frame(nameTeam = c("Washington Wizards", "Utah Jazz", "Toronto Raptors", "San Antonio Spurs", "Sacramento Kings", "Portland Trail Blazers", "Phoenix Suns", "Philadelphia 76ers", "Orlando Magic", "Oklahoma City Thunder", "New York Knicks", "New Orleans Pelicans", "Minnesota Timberwolves", "Milwaukee Bucks", "Miami Heat", "Memphis Grizzlies", "Los Angeles Lakers", "LA Clippers", "Indiana Pacers", "Houston Rockets", "Golden State Warriors", "Detroit Pistons", "Denver Nuggets", "Dallas Mavericks", "Cleveland Cavaliers", "Chicago Bulls", "Charlotte Hornets", "Brooklyn Nets", "Boston Celtics", "Atlanta Hawks"))

# Get a list of statuses
statuses <- c("Out", "Available", "Questionable", "Probable", "Doubtful")

# Function to parse daily IR reports
get_injuries <- function(date) {

  url <- paste0("https://ak-static.cms.nba.com/referee/injury/Injury-Report_", date, "_08PM.pdf")

  # extract data into a .pdf
  messyData <- extract_tables(url, output = "data.frame")

  # convert to a data frame
  dat <- bind_rows(messyData)

  # if dat is less than equal to 2, than create NA dataframe
  if (nrow(dat) <= 2) {

    df <- data.frame(
      reportDate = date,
      gameDate = date,
      gameMatchup = NA,
      teamName = NA,
      playerName = NA,
      playerStatus = NA,
      playerReason = NA
    )

  }

  # create clean data frame
  else {

    # clean up data
    df <- dat %>%
      mutate(
        playerName = case_when(
          Current.Status %in% statuses ~ Player.Name,
          Player.Name %in% statuses ~ Team,
          Matchup %in% statuses ~ Game.Time,
          Game.Time %in% statuses ~ Game.Date,
          Team %in% statuses ~ Matchup,
          TRUE ~ ""),
        teamName = case_when(
          Game.Date %in% tms$nameTeam ~ Game.Date,
          Game.Time %in% tms$nameTeam ~ Game.Time,
          Matchup %in% tms$nameTeam ~ Matchup,
          Team %in% tms$nameTeam ~ Team,
          Team %in% tms$nameTeam ~ Team,
          TRUE ~ ""),
        playerStatus = case_when(
          Game.Date %in% statuses ~ Game.Date,
          Game.Time %in% statuses ~ Game.Time,
          Matchup %in% statuses ~ Matchup,
          Team %in% statuses ~ Team,
          Player.Name %in% statuses ~ Player.Name,
          Current.Status %in% statuses ~ Current.Status,
          TRUE ~ ""),
        reportDate = date,
        gameDate = as.character(mdy(Game.Date, quiet = TRUE)),
        playerReason = case_when(
          Game.Date %in% statuses ~ Game.Time,
          Game.Time %in% statuses ~ Matchup,
          Matchup %in% statuses ~ Team,
          Team %in% statuses ~ Player.Name,
          Player.Name %in% statuses ~ Current.Status,
          Current.Status %in% statuses ~ Reason,
          TRUE ~ ""),
        gameMatchup = case_when(
          teamName == Team & Team %in% tms$nameTeam ~ Matchup,
          teamName == Matchup & Game.Time != "" ~ Game.Time,
          teamName == Matchup & Game.Time != "" ~ Game.Time,
          teamName == Game.Time & grepl("@", Game.Date) ~ Game.Date,
          teamName == "" & playerStatus == "" ~ "",
          TRUE ~ ""),  
        gameTime = case_when(
          playerName == "" & playerReason == "" ~ "",
          gameMatchup == Matchup ~ Game.Time, 
          gameMatchup == Game.Time ~ Game.Date,
          TRUE ~ ""
        )) %>%  
      filter(playerStatus != "NOT YET SUBMITTED" & playerReason != "NOT YET SUBMITTED") %>%
      select(reportDate, gameDate, gameTime, gameMatchup, teamName, playerName, playerStatus, playerReason) %>%
      mutate(across(everything(), ~ifelse(.=="", NA, as.character(.)))) %>%
      fill(gameDate, gameTime, gameMatchup, teamName) 

  }

  return(df)

}

# Get data
dat <- get_injuries(as.character(Sys.Date() - 1))

# Save data
write.csv(dat, paste0("data/", as.character(Sys.Date() - 1), ".csv"), row.names = FALSE)

