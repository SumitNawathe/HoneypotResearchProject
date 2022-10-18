# install necesary libraries
sudo apt-get update
sudo apt-get install git -y
sudo apt-get install python3 -y
sudo apt-get install python-is-python3 -y
sudo apt-get install pip -y
pip install Faker
pip install pandas

from faker import Faker
from faker_security.providers import SecurityProvider
import pandas as pd
import numpy as np
import sys


def fake():
    fake = Faker()

    fake.cvss3()

    fake.cvss2()

    fake.version()

    fake.npm_semver_range()

    fake.cwe()

    fake.cve()

    d = {'CVSS v3.0 Score': [fake.cvss3(), fake.cvss3()], 'CVSS v2.0 Score': [fake.cvss2(), fake.cvss2()], 'Version Number': [fake.version(), fake.version()], 'NPM Version Range': fake.npm_semver_range(), fake.npm_semver_range()], 'CWE': [fake.cwe(), fake.cwe()], 'CVE': [fake.cve(), fake.cve()]}

    df = pd.DataFrame(data=d)

    for i in range(200):
        df.loc[len(df.index)] = [fake.cvss3(), fake.cvss2(), fake.version(), fake.npm_semver_range(), fake.cwe(), fake.cve()]

    print(df)


for i in range(10):
    with open('people' + str(i), 'w') as sys.stdout:
        fake()
