import director_ownership.*;

public class director_ownership_runme {

  static {
    try {
      System.loadLibrary("director_ownership");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void set_content_and_release(Container container, ContentBase content) {
    content.swigReleaseOwnership();
    container.set_content(content);
  }

  public static void main(String argv[]) {

    Container container = new Container();

    // make a content in java (cMemoryOwn true)
    ContentBase content_java = new ContentDerived();

    // make a content in c++ (cMemoryOwn true)
    ContentBase content_cpp = director_ownership.make_content();

    set_content_and_release(container, content_java);
    if (!container.get_content().get_name().equals("ContentDerived"))
      throw new RuntimeException("did not get ContentDerived");

    // when swigReleaseOwnership() is called on content_cpp, swig tries a static_cast to director and calls the method
    // director->swig_java_change_ownership. The content created in c++ native library is not a director, therefore a
    // segfault may occur.
    // With a check done using dynamic_cast this issue could be avoided.
    set_content_and_release(container, content_cpp);
    if (!container.get_content().get_name().equals("ContentDerived"))
      throw new RuntimeException("did not get ContentDerived");
  }
}

