bison -y -t "bas.y" -d
flex bas.l
gcc y.tab.c lex.yy.c 
a.exe test.txt
pause 

