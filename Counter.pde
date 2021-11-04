/**
 * Static abstract class to implement static counters
 * https://forum.processing.org/two/discussion/20578/static-fields-in-a-class
 */
static abstract class Counter {
    static int count;
    
    @Override String toString() {
        return str(ctr);
    }
}