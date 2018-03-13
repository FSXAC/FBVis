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
import os
import time
import operator
from datetime import datetime


# TODO: add command line parameters for input csv
INPUT_FILE = './messages.csv'
SORTED = './sorted.csv'
NAME_MAP_FILE = './name_map.csv'
MASTER_FILE = './master.txt'

MSG_LIMIT = 0
NAME_MAP = {}

MASTER_NAME = 'Muchen He'
MASTER_ALIAS = [MASTER_NAME, 'Mansur He']
MASTER_ID = '100002015209360@facebook.com'

WRITE_CSV_HEADER = False
EXPORT_NO_NAME = True
EXPORT_UNKNOWN = False
EXPORT_ZERO_LENGTH = False

def getMsgEntry(entry):
    """Returns the formatted csv entry given preparsed csv row"""
    thread = entry[0]
    sender = entry[1]
    date = entry[2]
    msg = entry[3]

    # Check that the message have content
    if (not EXPORT_ZERO_LENGTH and len(msg) == 0):
        return ''

    # Check that the thread is only 1-to-1
    participants = thread.split(', ')
    if len(participants) > 1:
        return ''

    # Check that the participant has a known name
    if 'Facebook User' in participants and not EXPORT_UNKNOWN:
        return ''

    # Parse time
    timestamp = datetime.strptime(
        date[0:len(date)-6], '%Y-%m-%dT%H:%M'
    )

    # Convert to unix time
    writeTS = int(time.mktime(timestamp.timetuple()))

    # Convert sender name to master name
    # Receiver is the other participant that is not sender
    if sender == MASTER_ID or sender in MASTER_ALIAS:
        writeSender = MASTER_NAME
        writeReceiver = participants[0]
    else:
        writeSender = participants[0]
        writeReceiver = MASTER_NAME

    return (writeTS, writeSender, writeReceiver, len(msg))

def readMessageCSV():
    msgHistoryUnsorted = []
    with open(INPUT_FILE, newline='', encoding="utf8") as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='"')

        msgRead = 0
        for row in reader:

            # Ignore header (for now)
            if msgRead != 0:
                newEntry = getMsgEntry(row)
                if newEntry != '':
                    msgHistoryUnsorted.append(newEntry)

            # Limit number of messages read
            if msgRead > MSG_LIMIT and MSG_LIMIT != 0:
                break
            else:
                msgRead += 1
    return msgHistoryUnsorted

# Write to as unsorted csv
def sortMessageCSV(unsorted):
    msgHistorySorted = sorted(unsorted)
    with open(SORTED, 'w', newline='', encoding='utf8') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='"')

        # Writer header row
        if WRITE_CSV_HEADER:
            writer.writerow(['time', 'sender', 'receiver', 'msglen'])

        # Write entries to file
        for msgEntry in msgHistorySorted:
            writer.writerow(msgEntry)

# Write master
def writeMaster():
    with open(MASTER_FILE, 'w') as mf:
        mf.write(MASTER_NAME)

sortMessageCSV(readMessageCSV())
writeMaster()