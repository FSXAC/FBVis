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

/*
 * Singleton class for accessing the configurations which is read from the config file
 * NOTE: since everything inside .pde file is an inner class, we cannot have static classes
 * so instead I trust that future-me will not use multiple instances of this class.
 */
public class FBVisConfig {

    /* Private default settings */
    private String pathSeparator;

    private String dataRootPath;
    private String masterName = "Master name";
    private String defaultName = "Facebook user";
    
    private boolean enableVerbose = false;
    private boolean enableShaders = true;
    private boolean enableFullscreen = false;
    private int fps = 60;

    private int payloadOpacityMin = 50;
    private int payloadOpacityMax = 60;
    private float payloadSegmentLerpMin = 0.3;
    private float payloadSegmentLerpMax = 0.5;
    private float payloadSegmentGroupLerpMin = 0.5;
    private float payloadSegmentGroupLerpMax = 0.7;
    private color payloadSendColor = color(42, 153, 42);
    private color payloadReceiveColor = color(153, 62, 62);
    private color payloadGroupColor = color(20, 41, 83);
    private boolean payloadSizeBasedOnMessageLength = true;

    private boolean enableUniformTime = true;
    private long startTimestamp = 0;
    private float daysPerSecond = 0.1;
    private long deltaTimestamp = 144000; /* (long) (3600 * 24 * 1000 * DAYS_PER_SECOND / DESIRED_FPS) */
    private float autoSkipSeconds = 4.0;
    private long deltaAutoSkipTimestamp = 34560000;
    private long deltaSkipTimestamp = 86400000;
    private int numMsgPerFrame = 1;

    private boolean hideRealNames = false;
    private String hideNameReplacement = "Friend";

    private String[] ignoreList;

    /* Private constructor */
    public FBVisConfig() {

        // Read the configuration file and populate the configurations
        final String[] configLines = loadStrings("config.ini");

        // Create string-dictionary from config file
        StringDict configMapping = generateConfigMapping(configLines);

        // Populate FBVisConfig members using the config mapping
        populateConfig(configMapping);

        // Populate ignore list
        this.ignoreList = loadStrings("ignorelist.txt");
    }

    /* 
     * Private helper function that turns an array of lines read from the config file
     * into a string-string dictionary for further processing
     */
    private StringDict generateConfigMapping(String[] configLines) {
        // Create new dictionary
        StringDict configMapping = new StringDict();

        // Iterate through each line and add setting as mapping
        for (int i = 0 ; i < configLines.length; i++) {
            final String line = configLines[i];
            String[] m = match(line, "([a-zA-Z_]+)=(.*)");

            if (m == null || m.length != 3) {
                continue;
            }

            configMapping.set(m[1].toLowerCase(), m[2]);
        }

        return configMapping;
    }

    /*
     * Private helper method that gets a string-string mapping and sets
     * the corresponding private members
     */
    private void populateConfig(StringDict mapping) {
        this.pathSeparator = File.separator;
        this.dataRootPath = mapping.get("data_root_path").replace("/", this.pathSeparator);
        this.masterName = mapping.get("master_name");
        this.defaultName = mapping.get("facebook_default_name");
        this.enableVerbose = readConfigBoolean(mapping.get("run_verbose"));
        this.enableShaders = readConfigBoolean(mapping.get("run_shaders"));
        this.enableFullscreen = readConfigBoolean(mapping.get("run_fullscreen"));
        this.fps = readConfigInt(mapping.get("run_fps"));
        this.payloadOpacityMin = readConfigInt(mapping.get("payload_opacity_min"));
        this.payloadOpacityMax = readConfigInt(mapping.get("payload_opacity_max"));
        this.payloadSegmentLerpMin = readConfigFloat(mapping.get("payload_segment_lerp_min"));
        this.payloadSegmentLerpMax = readConfigFloat(mapping.get("payload_segment_lerp_max"));
        this.payloadSegmentGroupLerpMin = readConfigFloat(mapping.get("payload_segment_group_lerp_min"));
        this.payloadSegmentGroupLerpMax = readConfigFloat(mapping.get("payload_segment_group_lerp_max"));
        this.payloadSendColor = color(
            readConfigInt(mapping.get("payload_send_color_r")),
            readConfigInt(mapping.get("payload_send_color_b")),
            readConfigInt(mapping.get("payload_send_color_g"))
        );
        this.payloadReceiveColor = color(
            readConfigInt(mapping.get("payload_receive_color_r")),
            readConfigInt(mapping.get("payload_receive_color_g")),
            readConfigInt(mapping.get("payload_receive_color_b"))
        );
        this.payloadGroupColor = color(
            readConfigInt(mapping.get("payload_group_color_r")),
            readConfigInt(mapping.get("payload_group_color_g")),
            readConfigInt(mapping.get("payload_group_color_b"))
        );
        this.payloadSizeBasedOnMessageLength = readConfigBoolean(mapping.get("payload_size_based_on_message_length"));
        this.enableUniformTime = readConfigBoolean(mapping.get("use_uniform_time"));
        this.startTimestamp = (long) readConfigInt(mapping.get("start_time"));
        this.daysPerSecond = readConfigFloat(mapping.get("days_per_second"));
        this.deltaTimestamp = (long) (3600 * 24 * 1000 * this.daysPerSecond / this.fps);
        this.autoSkipSeconds = readConfigFloat(mapping.get("auto_skip_seconds"));
        this.deltaAutoSkipTimestamp = (long) (this.deltaTimestamp * this.autoSkipSeconds * this.fps);
        this.deltaSkipTimestamp = (long) (this.deltaTimestamp * this.fps * 10);
        this.numMsgPerFrame = readConfigInt(mapping.get("num_msgs_per_frame"));
        this.hideRealNames = readConfigBoolean(mapping.get("hide_real_names"));
        this.hideNameReplacement = mapping.get("name_replacement");
    }

    /* Helper function for reading config values */
    private boolean readConfigBoolean(String val) {
        return val.toLowerCase().equals("yes");
    }

    private int readConfigInt(String val) {
        return int(val);
    }

    private float readConfigFloat(String val) {
        return float(val);
    }
}
