#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read PLAYER
PLAYER_INFO=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$PLAYER'")
IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$PLAYER_INFO"
if [[ -z $PLAYER_INFO ]]
then
INSERT_PLAYER=$($PSQL "INSERT INTO players (username) VALUES ('$PLAYER')")
echo "Welcome, $PLAYER! It looks like this is your first time here."
else
echo "Welcome back, $PLAYER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
GUESS_COUNT=0
NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
until [[ $GUESS =~ ^[0-9]+$ ]] && [[ $GUESS -eq $NUMBER ]]
do
  read GUESS
  GUESS_COUNT=$((GUESS_COUNT + 1))
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
UPDATE_GAME_STATS=$($PSQL "UPDATE players
SET games_played = games_played + 1, best_game = LEAST(best_game, $GUESS_COUNT)
WHERE username = '$PLAYER';")
