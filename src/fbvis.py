# Main entry point

import argparse
import json
import os
import sys

import fbvis_config
from util import *
import visualizer

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
        menu_map = {}
        unknown_index = 0
        for item in os.listdir(messages_path[1]):
            # If there is item
            # msg_file_rel_path = os.path.join(item, fbvis_config.MESSAGE_FILENAME)
            # msg_file_path = os.path.join(self.rootdir, msg_file_rel_path)

            msg_file_path = os.sep.join([messages_path[1], item, fbvis_config.MESSAGE_FILENAME])

            # If there is something wrong
            if not os.path.isfile(msg_file_path):
                printDebug('Warning: messages folder ({}) doesnt have a message json file'.format(msg_file_path))
                continue
            
            # Check that the file only has two participants
            with open(msg_file_path, encoding='utf-8') as msg_file:
                msg_data = json.load(msg_file)

                participants = msg_data['participants']
                if len(participants) > 2:
                    printDebug('Warning: {} has more than two participants.'.format(msg_file_path))
                    continue

                # Add other person as a menu item
                for participant in participants:
                    name = participant['name']

                    if name != fbvis_config.NAME:

                        # Check name edge cases
                        if name == 'Facebook User':
                            name = 'Facebook User ' + str(unknown_index)
                            unknown_index += 1
                        elif name in fbvis_config.IGNORED_NAMES:
                            continue
                        
                        # Process what to do with name
                        if name[0].upper() in menu_map:
                            menu_map[name[0].upper()][name] = msg_file_path
                        else:
                            menu_map[name[0].upper()] = {}

        # Print a sub map that uses alphabets
        continue_loop = True
        menu_alphabet_list = [key for key in menu_map]
        while continue_loop:
            index = 0
            for alphabet in menu_alphabet_list:
                print('[{}]\t{}'.format(index, alphabet))
                index += 1
            print('[X]\tBack')

            # Get user input
            user_input = getMenuInput(menu_alphabet_list)

            if user_input == -1:
                continue_loop = False
            else:

                menu_names_list = [name for name in menu_map[menu_alphabet_list[user_input]]]

                # Generate secondary menu
                continue_inner_loop = True
                while continue_inner_loop:
                    inner_index = 0
                    for name in menu_names_list:
                        print('[{}]\t{}'.format(inner_index, name))
                        inner_index += 1
                    print('[X]\tBack')

                    inner_user_input = getMenuInput(menu_names_list)

                    if inner_user_input == -1:
                        continue_inner_loop = False
                    else:
                        selected_file = menu_map[menu_alphabet_list[user_input]][menu_names_list[inner_user_input]]
                        printDebug(selected_file + ' selected')

                        visualizer.IndividualVisualizer(selected_file)

# Run the program
if __name__ == '__main__':
    FBVis(parser.parse_args())
    sys.exit(0)

sys.exit(1)
