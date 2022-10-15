#!/bin/bash

DIRECTORY_PATH="$1"

NUM_COMMANDS=$(cat "$DIRECTORY_PATH/mitm.log" | grep "line from reader" | awk '{ print $9 }' | wc -l)

cat "$DIRECTORY_PATH/mitm.log" | grep "line from reader" | cut -d' ' -f9- > "$DIRECTORY_PATH/mitm_commands.processed"

echo "$NUM_COMMANDS"

