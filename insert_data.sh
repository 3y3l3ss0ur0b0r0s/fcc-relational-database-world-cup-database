#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# clear tables before running
echo $($PSQL "TRUNCATE TABLE teams,games")

# read through games.csv to populate teams table
# year,round,winner,opponent,winner_goals,opponent_goals

# go through games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip the header line
  if [[ $YEAR != "year" ]]
  then
    # insert winning team info, then opponent; then populate games table

    # winning team
    # get team_id 
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # if team_id not found...
    if [[ -z $TEAM_ID ]]
    then
      # insert team 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
      then
        echo Winning team inserted into teams: $WINNER, $TEAM_ID
      fi
    fi

    # losing team
    # get team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if team_id not found...
    if [[ -z $TEAM_ID ]]
    then
      # insert team 
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
      then
        echo Winning team inserted into teams: $OPPONENT, $TEAM_ID
      fi
    fi

    # populate games table; we don't need to check whether IDs already exist because these games are all unique
    # get winner and opponent names based on ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Game inserted into games: $YEAR, $ROUND, $WINNER ($WINNER_ID), $OPPONENT ($OPPONENT_ID), $WINNER_GOALS, $OPPONENT_GOALS"
    fi
  fi
done

# add games to games table