#!/usr/bin/python3

import subprocess
import gspread
from oauth2client.service_account import ServiceAccountCredentials

# connect to spreadsheet using Google API with credentials
scope = [
        "https://spreadsheets.google.com/feeds",
        'https://www.googleapis.com/auth/spreadsheets',
        "https://www.googleapis.com/auth/drive.file",
        "https://www.googleapis.com/auth/drive"
]
creds = gspread.service_account(filename='/home/sumit/HoneypotResearchProject/health_log_creds.json')
sheet = creds.open("Honeypot_Health_Logs").sheet1

# Example of how to insert a row
# list(map(lambda s: s.decode(), subprocess.run(['ls'], stdout=subprocess.PIPE).stdout.split()))
row = ["I'm","inserting","a","row","into","a,","Spreadsheet","with","Python", "Hello"]
index = 1
sheet.insert_row(row, index)


def run_ruby(rubycode):
    return subprocess.run(["ruby", "-e", rubycode], stdout=subprocess.PIPE).stdout.decode('ascii').split()


# get host health
host_health = run_ruby("require './health'; print_host_health")
sheet.insert_row(host_health, 2)

