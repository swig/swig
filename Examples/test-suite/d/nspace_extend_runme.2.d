module nspace_extend_runme;

static import oi1c = nspace_extend.Outer.Inner1.Color;
static import oi2c = nspace_extend.Outer.Inner2.Color;

void main() {
  {
    // constructors and destructors
    scope color1 = new oi1c.Color();
    scope color = new oi1c.Color(color1);

    // class methods
    color.colorInstanceMethod(20.0);
    oi1c.Color.colorStaticMethod(20.0);
    auto created = oi1c.Color.create();
  }
  {
    // constructors and destructors
    scope color2 = new oi2c.Color();
    scope color = new oi2c.Color(color2);

    // class methods
    color.colorInstanceMethod(20.0);
    oi2c.Color.colorStaticMethod(20.0);
    auto created = oi2c.Color.create();

    // Same class different namespaces
    auto col1 = new oi1c.Color();
    auto col2 = oi2c.Color.create();
    col2.colors(col1, col1, col2, col2, col2);
  }
}
