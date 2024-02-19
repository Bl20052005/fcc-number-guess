#!/bin/bash
RANDOM_VALUE=$(( ($RANDOM % 1000) + 1 ))
NUM_OF_GUESSES=0
PSQL="psql --username=freecodecamp --dbname=games -t --no-align -c"

echo "Enter your username:"
read USERNAME

DOES_USER_EXIST=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $DOES_USER_EXIST ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADDED_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo $($PSQL "SELECT games_played, best_guess FROM users WHERE username='$USERNAME'") | while IFS="|" read PLAYED BEST
  do
    echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
  done
fi

GUESS() {
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
  fi
  read USER_GUESS
  DETERMINE $USER_GUESS
}

DETERMINE() {
  (( NUM_OF_GUESSES++))
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    if [[ $1 -lt $RANDOM_VALUE ]]
    then
      echo "It's higher than that, guess again:"
      GUESS "guessed"
    fi

    if [[ $1 -gt $RANDOM_VALUE ]]
    then
      echo "It's lower than that, guess again:"
      GUESS "guessed"
    fi
  else
    echo "That is not an integer, guess again:"
    GUESS "guessed"
  fi
}

GUESS

NUM_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_TRY=$($PSQL "SELECT best_guess FROM users WHERE username='$USERNAME'")
((NUM_GAMES_PLAYED++))

SET_TRIES=$($PSQL "UPDATE users SET games_played=$NUM_GAMES_PLAYED WHERE username='$USERNAME'")

if [[ -z $BEST_TRY || $BEST_TRY -gt $NUM_OF_GUESSES ]]
then
  SET_BEST_TRY=$($PSQL "UPDATE users SET best_guess=$NUM_OF_GUESSES WHERE username='$USERNAME'")
fi

echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDOM_VALUE. Nice job!"
