CC:= clang++
LEX:=flex
YACC:=bison
YFLAGS:=-dtvg -Wcounterexamples
CFLAGS:=--std=c++14 -g -Wall -Wextra

all: olang.tab 
	git commit -a
	-make hello

olang.tab: olang.tab.o olang.yy.c subject.cpp

%.cpp: %.ola olang.tab
	./olang.tab <$< >$@


hello: hello.cpp olang_header.hpp

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
