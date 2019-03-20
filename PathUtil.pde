String pathJoin(String a, String b) {
    return a + PATH_SEPARATOR + b;
}

String pathJoins(String[] segments) {
    String output = "";
    for (int i = 0; i < segments.length; i++) {
        if (i != 0) {
            output += PATH_SEPARATOR;
        }
        output += segments[i];
    }
    
    return output;
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}