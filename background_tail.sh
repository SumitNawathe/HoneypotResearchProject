#!/bin/bash

if [ $# -ne 2 ]; then
   echo "Usage: $0 [tail file] [output file]"
   exit 1
fi
TAILFILE=$1
OUTPUTFILE=$2

sudo tail -n+0 -f "$TAILFILE" >> "$OUTPUTFILE" &
