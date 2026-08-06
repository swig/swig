%module swift_kept_ref
// Swift-specific test: pin a constructor argument for the wrapping object's
// whole lifetime (ARC), the Swift analogue of the Java javaconstruct /
// C# csconstruct idiom.  Adapter keeps a NON-owning C++ pointer into the Codec
// passed to its constructor, so the Codec's Swift proxy must be retained or ARC
// would free the C++ Codec and leave the pointer dangling.  The swiftcode
// typemap declares the stored property and swiftconstruct assigns it.

%typemap(swiftcode) Adapter %{
    // Pin the codec for the adapter's whole lifetime.
    private var keptCodec: Codec?
%}

%typemap(swiftconstruct) Adapter %{{
        swigCPtr = $imcall
        swigCMemOwn = true
        try swigCheckException()
        keptCodec = codec
    }%}

%inline %{
struct Codec {
  int id;
  Codec(int i) : id(i) { ++live_count(); }
  ~Codec() { --live_count(); }
  // Live-instance counter so the runme can prove the codec stays alive while the
  // adapter pins it (and is freed once the pin is released).
  static int &live_count() { static int n = 0; return n; }
};

struct Adapter {
  Codec *c;                              // non-owning pointer into the codec
  Adapter(Codec &codec) : c(&codec) {}
  int codecId() const { return c->id; }
};

int codec_live_count() { return Codec::live_count(); }
%}
