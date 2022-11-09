#!/bin/bash

# $1 = size_n_data directory

TARGET=/home/student/$1
TRACKING=/home/student/tracking/$1
DESTINATION=/home/student/unpacked_data/$1
DURATION=$DESTINATION/duration.processed
COMMANDS_HOLDING=/home/student/unpacked_data/$1/holding_$1.log
LOG=/home/student/processed_data/"processed_$1.log"
STAT=/home/student/processed_data/"stats_$1.txt"
ALL_COMMANDS=/home/student/processed_data/"separated_commands_$1.txt"

inotifywait -m -e create -e moved_to --format "%f" $TARGET \
   | while read FILENAME
      do
         cp $TARGET/$FILENAME $TRACKING/$FILENAME
         tar xvzf $TRACKING/$FILENAME -C $DESTINATION
         rm $DURATION
         ip_address=`cat $DESTINATION/external_ip.txt`
         size=`echo $1 | cut -d'_' -f2`
         n=$((size + 1))
         for (( a=1; a<=$n; a++ ))
         do
            ls $DESTINATION | grep "$ip_address" | head -$a | tail -1 > $DESTINATION/file.txt
            name=$(cat $DESTINATION/file.txt)
            entryExitCount=`cat $DESTINATION/$name | grep "sshd\[.*\]: pam_unix(sshd:session)" | wc -l`
            pairCount=$((entryExitCount / 2))
            timeTotal=0
            if [[ $pairCount -gt 1 ]]; then
               timeTotal=0
               n1=3
               for (( b=2; b<=$pairCount; b++ ))
               do
                  n2=$((2 * b))
                  entryMonthDate=`cat $DESTINATION/$name | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n1 | tail -1 | colrm 7`
                  exitMonthDate=`cat $DESTINATION/$name | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n2 | tail -1 | colrm 7`
                  entryTimeStamp=`cat $DESTINATION/$name | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n1 | tail -1 | awk '{print $3}'`
                  exitTimeStamp=`cat $DESTINATION/$name | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n2 | tail -1 | awk '{print $3}'`
                  entryMonthDateStamp=`date -d"$entryMonthDate" "+%Y-%m-%d"`
                  exitMonthDateStamp=`date -d"$exitMonthDate" "+%Y-%m-%d"`
                  entryStamp=`date -d"$entryMonthDateStamp $entryTimeStamp" +%s`
                  exitStamp=`date -d"$exitMonthDateStamp $exitTimeStamp" +%s`
                  timeElapsed=$((exitStamp - entryStamp))
                  timeTotal=$((timeTotal + timeElapsed))
                  n1=$((n1 + 2))
               done
            fi
            containerName=`echo $name | cut -d'.' -f1-4`
            echo "$containerName $timeTotal" >> $DURATION
         done
         n3=`cat $DESTINATION/duration.processed | wc -l`
         sum_time_total=0
         for (( c=1; c<=$n3; c++ ))
         do
            time=`cat $DESTINATION/duration.processed | head -$c | tail -1 | cut -d' ' -f2`
            sum_time_total=$((sum_time_total + time))
         done
         time_router=`cat $DESTINATION/duration.processed | grep "router" | cut -d' ' -f2`
         sum_time_internal=$((sum_time_total - time_router))
         if [ $sum_time_internal -lt 0 ]
         then
             sum_time_internal=0
         fi
         single_commands=`cat $DESTINATION/mitm_commands.processed | grep -v ";" | wc -l`
         for (( d=1; d<=$single_commands; d++ ))
         do
            cat $DESTINATION/mitm_commands.processed | grep -v ";" | head -$d | tail -1 | tee -a $ALL_COMMANDS $COMMANDS_HOLDING >/dev/null
         done
         n4=`cat $DESTINATION/mitm_commands.processed | grep ";" | wc -l`
         fields=0
         multiple_commands=0
         for (( e=1; e<=$n4; e++ ))
         do
            fields=`cat $DESTINATION/mitm_commands.processed | grep ";" | head -$e | tail -1 | awk -F ';' '{print NF}'`
            for (( f=1; f<=$fields; f++ ))
            do
               cat $DESTINATION/mitm_commands.processed | grep ";" | head -$e | tail -1 | cut -d';' -f$f | sed 's|^[[:blank:]]*||g' | tee -a $ALL_COMMANDS $COMMANDS_HOLDING >/dev/null
            done
            multiple_commands=$((fields + multiple_commands))
         done
         unique_commands=`cat $COMMANDS_HOLDING | sort | uniq | wc -l`
         sum_commands=$((single_commands + multiple_commands))
         cat $DESTINATION/duration.processed >> $LOG
         cat $DESTINATION/mitm_commands.processed >> $LOG
         echo "*---*" >> $LOG
         echo "$sum_time_total,$sum_commands,$unique_commands,$time_router,$sum_time_internal" >> $STAT
         rm $COMMANDS_HOLDING $DURATION
      done
