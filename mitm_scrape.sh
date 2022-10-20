#!/bin/bash

DIRECTORY_PATH="$1"

NUM_COMMANDS=$(cat "$DIRECTORY_PATH/mitm.log" | grep "line from reader" | awk '{ print $9 }' | wc -l)

NON_INTERACTIVE_COMMANDS=$(cat "$DIRECTORY_PATH/mitm.log" | grep "Noninteractive mode attacker command" | awk '{ print $10 }' | wc -l)

NUM_COMMANDS=$(( NUM_COMMANDS + NON_INTERACTIVE_COMMANDS ))

cat "$DIRECTORY_PATH/mitm.log" | grep -e "line from reader" -e "Noninteractive mode attacker command" | cut -d':' -f4- | sed 's/^ *//g' > "$DIRECTORY_PATH/mitm_commands.processed"

echo "$NUM_COMMANDS"
