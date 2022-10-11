#!/usr/bin/python3

import gspread
from oauth2client.service_account import ServiceAccountCredentials

# use creds to create a client to interact with the Google Drive and Google Sheets API
scope = [
        "https://spreadsheets.google.com/feeds",
        'https://www.googleapis.com/auth/spreadsheets',
        "https://www.googleapis.com/auth/drive.file",
        "https://www.googleapis.com/auth/drive"
]
creds = gspread.service_account(filename='/home/sumit/HoneypotResearchProject/health_log_creds.json')

# Put the name of your spreadsheet here
sheet = creds.open("Honeypot_Health_Logs").sheet1

# Example of how to insert a row
# list(map(lambda s: s.decode(), subprocess.run(['ls'], stdout=subprocess.PIPE).stdout.split()))
row = ["I'm","inserting","a","row","into","a,","Spreadsheet","with","Python", "Hello"]
index = 1
sheet.insert_row(row, index)

# Example of how to delete a row. This deletes the first row.
#sheet.delete_rows(1)

# Example of how to update a single cell
#sheet.update_cell(1, 1, "Update top left cell")

# How to get the number of rows in the spreadsheet
#sheet.row_count

