CC:= clang++
LEX:=flex
YACC:=bison
YFLAGS:=-dtvg -Wcounterexamples
CFLAGS:=--std=c++14

all: olang.tab olang.svg
	git commit -a

olang.tab: olang.tab.o olang.yy.c subject.cpp

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
