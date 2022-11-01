#!/bin/bash

# $1 = size_n_data directory

TARGET=/home/student/$1
TRACKING=/home/student/tracking/$1
DESTINATION=/home/student/unpacked_data/$1
LOG=/home/student/processed_data/"processed_$1.log"
STAT=/home/student/processed_data/"stats_$1.txt"
ALL_COMMANDS=/home/student/processed_data/"separated_commands_$1.txt"

inotifywait -m -e create -e moved_to --format "%f" $TARGET \
   | while read FILENAME
      do
         cp $TARGET/$FILENAME $TRACKING/$FILENAME
         tar xvzf $TRACKING/$FILENAME -C $DESTINATION
         n1=`cat $DESTINATION/duration.processed | wc -l`
         sum_time_total=0
         for (( c=1; c<=$n1; c++ ))
         do
            time=`cat $DESTINATION/duration.processed | head -$c | tail -1 | cut -d' ' -f2`
            sum_time_total=$((sum_time_total + time))
         done
         time_router=`cat $DESTINATION/duration.processed | grep "router" | cut -d' ' -f2`
         sum_time_internal=$((sum_time - time_router))
         single_commands=`cat $DESTINATION/mitm_commands.processed | grep -v ";" | wc -l`
         for (( d=1; d<=$single_commands; d++ ))
         do
            cat $DESTINATION/mitm_commands.processed | grep -v ";" | head -$d | tail -1 >> $ALL_COMMANDS
         done
         n2=`cat $DESTINATION/mitm_commands.processed | grep ";" | wc -l`
         for (( e=1; e<=$n2; e++ ))
         do
            fields=`cat $DESTINATION/mitm_commands.processed | grep ";" | head -$e | tail -1 | awk -F ';' '{print NF}'`
            for (( f=1; f<=$fields; f++ ))
            do
               cat $DESTINATION/mitm_commands.processed | grep ";" | head -$e | tail -1 | cut -d';' -f$f | sed 's|^[[:blank:]]*||g' >> $ALL_COMMANDS
            done
            multiple_commands=$((fields + multiple_commands))
         done
         unique_commands=`cat $ALL_COMMANDS | sort | uniq | wc -l`
         sum_commands=$((single_commands + multiple_commands))
         cat $DESTINATION/duration.processed >> $LOG
         cat $DESTINATION/mitm_commands.processed >> $LOG
         echo "*---*" >> $LOG
         cat "$sum_time_total,$sum_commands,$unique_commands,$time_router,$sum_time_internal" >> $STAT
      done
