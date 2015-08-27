import director_string.*


B=@(string) subclass(A(string),'get_first',@director_string_helper_get_first,'process_text',@director_string_helper_process_text);


b = B('hello');

b.get(0);
if (~strcmp(b.get_first(),'hello world!'))
  error(b.get_first())
end

b.call_process_func();

if (~strcmp(b.smem,'hello'))
  error(b.smem)
end

  
