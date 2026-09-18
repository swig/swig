/* Simpple test to check is getting/setting class property by value or optional works properly */

%module cpp17_optional_std_types

%include std_optional.i

%inline %{

    #include <optional>

    class TestObject {

    public:

        TestObject(const std::string &n)
        : _name(n)
        , _nameOpt(n) {}

        std::string getName() const { return _name; }
        void setName(std::string s) { _name = s; }
        // optional
        std::optional<std::string> getNameOpt() const { return _nameOpt; }
        void setNameOpt(std::optional<std::string> s) { _nameOpt = s; }
        
    private:

        std::string _name;
        std::optional<std::string> _nameOpt;
    };

%}

