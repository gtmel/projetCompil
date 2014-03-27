%{
	#include<stdio.h>
	int yylex();
	void yyerror(char const* s);
	extern FILE *yyin;
%}

%token ASSIGNMENT COLON DIV DO DOT
%token ELSE END EQUAL
%token FUNCTION GE GT IDENTIFIER IF
%token LE LT MINUS MOD NOTEQUAL
%token PBEGIN PLUS
%token PROGRAM PAREND PARENG
%token SEMICOLON DIVQUOT MULTIPLICAT THEN
%token VAR WHILE
%token STRING INTEGER REAL BOOLEAN CHAR

%error-verbose

%%

program : program_tete semicolon block DOT;

program_tete : PROGRAM identifier;

block : declaration_fonction_block
				declaration_variable_block
				section_programme
			;

declaration_variable_block : VAR declaration_variable semicolon;

declaration_variable : identifier COLON data_type;

declaration_fonction_block : FUNCTION identifier parametre_fonction COLON data_type semicolon;

parametre_fonction : PARENG identifier COLON data_type PAREND

section_programme : header_section_programme

header_section_programme : PBEGIN END;



data_type : STRING
					| INTEGER
					| REAL
					| BOOLEAN
					| CHAR
					;

identifier : IDENTIFIER;

semicolon : SEMICOLON;

%%

int main(int argc, char* argv[]){
	FILE *f = NULL;
	if(argc >1) {
		f = fopen(argv[1],"r");
			if(f==NULL){
				return -1;
			}
			yyin=f;
	}
	yyparse();
	if(f!=NULL)
		fclose(f);
}

void yyerror(char const* s){
	fprintf(stderr, "Erreur %s\n", s);
}