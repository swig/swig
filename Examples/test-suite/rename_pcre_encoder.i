%module rename_pcre_encoder

// strip the wx prefix from all identifiers except those starting with wxEVT
%rename("%(regex:/wx(?!EVT)(.*)/\\1/)s") "";

// Replace "Set" prefix with "put" in all functions
%rename("%(regex:/^Set(.*)/put\\1/)s", %$isfunction) "";

%inline %{

struct wxSomeWidget {
    void SetBorderWidth(int);
    void SetSize(int, int);
};

struct wxAnotherWidget {
    void wxDoSomething() {}
};

class wxEVTSomeEvent {
};

class xUnchangedName {
};

%}
