CRUD=*.so *.o php_example.h *_wrap.c* example.php 

all: check

check:
	./BUILD.sh

# This one is fun!  How do we know what shouldn't be there?
clean:
	rm -f $(CRUD)


