#!/bin/bash

MAX_LEVEL=15
POUR_RATE=0.2
MAX_FOAM_HEIGHT=3
FOAM_DECAY_RATE=0.08
SLEEP_TIME=0.08
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
RESET=$(tput sgr0)
tput clear

START_TIME=$(date +%s.%N)

while :; do
  CURRENT_TIME=$(date +%s.%N)
  ELAPSED_TIME=$(echo "scale=3; $CURRENT_TIME - $START_TIME" | bc)
  FILL_PERCENT=$(echo "scale=4; 100 * $POUR_RATE * $ELAPSED_TIME" | bc)
  if (($(echo "$FILL_PERCENT > 99" | bc -l))); then
    FILL_PERCENT=100
  fi
  CURRENT_LEVEL=$(echo "$MAX_LEVEL * $FILL_PERCENT / 100" | bc)
  CURRENT_LEVEL=${CURRENT_LEVEL%.*}

  tput cup 1 1
  echo "  (==) "
  echo "+------+"
  for ((i = $MAX_LEVEL; i >= 1; i--)); do
    if [ $i -le $CURRENT_LEVEL ]; then
      if (( i % 2 == 0 && i <= CURRENT_LEVEL - MAX_FOAM_HEIGHT )); then
        echo "${WHITE}|███████|${RESET}"
      else
        echo "${YELLOW}|███████|${RESET}"
      fi
    else
      echo "|      |"
    fi
  done
  echo "+------+"
  if [ $CURRENT_LEVEL -eq $MAX_LEVEL ]; then
    echo -e "\n${YELLOW}--- 🍻 乾杯！ ---${RESET}"
    break
  fi
  sleep $SLEEP_TIME
done
