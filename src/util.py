import os

import fbvis_config

# Useful functions


def printDebug(msg):
    print('[DEBUG]\t' + str(msg))

def getMenuInput(menu_list):
    """
    Get user input on a menu list
    
    @param menu_list the available menu items
    @return the user selected index as a number
    @return -1 if quit is selected
    """

    has_valid_input = False
    user_input = -2

    while not has_valid_input:
        attempt_input = input(fbvis_config.USER_INPUT_CHAR)

        if not attempt_input:
            continue
        
        if attempt_input == 'x' or attempt_input == 'X':
            has_valid_input = True
            user_input = -1
        else:
            try:
                num_input = int(attempt_input)
                if num_input in range(len(menu_list)):
                    has_valid_input = True
                    user_input = num_input

            except Exception as identifier:
                printDebug(identifier)
                pass

    return user_input

def verifyAndGetPath(root, rel_path):
    """
    @param[in] root Root directory
    @param[in] rel_path The path we want to verify

    @return Tuple (bool, str) where bool is verify success or not and the
    string is the paths we constructed
    """

    if isinstance(rel_path, list):
        rel_path = os.sep.join(rel_path)

    full_path = os.path.join(root, rel_path)

    if not os.path.isdir(full_path):
        printDebug('Error: {} is not a valid path.'.format(full_path))
        return (False, '')

    return (True, full_path)