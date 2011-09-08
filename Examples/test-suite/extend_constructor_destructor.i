%module extend_constructor_destructor

%inline %{
int global = 0;

namespace Space {
  typedef struct tagAStruct {
    int ivar;
  } AStruct;

  struct BStruct {
    int ivar;
  };

  typedef struct tagCStruct {
    int ivar;
  } CStruct;

  // Unnamed struct
  typedef struct {
    int ivar;
  } DStruct;
}

typedef struct tagEStruct {
  int ivar;
} EStruct;

%}

%extend Junk {
void thingy() {}
}
%inline %{
struct Junk {};
%}
namespace Space {

%extend tagAStruct {
  tagAStruct(int ivar0) {
    Space::AStruct *s = new Space::AStruct();
    s->ivar = ivar0;
    global = ivar0;
    return s;
  }
  ~tagAStruct() {
    global = -$self->ivar;
    delete $self;
  }
}

%extend BStruct {
  BStruct(int ivar0) {
    Space::BStruct *s = new Space::BStruct();
    s->ivar = ivar0;
    global = ivar0;
    return s;
  }
  ~BStruct() {
    global = -$self->ivar;
    delete $self;
  }
}

%extend CStruct {
  CStruct(int ivar0) {
    Space::CStruct *s = new Space::CStruct();
    s->ivar = ivar0;
    global = ivar0;
    return s;
  }
  ~CStruct() {
    global = -$self->ivar;
    delete $self;
  }
}

%extend DStruct {
  DStruct(int ivar0) {
    Space::DStruct *s = new Space::DStruct();
    s->ivar = ivar0;
    global = ivar0;
    return s;
  }
  ~DStruct() {
    global = -$self->ivar;
    delete $self;
  }
}

}

%extend EStruct {
  EStruct(int ivar0) {
    EStruct *s = new EStruct();
    s->ivar = ivar0;
    global = ivar0;
    return s;
  }
  ~EStruct() {
    global = -$self->ivar;
    delete $self;
  }
}

