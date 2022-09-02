(load-extension "null_pointer.so")

(load (build-path (path-only (path->complete-path (find-system-path 'run-file))) "../schemerunme/null_pointer.scm"))
