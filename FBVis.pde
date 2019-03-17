// Main entry point of the program

    

import java.util.Map;

// Hash map to hold to the person
HashMap<String, Person> personMap;

MessageManager man;

void setup() {
    //size(1280, 720);

    // TESTING:
    String rel_path = "\\messages\\inbox\\andrewdickson_p47_zcpo4g\\message.json";
    String full_path = pathJoin(DATA_ROOT_DIR, rel_path);

    MessageUtil test = new MessageUtil(full_path);
    println("First time " + str(test.getFirstMessageTimestamp()));
    println("Last time " + str(test.getLastMessageTimestamp()));
    
    man = new MessageManager(DATA_ROOT_DIR);
    
    personMap = new HashMap<String, Person>();
}

void draw() {
    // for (int i = 0; i < chatlist.size(); i++) {
    //     MessageUtil msg = chatlist.get(i);
        
    // }
    
    // drawPersons();
}

void drawPersons() {
//     for (HashMap.Entry<String, Person> entry : personMap.entrySet()) {
//         entry.getValue().draw();
//     }
// }
}