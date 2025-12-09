#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Vaciar tablas
$PSQL "TRUNCATE games, teams RESTART IDENTITY"

# Leer el archivo CSV
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipo ganador si no existe
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')" > /dev/null
    fi

    # Insertar equipo oponente si no existe
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')" > /dev/null
    fi

    # Obtener IDs
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insertar partido
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)" > /dev/null
  fi
done
