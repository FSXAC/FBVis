import java.util.Arrays;
import java.util.Comparator;

/**
 * Joins two paths together
 * @param a the first part of the path
 * @param b the second part of the path
 * @return a + b
 */
String pathJoin(String a, String b) {
    return a + File.separator + b;
}

/**
 * Joins two paths together
 * @param a the first part of the path
 * @param b the second part of the path
 * @param c the third part of the path
 * @return a + b + c
 */
String pathJoin(String a, String b, String c) {
    return pathJoin(pathJoin(a, b), c);
}

/**
 * Gets a list of file names that are in a given directory
 * @param dir the path to directory
 * @return a StringList of files in that directory (un-joined)
 */
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

/**
 * Gets a list of file names that are in a given directory,
 * only if such file names have a given extension
 * @param dir the path to directory
 * @param extension the extension to match for
 * @return a StringList of files in that directory that have
 * the specified extension
 */
StringList listFileNames(String dir, String extention) throws NotDirectoryException {
    final StringList allfiles = listFileNames(dir);
    StringList filenames = new StringList();

    for (String f : allfiles) {
        if (f.endsWith(extention)) {
            filenames.append(f);
        }
    }
    
    return filenames;
}

/**
 * Extracts an integer from a string given a start and end token/character
 * @param s the string to interpret
 * @param startToken the starting character in front of the number
 * @param endToken the ending character behind the number
 * @return an integer extracted from s; returns 0 if one cannot be found
 */
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

/**
 * Given a list of files, sort it numerically based on the number
 * @param files a StringList of file names
 * @return an array of strings where it's sorted based on extracted number
 */
String[] sortFilenamesNumerically(StringList files) {
    String[] sorted = new String[files.size()];
    for (String f : files) {
        int index = extractNumber(f, '_', '.') - 1;
        sorted[index] = f;
    }

    return sorted;
}
