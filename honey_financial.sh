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
fakestockdata.generate_stocks()
END

# move data to home, delete generation files
cd
cp -r ./fakestockdata/data/generated/* .
rm -rf fakestockdata/

