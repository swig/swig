/* Simpple test to check is getting/setting class property by value or optional works properly */

%module cpp17_optional_primitive_types

%include std_optional.i

%inline %{

    #include <optional>

    class TestObject {

    public:

        TestObject(bool done, int i, float f, double d)
        : _isDone(done)
        , _numberInt(i)
        , _numberFloat(f)
        , _numberDouble(d)
        , _isDoneOpt(done)
        , _numberIntOpt(i)
        , _numberFloatOpt(f)
        , _numberDoubleOpt(d)
        , _isNullopt(std::nullopt) {}

        // Bool optional testing
        bool getBool() const { return _isDone; }
        void setBool(bool b) { _isDone = b; }
        std::optional<bool> getBoolOpt() const { return _isDoneOpt; }
        void setBoolOpt(std::optional<bool> b) { _isDoneOpt = b; }
        // Int optional testing
        int getInt() const { return _numberInt; }
        void setInt(int i) { _numberInt = i; }
        std::optional<int> getIntOpt() const { return _numberIntOpt; }
        void setIntOpt(std::optional<int> i) { _numberIntOpt = i; }
        // Flaot optional testing
        float getFloat() const { return _numberFloat; }
        void setFloat(float f) { _numberFloat = f; }
        std::optional<float> getFloatOpt() const { return _numberFloatOpt; }
        void setFloatOpt(std::optional<float> f) { _numberFloatOpt = f; }
        // Double optional testing
        double getDouble() const { return _numberDouble; }
        void setDouble(double d) { _numberDouble = d; }
        std::optional<double> getDoubleOpt() const { return _numberDoubleOpt; }
        void setDoubleOpt(std::optional<double> d) { _numberDoubleOpt = d; }

        std::optional<bool>  getNullopt() const { return _isNullopt; }

    private:

        bool _isDone;
        int _numberInt;
        float _numberFloat;
        double _numberDouble;

        std::optional<bool> _isDoneOpt;
        std::optional<int> _numberIntOpt;
        std::optional<float> _numberFloatOpt;
        std::optional<double> _numberDoubleOpt;

        std::optional<bool> _isNullopt;
    };

%}

