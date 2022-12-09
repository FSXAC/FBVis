import java.util.Arrays;
import java.util.Comparator;

String pathJoin(String a, String b) {
    return a + CONFIG.pathSeparator + b;
}

String pathJoin(String a, String b, String c) {
    return pathJoin(a, b) + CONFIG.pathSeparator + c;
}

StringList listFileNames(String dir) throws NotDirectoryException {
    File file = new File(dir);
    StringList filenames = new StringList();
    if (file.isDirectory()) {
        String names[] = file.list();
        for (String n : names) {
            filenames.append(n);
        }
    } else {
        throw new NotDirectoryException("");
    }
    
    return filenames;
}


int extractNumber(String s, char startToken, char endToken) {
    int i = 0;
    try {
        int start = s.indexOf(startToken) + 1;
        int end = s.lastIndexOf(endToken);
        String number = s.substring(start, end);
        i = Integer.parseInt(number);
    } catch (Exception e) {
        i = 0;
    }

    return i;
}

StringList listFileNames(String dir, String extention) throws NotDirectoryException {
    StringList allfiles = listFileNames(dir);
    StringList files = new StringList();

    for (String f : allfiles) {
        if (f.endsWith(extention)) {
            files.append(f);
        }
    }
    
    return files;
}

String[] sortFilenamesNumerically(StringList files) {
    String[] sorted = new String[files.size()];
    for (String f : files) {
        int index = extractNumber(f, '_', '.') - 1;
        sorted[index] = f;
    }

    return sorted;
}
