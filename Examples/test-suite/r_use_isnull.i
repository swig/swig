%module r_use_isnull

%inline %{
// C++ code
class circle {
public:
circle(double radius)
{
m_radius = radius;
}
double getArea() const
{
return (3.14 * m_radius * m_radius);
}

private:
double m_radius;
};

class pointerTest {
public:
pointerTest() : m_circle(2) {}
const circle * getCircle(int index) const {
if (index == 0)
return & m_circle;
else
return 0;
}

private:
    circle m_circle;

};
 %}
