/* Simpple test to check is getting/setting class property by value or optional works properly */

%module cpp11_optional_custom_types

%include std_optional.i

%optional(Point)
%optional(Circle)

%inline %{

    #include <optional>

    struct Point {
        Point(int xx, int yy) : x(xx), y(yy) {}
        Point() : Point(0,0) {}
        bool isEqual(const Point &other) const {
            return (x == other.x && y == other.y);
        }
        std::string toString() const {
            return "Point(" + std::to_string(x) + ", " + std::to_string(y) + ")";
        }
        int x;
        int y;
    };

    struct Circle {
        Circle(const Point &p, int r, const std::string &n) 
        : center(p), radius(r), name(n) {}
        Circle() : Circle(Point(), 0, "") {}
        bool isEqual(const Circle &other) const {
            if (center.has_value() && other.center.has_value()) {
                if (!center.value().isEqual(other.center.value())) return false;
            }
            if (radius.has_value() && other.radius.has_value()) {
                if (radius.value() != other.radius.value()) return false;
            }
            if (name.has_value() && other.name.has_value()) {
                if (name.value() != other.name.value()) return false;
            }
            return true;
        }
        std::string toString() const {
            std::string cs = center.has_value() ? center.value().toString() : "";
            std::string rs = radius.has_value() ? std::to_string(radius.value()) : "";
            std::string ns = name.has_value() ? name.value() : "";
            return "Circle(" + cs + ", " + rs + ", " + ns + ")";
        }
        std::optional<Point> center;
        std::optional<int> radius;
        std::optional<std::string> name;
    };

    class TestObject {

    public:

        TestObject(const Point &p, const Circle &c)
        : _point(p)
        , _pointOpt(p)
        , _circleOpt(c) {}

        Point getPoint() const { return _point; }
        void setPoint(const Point &p) { _point = p; }
        // optional
        std::optional<Point> getPointOpt() const { return _pointOpt; }
        void setPointOpt(const std::optional<Point> &p) { _pointOpt = p; }

        const std::optional<Circle> &getCircleOpt() const { return _circleOpt; }
        void setCircleOpt(const std::optional<Circle> &c) { _circleOpt = c; }
        
    private:

        Point _point;
        std::optional<Point> _pointOpt;
        
        std::optional<Circle> _circleOpt;
    };

%}
