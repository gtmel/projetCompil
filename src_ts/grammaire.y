%{
	#include <stdio.h>
	#include <string.h>
	#include "tableSymboles.h"
	#include "tableSymbolesSecondaires.h"
	int yylex();
	void yyerror(char const* s);
	extern FILE *yyin;
	llistTS table_sym = NULL;
	llistSecond table_sym_second = NULL;
%}

%token <t_string> TBEGIN DO DIV TEND FUNCTION PROCEDURE IF MOD PROGRAM THEN ELSE VAR WHILE TO FOR
%token <t_string> INTEGER STRING REAL BOOLEAN CHAR
%token <t_string> ASSIGNATION POINT DEUXPOINTS VIRGULE POINTVIRGULE
%token <t_string> EGAL SUPERIEUREGAL SUPERIEUR INFERIEUREGAL INFERIEUR DIFFERENT
%token <t_string> ADDITION SOUSTRACTION MULTIPLICATION DIVISION
%token <t_string> PARENTHESEGAUCHE PARENTHESEDROITE
%token <t_string> APOSTROPHE
%token <t_string> NOMBRE
%token <t_string> IDENTIFIANT
%token <t_string> READLN WRITELN

%left ADDITION SOUSTRACTION
%left MULTIPLICATION DIVISION
%left INFERIEUR SUPERIEUR
%left EGAL
%right THEN ELSE

%error-verbose

%union {
	int t_int;
	float t_float;
	char * t_string;
}

%type <t_string> programme;
%type <t_string> programme_entete;
%type <t_string> bloc;
%type <t_string> declaration_variable;
%type <t_string> liste_variables;
%type <t_string> declaration_variables;
%type <t_string> liste_identifiants;
%type <t_string> declaration_fonction;
%type <t_string> declaration_procedure;
%type <t_string> liste_fonctions;
%type <t_string> liste_procedures;
%type <t_string> declaration_fonctions;
%type <t_string> declaration_procedures;
%type <t_string> fonction_entete;
%type <t_string> procedure_entete;
%type <t_string> parametres;
%type <t_string> liste_parametres;
%type <t_string> instruction;
%type <t_string> instruction_list;
%type <t_string> declaration;
%type <t_string> declaration_close;
%type <t_string> declaration_ouverte;
%type <t_string> while;
%type <t_string> if;
%type <t_string> for;
%type <t_string> instruction_assignement;
%type <t_string> expressions;
%type <t_string> comparaison;
%type <t_string> expression;
%type <t_string> type_variable;
%type <t_string> writeln;
%type <t_string> readln;
%%


programme:
	programme_entete bloc POINT 
	;

programme_entete:
	PROGRAM IDENTIFIANT POINTVIRGULE { /*table_sym = ajoutSymboleTS(table_sym, $2, "nom programme");*/}
	;

bloc: declaration_variable
	declaration_fonction
	declaration_procedure
	instruction
	;

declaration_variable: VAR liste_variables POINTVIRGULE
	|
	;

liste_variables: liste_variables POINTVIRGULE declaration_variables
	| declaration_variables
	;

declaration_variables: liste_identifiants DEUXPOINTS type_variable { table_sym = ajoutListeSymboleTS(table_sym, $1, $3);}
	;

liste_identifiants: liste_identifiants VIRGULE IDENTIFIANT { $$ = concat_expressionTS($1,$2,$3); }
	| IDENTIFIANT
	;

declaration_fonction: liste_fonctions POINTVIRGULE declaration_variable
	|
	;

declaration_procedure: liste_procedures POINTVIRGULE declaration_variable
	|
	;

liste_fonctions: liste_fonctions POINTVIRGULE declaration_fonctions
	| declaration_fonctions
	;

liste_procedures: liste_procedures POINTVIRGULE declaration_procedures
	| declaration_procedures
	;

declaration_fonctions: fonction_entete bloc {llistTS table_sym_b = NULL;
																						table_sym_second = ajouterEnFinSecondaire(table_sym_second, table_sym_b); /* probleme de copie */
																						afficherListeTS(table_sym);
																						printf("\n");
																						table_sym = table_sym_b;
																						}

	;

declaration_procedures: procedure_entete bloc
	;

fonction_entete: FUNCTION IDENTIFIANT parametres DEUXPOINTS type_variable POINTVIRGULE {
									table_sym = ajoutSymboleTS(table_sym, $2, concat_deux_chainesTS("fonction", $5));
									}
	;

procedure_entete: PROCEDURE IDENTIFIANT parametres POINTVIRGULE { table_sym = ajoutSymboleTS(table_sym, $2, "void");}
	;

parametres: PARENTHESEGAUCHE liste_parametres PARENTHESEDROITE
	;

liste_parametres: liste_parametres VIRGULE declaration_variables
	| declaration_variables
	;

instruction: TBEGIN instruction_list TEND
	;

instruction_list: instruction_list POINTVIRGULE declaration
	| declaration
	;

declaration: declaration_ouverte
	| declaration_close
	;

declaration_close: instruction_assignement
	| instruction
	| 
	;

declaration_ouverte: while 
	| if 
	| for
	| writeln
	| readln
	;

writeln: WRITELN PARENTHESEGAUCHE IDENTIFIANT PARENTHESEGAUCHE IDENTIFIANT PARENTHESEDROITE PARENTHESEDROITE POINTVIRGULE
	;

readln: READLN PARENTHESEGAUCHE IDENTIFIANT PARENTHESEDROITE POINTVIRGULE
	;

while: 	WHILE 
		expressions 
		DO 
		declaration 
	;

if: IF 
	expressions 
	THEN 
	declaration 
	| 
	IF 
	expressions 
	THEN 
	declaration 
	ELSE 
	declaration
	;

for: FOR IDENTIFIANT ASSIGNATION expression TO expression DO declaration
	;

instruction_assignement: IDENTIFIANT ASSIGNATION expression { verificationContexteTS(table_sym, $1);/*vérification de l'identifiant si il est déclaré*/}
	;

expressions: comparaison
	|
	NOMBRE
	;

comparaison: expression INFERIEUREGAL expression
	| 
	expression INFERIEUR expression
	|
	expression EGAL expression
	|
	expression SUPERIEUR expression
	|
	expression SUPERIEUREGAL expression
	;

expression: expression MULTIPLICATION expression
	|
	expression ADDITION expression
	|
	expression SOUSTRACTION expression
	|
	expression DIVISION expression
	|
	PARENTHESEGAUCHE expression PARENTHESEDROITE
	|
	NOMBRE
	|
	IDENTIFIANT { verificationContexteTS(table_sym, $1);/*vérification de l'identifiant si il est déclaré*/}
	;

type_variable : STRING
	| INTEGER
	| REAL
	| BOOLEAN
	| CHAR
	;

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

	afficherListeTS(table_sym);
	// liberationMemoire(table_sym);
	// afficherListeSecondaire(table_sym_second);
}

void yyerror(char const* s){
	fprintf(stderr, "Erreur %s\n", s);
}