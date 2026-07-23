%module(directors="1") director_pyobject

%feature("director") Callback;

%inline %{
    struct Callback {
        virtual void callback(PyObject* param1) = 0;
        virtual ~Callback() {}
    };

    void call_callback(Callback *handler, PyObject* param1) {
        handler->callback(param1);
    }
%}
