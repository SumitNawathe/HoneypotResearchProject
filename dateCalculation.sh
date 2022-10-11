#!/bin/bash

entryExitCount=`cat $1 | grep "sshd\[.*\]: pam_unix(sshd:session)" | wc -l`
pairCount=$((entryExitCount / 2))
timeTotal=0
n1=1
for (( c=1; c<=$pairCount; c++ ))  
do 
   n2=$((2 * c))    	
   entryMonthDate=`cat $1 | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n1 | tail -1 | colrm 8`  
   exitMonthDate=`cat $1 | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n2 | tail -1 | colrm 8`
   entryTimeStamp=`cat $1 | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n1 | tail -1 | cut -d' ' -f4` 
   exitTimeStamp=`cat $1 | grep "sshd\[.*\]: pam_unix(sshd:session)" | head -$n2 | tail -1 | cut -d' ' -f4`
   entryMonthDateStamp=`date -d"$entryMonthDate" "+%Y-%m-%d"`
   exitMonthDateStamp=`date -d"$exitMonthDate" "+%Y-%m-%d"`
   entryStamp=`date -d"$entryMonthDateStamp $entryTimeStamp" +%s`
   exitStamp=`date -d"$exitMonthDateStamp $exitTimeStamp" +%s`
   timeElapsed=$((exitStamp - entryStamp))
   timeTotal=$((timeTotal + timeElapsed))
   n1=$((n1 + 2))
done
echo "Attacker spent $timeTotal seconds in honeypot"
