#!/bin/bash

# assume sudo (in lxc-attach)
# move to home directory
cd

# install java and synthea
sudo apt-get install git -y
sudo apt-get install default-jre -y
sudo apt-get install wget -y
wget https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar

# create config file
touch config
echo "exporter.csv.export = true" > config

# run synthea
NUM_PATIENTS=$(( ( $RANDOM % 5 ) + 20 ))
java -jar synthea-with-dependencies.jar Maryland -c ./config -p "$NUM_PATIENTS"

# pull csv export to home, delete rest
cp ./output/csv/* .
rm config
rm synthea-with-dependencies.jar
sudo rm -rf output

# remove installed libraries
sudo apt-get remove --purge default-jre -y
sudo apt-get remove --purge wget -y
sudo apt-get autoremove -y

rm -- "$0"


