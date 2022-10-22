#!/usr/bin/python3

import time
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
creds = gspread.service_account(filename='/home/student/HoneypotResearchProject/health_log_creds.json')
sheets = creds.open("Honeypot_Health_Logs")

# utilities
timestamp = str(int(time.time()))
def run_ruby(rubycode):
    return subprocess.run(["ruby", "-e", rubycode], stdout=subprocess.PIPE).stdout.decode('ascii').split()

# get host health
host_health = run_ruby("require './health'; print_host_health")
sheets.get_worksheet(0).insert_row([timestamp] + host_health, 2)

# loop through external IP's
with open('./ip_to_mitm_port.txt') as f:
    external_ips = list(map(lambda s: s.split()[0], f.readlines()))
for i, ip in enumerate(external_ips):
    honeypot_exists = run_ruby(f"require './health'; network_exists? '{ip}'")[0]
    if honeypot_exists == "NO":
        # honeypot file not present
        honeypot_health = ["HONEYPOT DOWN"]
    else:
        # get honeypot health
        honeypot_health = run_ruby(f"require './health'; print_network_health_for_ip '{ip}'")
    sheets.get_worksheet(i+1).insert_row([timestamp] + honeypot_health, 2)

