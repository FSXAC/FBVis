import json
import pygame

import fbvis_config
from util import *

class IndividualVisualizer:
    def __init__(self, msg_file):
        printDebug(msg_file + ' received in visualizer')
        self.message_file = msg_file

        # Initialize pygame
        pygame.init()

        self.pyClock = pygame.time.Clock()
        self.pyScreen = pygame.display.set_mode(fbvis_config.VISUALIZER_SCREEN_SIZE)

        self.running = True
        self.fps = 60

        # Process data
        self.processData()
        
        # Entry point
        self.runVisualizer()

    def setDisplayCaption(self, caption):
        pygame.display.set_caption(caption)

    def processData(self):
        with open(self.message_file, encoding='utf-8') as msg_file:
            data = json.load(msg_file)

            me = fbvis_config.NAME
            other = data['participants'].remove(fbvis_config.NAME)[0]

            # Set display caption
            self.setDisplayCaption('Conversation with {}'.format(other))

            messages = data['messages']

    
    def runVisualizer(self):
        while self.running:

            # printDebug('Update tick')

            # Clock tick
            self.pyClock.tick(self.fps)

            # Handle events
            self.handleEvents()

            # Update state

            # Draw
            self.pyScreen.fill([0, 0 ,0])

            # Update frame
            pygame.display.flip()

        # Quit
        pygame.quit()

    def handleEvents(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
