%module rename_pcre_encoder

// strip the wx prefix from all identifiers except those starting with wxEVT
%rename("%(regex:/wx(?!EVT)(.*)/\\1/)s") "";

%inline %{

class wxSomeWidget {
};

struct wxAnotherWidget {
    void wxDoSomething() {}
};

class wxEVTSomeEvent {
};

class xUnchangedName {
};

%}
