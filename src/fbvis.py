# Main entry point

import argparse
import json
import os
import pygame
import sys

import fbvis_config
from util import *

# Argument parsing
parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('root', help='Root directory of the Facebook directory')

# Main program
class FBVis:
    def __init__(self, args):
        """
        Entry point of the program;
        Initialize the main stuff and parse through arguments
        @param[in] args the arguments from the CLI
        """

        self.rootdir = args.root
        self.run()

    def run(self):
        printDebug("Running at {}".format(self.rootdir))
        
        while True:
            # do main menu
            if not self.mainMenu():
                break
        
        printDebug('Program ended')

    def mainMenu(self):
        """
        Prints main menu, get input and do things
        """

        menu_options = ['Visualize Individual Chats']

        index = 0
        for menu_option in menu_options:
            print('[{}]\t{}'.format(index, menu_option))
            index += 1
        print('[X]\tQuit')

        # Get user input
        user_input = getMenuInput(menu_options)

        if user_input == -1:
            return False
        elif user_input == 0:
            # Visualize individual threads
            self.messageIndividualMenu()
        else:
            printDebug('Error at mainMenu')

        return True

    def messageIndividualMenu(self):
        """
        Give a menu option to select which person to visualize
        """

        # Check that the file structure is correct
        messages_path = verifyAndGetPath(self.rootdir, fbvis_config.MESSAGES_INBOX_DIR)
        if messages_path[0]:
            printDebug('File structure valid')

        # Generate menu from using content within
        for item in os.listdir(messages_path[1]):
            print(item)


# Run the program
if __name__ == '__main__':
    FBVis(parser.parse_args())
    sys.exit(0)

sys.exit(1)
