%module li_factory
%include factory.i

%newobject Geometry::create;
%factory(Geometry *Geometry::create, Point, Circle);

%inline {
  struct Geometry {
    enum GeomType{
      POINT,
      CIRCLE
    };
    
    virtual ~Geometry() {}    
    virtual int draw() = 0;
    static Geometry *create(GeomType i);
  };

  struct Point : Geometry  {
    int draw() { return 1; }
    double width() { return 1.0; }    
  };

  struct Circle : Geometry  {
    int draw() { return 2; }
    double radius() { return 1.5; }      
  }; 

  Geometry *Geometry::create(GeomType type) {
    switch (type) {
    case POINT: return new Point();
    case CIRCLE: return new Circle(); 
    default: return 0;
    }
  }
}

