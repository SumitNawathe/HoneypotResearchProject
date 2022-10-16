# install necesary libraries
sudo apt-get update
sudo apt-get install git -y
sudo apt-get install python3 -y
sudo apt-get install python-is-python3 -y
sudo apt-get install pip -y
pip install Faker
pip install pandas

from faker import Faker
import pandas as pd
import numpy as np
import sys


def fake():
    fake = Faker()

    fake.name()
    # 'Lucy Cechtelar'

    fake.address()
    # '426 Jordy Lodge
    #  Cartwrightshire, SC 88120-6700'

    fake.text()

    d = {'Name': [fake.name(), fake.name()], 'Address': [fake.address(), fake.address()], 'Comment': [fake.text(), fake.text()]}

    df = pd.DataFrame(data=d)

    for i in range(200):
        df.loc[len(df.index)] = [fake.name(), fake.address(), fake.text()]

    print(df)


for i in range(10):
    with open('people' + str(i), 'w') as sys.stdout:
        fake()
