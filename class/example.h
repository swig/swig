class Circle
{
private:
  int r;
public:
  Circle() {
    r = 0;
    objectCount++;
  }
  Circle(int pr) {
    r = pr;
    objectCount++;
  }
  int area();
  static void info();
  int z;
  static int objectCount;
};

void pnt(Circle *);
