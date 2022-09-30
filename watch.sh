#!/bin/bash

if [ $# -lt 3 ]; then
   echo "Usage: $0 [file to watch] [line to watch for] [*callback with args]"
   exit 1
fi
TARGET_FILE=$1
EXPRESSION=$2
CALLBACK="${*:3}"

tail -F "$TARGET_FILE" | grep -m 1 "$EXPRESSION" > /dev/null
eval "$CALLBACK"

