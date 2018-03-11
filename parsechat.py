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
from datetime import datetime

# TODO: add command line parameters for input csv
INPUT_FILE = './messages.csv'
UNSORTED_FILE = './unsorted.csv'

# TODO: set as command line parameter (0 for unlimited)
MSG_LIMIT = 0

# TODO: map ids to names automatically (probably via API)
NAME_MAP = {
    
}

MASTER_NAME = 'Muchen He'
MASTER_ALIAS = ['Mansur He']
MASTER_ID = '100002015209360@facebook.com'

def getMsgEntry(entry):
    """Returns the formatted csv entry given preparsed csv row"""
    thread = entry[0]
    sender = entry[1]
    date = entry[2]
    msg = entry[3]

    # Check that the thread is only 1-to-1
    participants = thread.split(', ')
    if len(participants) != 2:
        return ''

    for participant in participants:
        if participant == MASTER_ID:
            participants[participants.index(MASTER_ID)] = MASTER_NAME
    
    masterParticipantId = 0
    try:
        masterParticipantId = participants.index(MASTER_NAME)
    except Exception as e:
        print(e)
        print(participants)
        input()

    # Parse time
    timestamp = datetime.strptime(
        date[0:len(date)-6], '%Y-%m-%dT%H:%M'
    )

    # Convert to unix time
    writeTS = int(time.mktime(timestamp.timetuple()))

    # Convert sender name to master name
    writeSender = sender

    # Receiver is the other participant that is not sender
    writeReceiver = ''
    if sender == MASTER_ID or sender in MASTER_ALIAS:
        writeSender = MASTER_NAME

        if masterParticipantId == 0:
            writeReceiver = participants[1]
    else:
        if masterParticipantId == 0:
            writeReceiver = participants[0]

    # Message length
    writeMsgLen = len(msg)

    return (writeTS, writeSender, writeReceiver, writeMsgLen)

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

# Write to as unsorted csv
with open(UNSORTED_FILE, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile, delimiter=',', quotechar='"')

    # Writer header row
    writer.writerow(['time', 'sender', 'receiver', 'msglen'])
    for msgEntry in msgHistoryUnsorted:
        writer.writerow(msgEntry)
