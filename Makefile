CC:= clang++
LEX:=flex
YACC:=bison
YFLAGS:=-dtvg 
CFLAGS:=--std=c++14 -g -Wall -Wextra 
CPPFLAGS:=-I.

all: olang.tab 
	git commit -a
	touch hello.ola
	-make hello
	-make sixliner
	-make demos/demo1
	-make demos/demo2

olang.tab: olang.tab.o olang.yy.c 

%.cpp: %.ola olang.tab
	./olang.tab $(OLAFLAGS) <$< >$@

hello.o: hello.cpp olang_header.hpp

%.c: %.tab.c
	mv $^ $@

%.tab.c: %.y
	$(YACC) $(YFLAGS) -o $@ $^

%.yy.c: %.flex
	$(LEX) -o $@ $^ 

%.yy: %.yy.c

%.svg: %.dot
	dot -Tsvg -o $@ $^

%: %.yy
	mv $^ $@

#%.c: %.y
