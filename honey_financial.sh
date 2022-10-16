#!/bin/bash

# assume sudo (in lxc-attach)
# move to home directory
cd

# install necesary libraries
sudo apt-get update 
sudo apt-get install git -y
sudo apt-get install python3 -y
sudo apt-get install python-is-python3 -y
sudo apt-get install pip -y
pip install fakestockdata
pip install requests
pip install pandas

# clone repo, generate data
git clone https://github.com/mrocklin/fakestockdata.git
cd fakestockdata
python <<END
import fakestockdata
import pandas as pd
fakestockdata.generate_stocks(start=pd.Timestamp('2006-01-01'), freq=pd.Timedelta(minutes=20))
END

# move data to home, delete generation files
cd
cp -r ./fakestockdata/data/generated/* .
sudo rm -rf fakestockdata/

# randomly delete half files
n=$( ls | wc -l )
h=$(( 1 * n / 8 ))
for stock in $( ls | shuf | head -n-$h ); do
   sudo rm -rf "$stock"
done
rm -- "$0"

