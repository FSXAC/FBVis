/*
 * Singleton class for accessing the configurations which is read from the config file
 * NOTE: since everything inside .pde file is an inner class, we cannot have static classes
 * so instead I trust that future-me will not use multiple instances of this class.
 */
public class FBVisConfig {

    /* Private default settings */
    public String pathSeparator;

    public String dataRootPath;
    public String masterName = "Master name";
    public String defaultName = "Facebook user";
    
    public boolean enableVerbose = false;
    public boolean enableShaders = true;
    public boolean enableFullscreen = false;
    public int fps = 60;

    public int payloadOpacityMin = 50;
    public int payloadOpacityMax = 60;
    public float payloadSegmentLerpMin = 0.3;
    public float payloadSegmentLerpMax = 0.5;
    public float payloadSegmentGroupLerpMin = 0.5;
    public float payloadSegmentGroupLerpMax = 0.7;
    public color payloadSendColor = color(42, 153, 42);
    public color payloadReceiveColor = color(153, 62, 62);
    public color payloadGroupColor = color(20, 41, 83);
    public boolean payloadSizeBasedOnMessageLength = true;

    public boolean enableUniformTime = true;
    public long startTimestamp = 0;
    public float daysPerSecond = 0.1;
    public long deltaTimestamp = 144000; /* (long) (3600 * 24 * 1000 * DAYS_PER_SECOND / DESIRED_FPS) */
    public float autoSkipSeconds = 4.0;
    public long deltaAutoSkipTimestamp = 34560000;
    public long deltaSkipTimestamp = 86400000;
    public int numMsgPerFrame = 1;

    public boolean hideRealNames = false;
    public String hideNameReplacement = "Friend";

    public String[] ignoreList;

    /* Private constructor */
    public FBVisConfig() {

        // Read the configuration file and populate the configurations
        final String[] configLines = loadStrings("data/config.ini");

        // Create string-dictionary from config file
        StringDict configMapping = generateConfigMapping(configLines);

        // Populate FBVisConfig members using the config mapping
        populateConfig(configMapping);

        // Populate ignore list
        this.ignoreList = loadStrings("data/ignorelist.txt");
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
