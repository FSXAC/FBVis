# This python file should parse the already parsed chat log even more
# by ignoring the message content and purely focus on who and when the chat
# occured
#
# This program should also put everything in chronological order
#
# Right now, group chats are not supported (only 1-to-1 conversations)
#
# File output is another csv file with convention:
# time in unix style | sender | receiver | length of message

import csv

# TODO: add command line parameters for input csv
INPUT_FILE = './messages.csv'

# TODO: set as command line parameter
MSG_LIMIT = 5

def getMsgEntry(entry):
    """Returns the formatted csv entry given preparsed csv row"""
    thread = entry[0]
    sender = entry[1]
    date = entry[2]
    msg = entry[3]

    print(date)

with open(INPUT_FILE, newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')

    msgRead = 0
    for row in reader:

        # Ignore header (for now)
        if msgRead != 0:
            getMsgEntry(row)

        # Limit number of messages read
        if msgRead > MSG_LIMIT:
            break
        else:
            msgRead += 1