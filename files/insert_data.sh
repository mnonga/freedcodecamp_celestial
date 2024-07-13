#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data
$PSQL "TRUNCATE teams, games RESTART IDENTITY;"

# Insert unique teams
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ $winner != "winner" ]]
  then
    # Insert winner team if not exists
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $TEAM_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted team: $winner"
      fi
    fi

    # Insert opponent team if not exists
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $TEAM_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted team: $opponent"
      fi
    fi
  fi
done

# Insert games
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    # Get team ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $winner vs $opponent, $year"
    fi
  fi
done
