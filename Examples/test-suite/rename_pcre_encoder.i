%module rename_pcre_encoder

// strip the wx prefix from all identifiers except those starting with wxEVT
%rename("%(regex:/wx(?!EVT)(.*)/\\1/)s") "";

// Replace "Set" and "Get" prefixes with "put" and "get" respectively.
%rename("%(regex:/^Set(.*)/put\\1/)s", %$isfunction) "";
%rename("%(regex:/^Get(.*)/get\\1/)s", %$isfunction) "";

%inline %{

struct wxSomeWidget {
    void SetBorderWidth(int width) { m_width = width; }
    int GetBorderWidth() const { return m_width; }

    void SetSize(int, int) {}

    int m_width;
};

struct wxAnotherWidget {
    void DoSomething() {}
};

class wxEVTSomeEvent {
};

class xUnchangedName {
};

%}
