import preproc_line_file.*;

public class preproc_line_file_runme {

  static {
    try {
        System.loadLibrary("preproc_line_file");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static String FILENAME_WINDOWS = "..\\..\\..\\..\\Examples\\test-suite\\preproc_line_file.i";
  public static String FILENAME_UNIX = "../../../../Examples/test-suite/preproc_line_file.i";
  public static void main(String argv[]) throws Throwable
  {
    int myline = preproc_line_file.MYLINE;
    int myline_adjusted = preproc_line_file.MYLINE_ADJUSTED;
    if (myline != 4)
      throw new RuntimeException("preproc failure");
    if (myline + 100 + 1 != myline_adjusted)
      throw new RuntimeException("preproc failure");

    String myfile = preproc_line_file.MYFILE;
    String myfile_adjusted = preproc_line_file.MYFILE_ADJUSTED;
    if (!(myfile.equals(FILENAME_UNIX) || myfile.equals(FILENAME_WINDOWS)))
      throw new RuntimeException("preproc failure");

    if (!(myfile_adjusted.equals(FILENAME_UNIX + ".bak") || myfile_adjusted.equals(FILENAME_WINDOWS + ".bak")))
      throw new RuntimeException("preproc failure");

    if (!preproc_line_file.MY_STRINGNUM_A.equals("my15"))
      throw new RuntimeException("preproc failed MY_STRINGNUM_A");

    if (!preproc_line_file.MY_STRINGNUM_B.equals("my16"))
      throw new RuntimeException("preproc failed MY_STRINGNUM_B");

    if (preproc_line_file.getThing27() != -1)
      throw new RuntimeException("preproc failure");

    if (preproc_line_file.getThing28() != -2)
      throw new RuntimeException("preproc failure");

    if (preproc_line_file.MYLINE2 != 30)
      throw new RuntimeException("preproc failure");

    if (SillyStruct.LINE_NUMBER != 52)
      throw new RuntimeException("preproc failure");

    if (SillyMacroClass.LINE_NUM != 56)
      throw new RuntimeException("preproc failure");

    if (SillyMultipleMacroStruct.LINE_NUM != 81)
      throw new RuntimeException("preproc failure");

    if (preproc_line_file.INLINE_LINE != 87)
      throw new RuntimeException("preproc failure");

    String inlineFile = preproc_line_file.INLINE_FILE;
    if (!(inlineFile.equals(FILENAME_UNIX) || inlineFile.equals(FILENAME_WINDOWS)))
      throw new RuntimeException("preproc failure");
  }
}
