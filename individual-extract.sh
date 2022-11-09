#!/bin/bash
# $1 = size_n_data
# $2 = tar file # in size_n_data directory

SOURCE=/home/student/tracking/$1
DESTINATION=/home/student/analyze

FILE=`ls $SOURCE | head -$2 | tail -1`
mkdir $DESTINATION/$FILE
tar xvzf $SOURCE/$FILE -C $DESTINATION/$FILE
