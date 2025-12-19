%module(directors="1") cpp17_optional
#if defined SWIGCSHARP
//#define SWIG_STD_OPTIONAL_USE_NULLABLE_REFERENCE_TYPES // Enable this to use nullable reference types for optional class types in C# (requires C# 8.0 or later). Not supported by the CI
#define SWIG_STD_OPTIONAL_DEFAULT_TYPES
%include <stdint.i>
%include <std_optional.i>

%optional(test::Struct)
%optional(test::SubStruct)
%optional(test::Point)
%optional(test::Circle)
%optional(test::Rect)

// Enum types with different underlying types
%optional_enum_uint8(test::SmallEnum)
%optional_enum_int64(test::BigEnum)

%feature("director") test::TestObjectDirected;

%inline %{

#include <cstdint>
#include <optional>
#include <string>

struct NoNamespaceStruct
{
    int a;
};
using NoNamespaceStructOptional = std::optional<NoNamespaceStruct>;

namespace test
{
    // Enum types for testing
    enum class SmallEnum : std::uint8_t
    {
        Value1 = 1,
        Value2 = 2,
        Value3 = 255
    };

    enum class BigEnum : std::int64_t
    {
        Small = -1000000000000LL,
        Zero = 0,
        Large = 1000000000000LL
    };

    // Example using simple type (eg. std::uint32_t)
    using SimpleOptional = std::optional<std::uint32_t>;

    // Example using a string
    using StringOptional = std::optional<std::string>;

    // Sub struct to be used for struct test
    struct SubStruct
    {
        std::uint32_t z;
    };
    using SubStructOptional = std::optional<SubStruct>;

    // Example using a struct
    struct Struct
    {
        std::uint32_t a;
        std::uint32_t b;
        SubStructOptional sub;
    };
    using StructOptional = std::optional<Struct>;

    // Define a class that uses all the above types (input and output parameters)
    class TestOptionals
    {
    public:
        TestOptionals() = default;

        SimpleOptional getSimpleOptional() const
        {
            return _simpleOptional;
        }
        void setSimpleOptional(SimpleOptional const value)
        {
            _simpleOptional = value;
        }

        StringOptional getStringOptional() const
        {
            return _stringOptional;
        }
        void setStringOptional(StringOptional const& value)
        {
            _stringOptional = value;
        }

        StructOptional const& getStructOptional() const
        {
            return _structOptional;
        }
        StructOptional getStructOptionalCopy() const
        {
            return _structOptional;
        }
        void setStructOptional(StructOptional const& value)
        {
            _structOptional = value;
        }
        void setStructOptionalCopy(StructOptional const value)
        {
            _structOptional = value;
        }

    private:
        SimpleOptional _simpleOptional {};
        StringOptional _stringOptional {};
        StructOptional _structOptional {};
    };

    // Examples/test-suite/cpp17_optional_primitive_types.i
    class TestObjectPrimitives
    {
    
    public:
        TestObjectPrimitives(bool done, int i, float f, double d)
            : _isDone(done)
            , _numberInt(i)
            , _numberFloat(f)
            , _numberDouble(d)
            , _isDoneOpt(done)
            , _numberIntOpt(i)
            , _numberFloatOpt(f)
            , _numberDoubleOpt(d)
            , _isNullopt(std::nullopt)
        { }
    
        // Bool optional testing
        bool                getBool() const { return _isDone; }
        void                setBool(bool b) { _isDone = b; }
        std::optional<bool> getBoolOpt() const { return _isDoneOpt; }
        void                setBoolOpt(std::optional<bool> b) { _isDoneOpt = b; }
        // Int optional testing
        int                getInt() const { return _numberInt; }
        void               setInt(int i) { _numberInt = i; }
        std::optional<int> getIntOpt() const { return _numberIntOpt; }
        void               setIntOpt(std::optional<int> i) { _numberIntOpt = i; }
        // Float optional testing
        float                getFloat() const { return _numberFloat; }
        void                 setFloat(float f) { _numberFloat = f; }
        std::optional<float> getFloatOpt() const { return _numberFloatOpt; }
        void                 setFloatOpt(std::optional<float> f) { _numberFloatOpt = f; }
        // Double optional testing
        double                getDouble() const { return _numberDouble; }
        void                  setDouble(double d) { _numberDouble = d; }
        std::optional<double> getDoubleOpt() const { return _numberDoubleOpt; }
        void                  setDoubleOpt(std::optional<double> d) { _numberDoubleOpt = d; }
    
        std::optional<bool> getNullopt() const { return _isNullopt; }
    
    private:
        bool   _isDone;
        int    _numberInt;
        float  _numberFloat;
        double _numberDouble;
    
        std::optional<bool>   _isDoneOpt;
        std::optional<int>    _numberIntOpt;
        std::optional<float>  _numberFloatOpt;
        std::optional<double> _numberDoubleOpt;
    
        std::optional<bool> _isNullopt;
    };
    
    // Examples/test-suite/cpp17_optional_std_types.i
    class TestObjectString
    {
    
    public:
        TestObjectString(const std::string& n)
            : _name(n)
            , _nameOpt(n)
        { }
    
        std::string getName() const { return _name; }
        void        setName(std::string s) { _name = s; }
        // optional
        std::optional<std::string> getNameOpt() const { return _nameOpt; }
        void                       setNameOpt(std::optional<std::string> const& s) { _nameOpt = s; }
    
    private:
        std::string                _name;
        std::optional<std::string> _nameOpt;
    };
    
    // Examples/test-suite/cpp17_optional_custom_types.i
    struct Point
    {
        Point(int xx, int yy)
            : x(xx)
            , y(yy)
        { }
    
        Point()
            : Point(0, 0)
        { }
    
        bool isEqual(const Point& other) const
        {
            return (x == other.x && y == other.y);
        }
    
        std::string toString() const
        {
            return "Point(" + std::to_string(x) + ", " + std::to_string(y) + ")";
        }
        int x;
        int y;
    };
    
    struct Circle
    {
        Circle(const Point& p, int r, const std::string& n)
            : center(p)
            , radius(r)
            , name(n)
        { }
        Circle()
            : center(std::nullopt)
            , radius(std::nullopt)
            , name(std::nullopt)
        { }
    
        bool isEqual(const Circle& other) const
        {
            if (center.has_value() && other.center.has_value())
            {
                if (!center.value().isEqual(other.center.value()))
                    return false;
            }
            if (radius.has_value() && other.radius.has_value())
            {
                if (radius.value() != other.radius.value())
                    return false;
            }
            if (name.has_value() && other.name.has_value())
            {
                if (name.value() != other.name.value())
                    return false;
            }
            return true;
        }
    
        std::string toString() const
        {
            std::string cs = center.has_value() ? center.value().toString() : "";
            std::string rs = radius.has_value() ? std::to_string(radius.value()) : "";
            std::string ns = name.has_value() ? name.value() : "";
            return "Circle(" + cs + ", " + rs + ", " + ns + ")";
        }
    
        std::optional<Point>       center;
        std::optional<int>         radius;
        std::optional<std::string> name;
    };
    
    class TestObjectCustom
    {
    
    public:
        TestObjectCustom(const Point& p, const Circle& c)
            : _point(p)
            , _pointOpt(p)
            , _circleOpt(c)
        { }
    
        Point getPoint() const { return _point; }
        void  setPoint(const Point& p) { _point = p; }
        // optional
        std::optional<Point> getPointOpt() const { return _pointOpt; }
        void                 setPointOpt(const std::optional<Point>& p) { _pointOpt = p; }
    
        const std::optional<Circle>& getCircleOpt() const { return _circleOpt; }
        void                         setCircleOpt(const std::optional<Circle>& c) { _circleOpt = c; }
    
    private:
        Point                _point;
        std::optional<Point> _pointOpt;
    
        std::optional<Circle> _circleOpt;
    };
    
    // Examples/test-suite/cpp17_directed_optional_callbacks.i
    class Rect
    {
    public:
        Rect(double w = 1.0, double h = 1.0)
            : width(w)
            , height(h)
        { }
    
        double area() const
        {
            return width * height;
        }
    
        double perimeter() const
        {
            return 2 * (width + height);
        }
    
        std::string toString() const
        {
            return "Rect(" + std::to_string(width) + ", " + std::to_string(height) + ")";
        }
    
        double width;
        double height;
    };

    // Class to test enum optional types
    class TestEnums
    {
    public:
        TestEnums() = default;

        std::optional<SmallEnum> getSmallEnumOpt() const { return _smallEnum; }
        void setSmallEnumOpt(std::optional<SmallEnum> e) { _smallEnum = e; }

        std::optional<BigEnum> getBigEnumOpt() const { return _bigEnum; }
        void setBigEnumOpt(std::optional<BigEnum> e) { _bigEnum = e; }

    private:
        std::optional<SmallEnum> _smallEnum;
        std::optional<BigEnum> _bigEnum;
    };
    
    class TestObjectDirected
    {
    public:
        TestObjectDirected() = default;
        virtual ~TestObjectDirected() = default;
    
        // Director methods for uint32_t optional (by value and by reference)
        virtual std::optional<std::uint32_t> onUint32OptionalChanged(const std::optional<std::uint32_t>& value) const { return std::nullopt; }
    
        std::optional<std::uint32_t> doUint32OptionalChanged(const std::optional<std::uint32_t>& value) const
        {
            return onUint32OptionalChanged(value);
        }
    
        // Director methods for class optional (Rect)
        virtual std::optional<Rect> onRectOptionalChanged(const std::optional<Rect>& value) const { return std::nullopt; }
    
        std::optional<Rect> doRectOptionalChanged(const std::optional<Rect>& value) const
        {
            return onRectOptionalChanged(value);
        }

        // Director methods for string optional
        virtual std::optional<std::string> onStringOptionalChanged(const std::optional<std::string>& value) const { return std::nullopt; }

        std::optional<std::string> doStringOptionalChanged(const std::optional<std::string>& value) const
        {
            return onStringOptionalChanged(value);
        }

        // Director methods for primitive optional (int)
        virtual std::optional<int> onIntOptionalChanged(const std::optional<int>& value) const { return std::nullopt; }

        std::optional<int> doIntOptionalChanged(const std::optional<int>& value) const
        {
            return onIntOptionalChanged(value);
        }

        // Director methods for SmallEnum optional (uint8_t underlying)
        virtual std::optional<SmallEnum> onSmallEnumOptionalChanged(const std::optional<SmallEnum>& value) const { return std::nullopt; }

        std::optional<SmallEnum> doSmallEnumOptionalChanged(const std::optional<SmallEnum>& value) const
        {
            return onSmallEnumOptionalChanged(value);
        }

        // Director methods for BigEnum optional (int64_t underlying)
        virtual std::optional<BigEnum> onBigEnumOptionalChanged(const std::optional<BigEnum>& value) const { return std::nullopt; }

        std::optional<BigEnum> doBigEnumOptionalChanged(const std::optional<BigEnum>& value) const
        {
            return onBigEnumOptionalChanged(value);
        }
    };
} // namespace test

%}

#endif
