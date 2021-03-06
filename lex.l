%{
#include "y.tab.h"
#include <string.h>

int lineNumber = 2;

%}
digit [0-9]
lower [a-z]
upper [A-Z]
letter [a-zA-Z]
onlineComment "//".*
moreLineComment "/*"
%%
"print"                 { return PRINT;     }
"in"                    { return IN;        }
"false"                 { return FALSE;     }
"true"                  { return TRUE;      }
"end"                   { return END;       }
"case"                  { return CASE;      }
"write"                 { return WRITE;     }
"read"                  { return READ;      }
"return"                { return RETURN;    }
"continue"              { return CONTINUE;  }
"until"                 { return UNTIL;     }
"repeat"                { return REPEAT;    }
"break"                 { return BREAK;     }
"of"                    { return OF;        }
"switch"                { return SWITCH;    }
"else"                  { return ELSE;      }
"then"                  { return THEN;      }
"if"                    { return IF;        }
"while"                 { return WHILE;     }
"do"                    { return DO;        }
"down"                  { return DOWN;      }
"to"                    { return TO;        }
"for"                   { return FOR;       }
"int"                   { return INTEGER;   }
"double"                { return DOUBLE;    }
"char"                  { return CHARACTER; }
"bool"                  { return BOOLEAN;   }
"constant"              { return CONSTANT;  }
["].["]                 { return STRING;    }
['].[']                 { return CHAR;      }
"program"               { return program;   }
[0-9]+                 {yylval.num = atoi(yytext); return IntNumber;}
{letter}({letter}|{digit})*        {yylval.id = strdup(yytext); return ID;}
[ \t]                ;
\n                      { printf("--||-- lineNumber : %d\n", lineNumber++); }
{onlineComment}        ;
{moreLineComment}          {
{int c;
while( ( c = input() ) != EOF ){
if ( c == '\n' ){}
else if ( c == '*' )
{
if ( ( c = input() ) == '/' )
break ;
else
unput(c) ;
}
}
}

}
([-|+]?{digit}+)?"."{digit}+|([-|+]?{digit}+)?"."{digit}+([e|E][-+]?{digit}+) {yylval.doub = atof(yytext); return REALNUM;}
[+]                             {return ADD;}
[-]                             {return SUB;}
[*]                             {return MUL;}
[%]                             {return MOD;} 
"/"                             {return DIVIDE;} 
[=;:{}.,()]                     {return yytext[0];}
"["|"]"                         {return yytext[0];}
"=="                            {return EQUAL;}
".."                            {return DOT;}
"!="                            {return NEQUAL;}
"&&"                            {return AND;}
"||"                            {return OR;}
"<"                             {return LESS;}
">"                             {return GREATER;}
"<="                            {return LESSOREQ;}
">="                            {return GREATEROREQ;}
.                               {;}

%%
int yywrap (void) {return 1;}