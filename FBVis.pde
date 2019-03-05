// Main entry point of the program

void setup() {
    //size(1280, 720);

    // TESTING:
    String rel_path = "\\messages\\inbox\\andrewdickson_p47_zcpo4g\\message.json";
    String full_path = pathJoin(DATA_ROOT_DIR, rel_path);

    MessageUtil test = new MessageUtil(full_path);
    println("First time " + str(test.getFirstMessageTimestamp()));
    println("Last time " + str(test.getLastMessageTimestamp()));

}

void draw() {

}