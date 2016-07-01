class Circle
{
private:
    int r;
public:
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
