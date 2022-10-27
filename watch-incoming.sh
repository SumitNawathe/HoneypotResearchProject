#!/bin/bash

#$1 = size_n_data directory

TARGET=/home/student/$1
TRACKING=/home/student/tracking/$1
DESTINATION=/home/student/unpacked_data/$1
LOG=/home/student/processed_data/"processed_$1.log"

inotifywait -m -e create -e moved_to --format "%f" $TARGET \
        | while read FILENAME
                do
                        cp $TARGET/$FILENAME $TRACKING/$FILENAME
                        tar xvzf $TRACKING/$FILENAME -C $DESTINATION
                        cat $DESTINATION/duration.processed >> $LOG
                        cat $DESTINATION/mitm_commands.processed >> $LOG
                        echo "--------------------------------------------------------" >> $LOG
                done
