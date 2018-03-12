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
import requests
import json
import webbrowser
from subprocess import Popen, PIPE
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
EXPORT_NO_NAME = False

PORT = '8000'

# Launch local server
process = Popen(['python', '-m', 'http.server', PORT], stdin=None, stdout=PIPE, stderr=PIPE)
webbrowser.open('http://localhost:8000', new=2)

# Prompt to enter user access token
ACCESS_TOKEN = input('Enter your accesss token: ')
process.kill()

def importNameMap():
    newNameMap = {}
    try:
        with open(NAME_MAP_FILE, newline='', encoding="utf8") as csvfile:
            reader = csv.reader(csvfile, delimiter=',', quotechar='"')
            for row in reader:
                newNameMap[row[0]] = row[1]
    except Exception as e:
        print(e)
    return newNameMap


def saveNameMap():
    with open(NAME_MAP_FILE, 'w', newline='', encoding='utf8') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='"')
        for key in NAME_MAP:
            writer.writerow([key, NAME_MAP[key]])

def getFacebookName(id):
    host = 'https://graph.facebook.com'
    version = '/v2.12'
    path = '/' + id
    url = '{host}{version}{path}?access_token={token}'.format(host=host, version=version, path=path, token=ACCESS_TOKEN)

    try:
        response = requests.get(url)
        data = json.loads(response.text)
        if ('name' in data):
            return data['name']
        else:
            if (EXPORT_NO_NAME):
                return id
            else:
                return ''
    except Exception as e:
        print('Exception in getFacebookName function:', e)
        return ''

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
        else:
            # Participant not in name map -> add to name map
            participantID = participant[0:participant.index('@')]
            name = getFacebookName(participantID)

            if (name == ''):
                return ''

            print('Added to name map:', name)

            # Add to name map
            NAME_MAP[participant] = name

    # Master ID
    masterParticipantId = participants.index(MASTER_NAME)

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

NAME_MAP = importNameMap()
sortMessageCSV(readMessageCSV())
writeMaster()
saveNameMap()
