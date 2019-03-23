final int TOP_OFFSET = 20;
final int TOP_SIZE = 20;

void drawLoading() {
    fill(255);
    text("Reading log . . .", width/2, height/2);
}

void drawTopText(String txt) {
    fill(255);
    textSize(TOP_SIZE);
    text(txt, width/2, TOP_OFFSET);
}