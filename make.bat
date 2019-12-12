bison -d project.y
flex project.l
g++ lex.yy.c project.tab.c -o project


project