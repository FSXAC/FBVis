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
from subprocess import Popen, PIPE
from datetime import datetime

import http.server
import socketserver
from threading import Thread

# TODO: add command line parameters for input csv
INPUT_FILE = './messages.csv'
SORTED = './sorted.csv'

# TODO: set as command line parameter (0 for unlimited)
MSG_LIMIT = 0

# TODO: map ids to names automatically (probably via API)
NAME_MAP = {
    '100004290304565@facebook.com':'Winnie  Gong',
    '1483268778@facebook.com':'LuFei Liu',
    '100002533586559@facebook.com':'Danny Hsieh',
    '1579537448@facebook.com':'Paul Liu',
    '100002049867151@facebook.com':'Chris Chiu',
    '691598428@facebook.com':'Keegen Payne',
    '100004795364108@facebook.com':'Christopher Tong',
    '1403335938@facebook.com':'Maharsh Patel'
}

MASTER_NAME = 'Muchen He'
MASTER_ALIAS = [MASTER_NAME, 'Mansur He']
MASTER_ID = '100002015209360@facebook.com'

WRITE_CSV_HEADER = False

PORT = 8000

# Launch local server
process = Popen(['python', '-m', 'http.server', PORT], stdin=None, stdout=PIPE, stderr=PIPE)

# Prompt to enter user access token
accessToken = input('Enter your accesss token: ')
print('Your access token is:', accessToken)
process.kill()

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
        elif participant in NAME_MAP:
            participants[participants.index(participant)] = NAME_MAP[participant]

    # Master ID
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
    # Receiver is the other participant that is not sender
    if sender == MASTER_ID or sender in MASTER_ALIAS:
        writeSender = MASTER_NAME

        if masterParticipantId == 0:
            writeReceiver = participants[1]
        else:
            writeReceiver = participants[0]
        
        if writeReceiver in NAME_MAP:
            writeReceiver = NAME_MAP[writeReceiver]
    else:
        if masterParticipantId == 0:
            writeSender = participants[1]
        else:
            writeSender = participants[0]
        writeReceiver = MASTER_NAME

    # Message length
    writeMsgLen = len(msg)

    return (writeTS, writeSender, writeReceiver, writeMsgLen)

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
    with open(SORTED, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='"')

        # Writer header row
        if WRITE_CSV_HEADER:
            writer.writerow(['time', 'sender', 'receiver', 'msglen'])

        # Write entries to file
        for msgEntry in msgHistorySorted:
            writer.writerow(msgEntry)
