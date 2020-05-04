## How to Run

First you need to have [Bison](http://gnuwin32.sourceforge.net/packages/bison.htm) and [Felx](http://gnuwin32.sourceforge.net/packages/flex.htm) installed. 
<br/>
Then proceed to run the Command.bat file found in the Code folder.


## Test Cases

The test cases folder contains examples of accepted and erroneous code.
<br/>
To try a specific test case copy it's contents to the test.txt file in the Code folder. 


## Understanding the Output

For each statement, a quadruple is built and presented as Assembly code. Also the Symbol table is print out to track variables in the system and perform needed semantic checks.

## Examples of covered statements

```C
int x;
int i=5;
float f=2.3;
string s= "hi there!";
char c= 'm';
a=b+c;
a=b-c;
a=b+5;
a=1+2;
// comments too!
```