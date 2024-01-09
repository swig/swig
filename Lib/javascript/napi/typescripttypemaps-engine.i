// Node-API specific TypeScript typemaps

%typemap(ts)    (const void *buffer_data, const size_t buffer_len)  "Buffer";
%typemap(tsout) (void **buffer_data, size_t *buffer_len)            "Buffer";

%typemap(ts)    (const void *arraybuffer_data, const size_t arraybuffer_len)  "ArrayBuffer";
%typemap(tsout) (void **arraybuffer_data, size_t *arraybuffer_len)            "ArrayBuffer";
