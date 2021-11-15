/**
 * FBVis
 * Created by Muchen He; see README.md for more details
 */


/**
 * Global variables
 */

/* Object for reading/writing config file */
FBVisConfig g_config;

/* Render layers */
/* TODO: payload should be on its own layers */
RenderUILayer g_uiLayer;
RenderPeopleLayer g_pplLayer;

/* Person node instances (view) */
ArrayList<PersonNode> g_persons;

/* Message payloads (view) */
ArrayList<Payload> g_msgPayloads;

/* Payload factory instantiates msgPayload views */
PayloadFactory g_payloadFactory;

/* Message data and manager */
MsgManager g_msgMan;

/* Layout generator */
LayoutGenerator g_layoutGen;

/* Progress bar TODO: Change name ot ProgressBar */
Progress g_progress;

/* Timing and animation */
long t_current;     /* Current timestamp in ms */
long t_next;        /* Next timestamp in ms */

/* Timeline progress bar */
Timeline g_timeline;

/* Speed controller */
SpeedControl g_speedControl;

/* UI */
PFont g_uiFont;
PFont g_uiMonospaceFont;
Boolean g_uiVisible;
PImage g_logo;
float halfwidth;
float halfheight;

/* Mouse dragging control */
/* TODO: put this to [PER LAYER] control */
Boolean g_mouseLocked = false;
float mouseDown_x = 0;
float mouseDown_y = 0;
float g_offsetX = 0.0;
float g_offsetY = 0.0;

/* App state */
enum AppState {
    UNINITIALIZED,
    RUNNING,
    PAUSED
}
AppState g_appState;


/**
 * Initialization functions
 */
void settings() {
    size(800, 600, P2D);
    halfwidth = width / 2;
    halfheight = height / 2;
}

void setup() {
    /* Configuration */
    g_config = new FBVisConfig();
    g_logo = loadImage("img/logo.png");
    g_logo.resize(0, int(0.3 * height));

    /* Initialize app */
    g_appState = AppState.UNINITIALIZED;
    g_persons = new ArrayList<PersonNode>();
    g_msgPayloads = new ArrayList<Payload>();
    g_payloadFactory = new PayloadFactory(g_msgPayloads);
    g_progress = new Progress();

    frameRate(g_config.fps);

    /* Run data processing routine */
    thread("initialize");
}

void initialize() {
    initializeUI();
    initializeMsgs();

    /* Once done, we can begin playing */
    g_appState = AppState.PAUSED;
}

void initializeUI() {
    /* TODO: remove hardcoded geometry */
    g_timeline = new Timeline(50, height - 50, width - 100, 30);
    g_speedControl = new SpeedControl();
    g_layoutGen = new PackedSpiral(70, halfwidth, halfheight);

    /* TODO: use custom/system-independent fonts */
    g_uiFont = createFont("Helvetica", 32);
    g_uiMonospaceFont = createFont("Courier", 32);
}

void initializeMsgs() {
    g_msgMan = new MsgManager(g_config.dataRootPath);
    g_msgMan.populate(g_progress);
}


/**
 * Drawing functions
 */
void draw() {
    drawLoadingScreen();
}

/**
 * Draw the loading screen while things are still initializing
 */
void drawLoadingScreen() {
    background(0);

    /* Draw text */
    fill(255);
    noStroke();
    textAlign(CENTER, CENTER);
    text("github.com/FSXAC/FBVis", halfwidth, halfheight + 10);
    text("Loading Messenger data . . .", halfwidth, halfheight + 20);

    float y = halfheight + 30;
    stroke(150);
    line(0.3 * width, y, 0.7 * width, y);

    /* Draw logo */
    tint(255, constrain(frameCount, 0, 255));
    image(g_logo, halfwidth - g_logo.width/2, halfheight - g_logo.height);
}



// Mouse input handling
void mousePressed() {
    g_mouseLocked = true;

    mouseDown_x = mouseX - g_offsetX;
    mouseDown_y = mouseY - g_offsetY;
}

void mouseDragged() {
    if (g_appState != AppState.RUNNING || g_appState != AppState.PAUSED) {
        return;
    }

    if (g_mouseLocked) {
        g_offsetX = mouseX - mouseDown_x;
        g_offsetY = mouseY - mouseDown_y;
    }
}

void mouseReleased() {
    g_mouseLocked = false;
}

float mouseXSpace() {
    return mouseX - g_offsetX;
}

float mouseYSpace() {
    return mouseY - g_offsetY;
}
