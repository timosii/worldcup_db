#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1") 
cat games.csv | while IFS=",", read YEAR ROUND WINNER LOSER WINNER_GOALS LOSER_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    TEAM_ID_WIN=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")  
    if [[ -z $TEAM_ID_WIN ]]
    then
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
    TEAM_ID_LOSE=$($PSQL "SELECT name FROM teams WHERE name='$LOSER'")
    if [[ -z $TEAM_ID_LOSE ]]
    then
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$LOSER'")
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$LOSER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $LOSER
      fi
    fi
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$LOSER'") 
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$LOSER_GOALS')") 
    if [[ $INSERT_GAMES == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $LOSER_GOALS
    fi
  fi
done
