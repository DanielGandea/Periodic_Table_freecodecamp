#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
ARGUMENT=$1 # assign the argument to var for clarity

# check if user provided argument
if [[ -z $ARGUMENT ]]
then
  echo Please provide an element as an argument.
  exit
fi

# ~~ Here we try to filter the argument and get the desired response ~~ #
# 1. if argument is a number
if [[ $ARGUMENT =~ ^[0-9]+$ ]]
then
  DB_Query=$($PSQL"SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ARGUMENT;")
fi

# 2. if argument is a name (we assume it will be 4 characters or longer)
if [[ $ARGUMENT =~ ^[a-zA-Z]{4,}$ ]]
then
  DB_Query=$($PSQL"SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE name='$ARGUMENT';")
fi

# 3. if it has 3 letters or less, then try symbol
if [[ $ARGUMENT =~ ^[a-zA-Z]{1,3}$ && $ARGUMENT != 'Tin' ]]
then
  DB_Query=$($PSQL"SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE symbol='$ARGUMENT';")
fi

# 4. add special case for tin which has 3 letters
if [[ $ARGUMENT = 'Tin' ]]
then
  # search by name for tin
  DB_Query=$($PSQL"SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE name='$ARGUMENT';")
fi

# filter the db query to get needed data
if [[ -z $DB_Query && -n $ARGUMENT ]]
then
  echo -e "I could not find that element in the database."

else

  echo $DB_Query | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELT_POINT BOIL_POINT
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
  done
fi



