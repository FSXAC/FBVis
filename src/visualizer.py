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
        self.pyFont = pygame.font.SysFont('Arial', 30)
        self.pyScreen = pygame.display.set_mode(fbvis_config.VISUALIZER_SCREEN_SIZE)

        self.running = True
        self.fps = 60

        # Process data
        self.processData()

        # Visualizer settings
        # TODO: make configurable
        
        # Entry point
        self.runVisualizer()

    def setDisplayCaption(self, caption):
        pygame.display.set_caption(caption)

    def processData(self):
        with open(self.message_file, encoding='utf-8') as msg_file:
            data = json.load(msg_file)

            self.person_me = fbvis_config.NAME
            self.person_other = ''
            for participant in data['participants']:
                if participant['name'] != self.person_me:
                    self.person_other = participant['name']

            # Set display caption
            self.setDisplayCaption('Conversation with {}'.format(self.person_other))

            # Messages is an array of message objects
            # The array has its most recent content first,
            # so we just need to go backwards
            self.messages = data['messages']

    
    def runVisualizer(self):

        data_index = len(self.messages) - 1

        while self.running:


            # Clock tick
            self.pyClock.tick(self.fps)

            # Handle events
            self.handleEvents()

            # Draw
            self.pyScreen.fill([0, 0 ,0])

            if 'content' in self.messages[data_index]:
                textsurface = self.pyFont.render(self.messages[data_index]['content'], False, (255, 255, 255))
                self.pyScreen.blit(textsurface, (0, 0))

            if data_index > 0:
                data_index -= 1

            # Update frame
            pygame.display.flip()

        # Quit
        pygame.quit()

    def handleEvents(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
