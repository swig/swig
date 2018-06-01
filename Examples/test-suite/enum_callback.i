%module enum_callback

%callback("%s_cb") identity_finger;

%inline %{

typedef enum {One, Two, Three, Four, Five} finger;
typedef finger (*finger_finger)(finger);
finger identity_finger(finger f) { return f; }
finger apply_finger_cb(finger f, finger_finger cb) {
    return cb(f);
}

%}
