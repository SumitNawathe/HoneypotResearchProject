#!/bin/bash

# $1 = size_n_data
LOCATION=/home/student/processed_data/stats_$1.txt

lines=`cat $LOCATION | wc -l`
time=0
time_total=0
for (( n=1; n<=$lines; n++ ))
do
   time=`cat $LOCATION | head -$n | tail -1 | cut -d',' -f1`
   time_total=$((time_total + time))
   commands=`cat $LOCATION | head -$n | tail -1 | cut -d',' -f2`
   commands_total=$((commands_total + commands))
   unique_commands=`cat $LOCATION | head -$n | tail -1 | cut -d',' -f3`
   unique_commands_total=$((unique_commands_total + unique_commands))
   interactive_sessions=`cat $LOCATION | head -$n | tail -1 | cut -d',' -f6`
   total_interactive_sessions=$((total_interactive_sessions + interactive_sessions))
done
echo "--------------------------------------------"
echo "Total Time: $time_total seconds"
echo "Total Commands: $commands_total"
echo "Total Unique Commands: $unique_commands_total"
echo "Total Sessions: $((n - 1))"
echo "Total Interactive Sessions: $total_interactive_sessions"
echo "Average Time Per Session: $((time_total / n))"
echo "Average Commands Per Session: $((commands_total / n))"
echo "Average Unique Commands Per Session: $((unique_commands_total / n))"
echo "--------------------------------------------"
