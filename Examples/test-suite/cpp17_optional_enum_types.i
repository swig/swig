/* Simpple test to check is getting/setting class property by value or optional works properly */

%module cpp17_optional_enum_types

%include std_optional.i

%optional_enum(OptionalEnumTest);

%inline %{

    #include <optional>

    enum class OptionalEnumTest : int64_t {
        A, B, C
    };

    enum class NonOptionalEnumTest : int64_t {
        D, E, F
    };

    class TestObject {

    public:

        TestObject(std::optional<OptionalEnumTest> enumOpt,
                   NonOptionalEnumTest e)
        : _enumOpt(enumOpt)
        , _enum(e) {}

        NonOptionalEnumTest getNonOptionalEnum() const { return _enum; }
        void setNonOptionalEnum(NonOptionalEnumTest e) { _enum = e; }
        // optional
        std::optional<OptionalEnumTest> getOptionalEnum() const { return _enumOpt; }
        void setOptionalEnum(std::optional<OptionalEnumTest> e) { _enumOpt = e; }
        
    private:

        std::optional<OptionalEnumTest> _enumOpt;
        NonOptionalEnumTest _enum;
    };

%}

