// Configuration

final String PATH_SEPARATOR = "\\";
final String DATA_ROOT_DIR = "C:\\Users\\mansu\\OneDrive\\Documents\\Facebook Data 2019";

final String FACEBOOK_USER_NAME = "Facebook User";

final String MASTER_NAME = "Muchen He";

final boolean VERBOSE = false;

final boolean SHADERS = true;

final float PAYLOAD_OPACITY_MIN = 50;
final float PAYLOAD_OPACITY_MAX = 60;
final float PAYLOAD_SEGMENT_LERP_MIN = 0.3;
final float PAYLOAD_SEGMENT_LERP_MAX = 0.5;
final float PAYLOAD_SEGMENT_GROUP_LERP_MIN = 0.5;
final float PAYLOAD_SEGMENT_GROUP_LERP_MAX = 0.7;
//final color SEND_COLOR = color(150, 255, 150);
//final color RECEIVE_COLOR = color(255, 150, 150);
//final color GROUP_COLOR = color(80, 150, 255);
final color SEND_COLOR = color(42, 153, 42);
final color RECEIVE_COLOR = color(153, 62, 62);
final color GROUP_COLOR = color(20, 41, 83);

final boolean USE_MESSAGE_CONTENT_AS_SIZE = true;

final boolean FULLSCREEN = false;
final boolean ANNON_NAMES = false;
final String ANNON_NAME_DEFAULT = "Friend";

final float DESIRED_FPS = 60;

final boolean USE_UNIFORM_TIME = true;

// Start from very beginning
final long START_TIMESTAMP = 0;

// 1 day per frame
final float DAYS_PER_SECOND = 0.1;
final long DELTA_TIMESTAMP = (long) (3600 * 24 * 1000 * DAYS_PER_SECOND / DESIRED_FPS);

// Number of seconds without anything to autoskip
final float AUTO_SKIP_SECONDS = 4;
final long AUTO_SKIP_TIMESTAMP = (long) (DELTA_TIMESTAMP * AUTO_SKIP_SECONDS * DESIRED_FPS);

final long SKIP_TIMESTAMP = (long) (DELTA_TIMESTAMP * DESIRED_FPS * 10);

// If not using uniform time, then how much faster is the thing is visualized
// Value of 2 means 2 messages are visualized per frame
final int SPEED_SCALE = 1;

final String[] IGNORE_LIST = {
    "ecess20162017nobusinessallowed_xb_5gacbmw",
    "catobsession_bgzdw1_z_w"
};
