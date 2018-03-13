// Given master.txt and sorted.csv
// Visualize message transactions of messages

final boolean DO_FORCE_LENGTH = false;
final int FORCE_LENGTH = 100;
final int STARTING_INDEX = 11000;

final int PEOPLE_SIZE = 20;
final float ENABLE_ENLARGE_FACTOR = 1.2;
final float PEOPLE_LERPNESS = 0.5;

Table g_chats;
int g_chatLength;
int g_currentEntry;

String masterName;
