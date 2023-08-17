%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace
%code requires{
   #include "ast.hh"
   #include "symtab.hh"
   #include "type.hh"
   #include "location.hh"
     namespace IPL {
     class Scanner;
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } PTR_OP


%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   #include <string>
   
   
   #include "scanner.hh"
   using namespace std;
   string curr_func = "";
   string curr_struct = "";
   SymbTab *curr_symbtab = new SymbTab();
   typeSymbTab *typecurr_symbtab = new typeSymbTab();
   map<string, datatype*> variable_dtypes;
   map<string, datatype*> fun_return_types;
   map<string,map<string,datatype*>> variable_info;
   extern SymbTab gst;
   typeSymbTab table;
   map<string,abstract_astnode*> ast;

#undef yylex
#define yylex IPL::Parser::scanner.yylex

}




%define api.value.type variant
%define parse.assert

%start translation_unit


%token '\n'
%token <std::string> STRUCT OTHERS
%token <std::string> INT_CONSTANT
%token <std::string> FLOAT_CONSTANT
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> WHILE
%token <std::string> FOR
%token <std::string> VOID
%token <std::string> INT
%token <std::string> FLOAT
%token <std::string> RETURN
%token <std::string> STRING_LITERAL
%token <std::string> IDENTIFIER
%token <std::string> OR_OP
%token <std::string> AND_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> INC_OP
%token <std::string> PTR_OP
%token '{' '}' '[' ']' '(' ')' ',' ';' '*' '=' '!' '&' '<' '>' '+' '-' '/' '.' 



%left OR_OP
%left AND_OP
%left EQ_OP NE_OP 
%left '<' LE_OP
%left '>' GE_OP
%left '+' '-'
%left '*' '/'

%right '&'
%right USTAR
%right UMINUS

%left PTR_OP
%left '.'
%left INC_OP


%nterm <abstract_astnode*> translation_unit 
%nterm <abstract_astnode*> struct_specifier 
%nterm <abstract_astnode*> function_definition

%nterm <std::string> type_specifier 
%nterm <declarator_class*> declarator_arr 
%nterm <declarator_class*> declarator 
%nterm <declaration_class*> declaration 
%nterm <declarator_list_class*> declarator_list
%nterm <declaration_list_class*> declaration_list 

%nterm <exp_astnode*> expression 
%nterm <fun_declarator_class*> fun_declarator
%nterm <parameter_list_class*> parameter_list 
%nterm <parameter_declaration_class*> parameter_declaration 
%nterm <statement_astnode*> statement 
%nterm <assignS_astnode*> assignment_statement

%nterm <seq_astnode*> compound_statement
%nterm <seq_astnode*> statement_list 
%nterm <assignE_astnode*> assignment_expression 


%nterm <exp_astnode*> logical_and_expression 
%nterm <exp_astnode*> equality_expression 
%nterm <exp_astnode*> relational_expression
%nterm <exp_astnode*> additive_expression 
%nterm <exp_astnode*> unary_expression 
%nterm <exp_astnode*> multiplicative_expression 
%nterm <exp_astnode*> postfix_expression
%nterm <exp_astnode*> primary_expression 
%nterm <funcall_astnode*> expression_list 
%nterm <proccall_astnode*> procedure_call
%nterm <std::string> unary_operator 
%nterm <statement_astnode*> selection_statement 
%nterm <statement_astnode*> iteration_statement


%%
translation_unit: 
     struct_specifier
     {

     }
     | function_definition
     {

     }          
     | translation_unit struct_specifier
     {

     }
     | translation_unit function_definition
     {
          
     }
     ;

struct_specifier:
      STRUCT IDENTIFIER
     {
          curr_func = "";
          curr_struct = "struct " + $2;
     }
      '{' declaration_list '}' ';'
     { 
          
          int off =0;
          for(auto j: $5->dection_list){
               for(auto i: j->dec_list->dector_list){
                    string name = i->dector_str;
                    string type = i->getType(j->dec_type);
                    int size = i->getSize(j->dec_type,table);
                    curr_symbtab->Entries[name] = new Symbol(name,"var","local",type,size,off,nullptr);
                    typecurr_symbtab->Entries[name] = new typeSymbol(name,"var","local",type,size,off,nullptr);
                    off += size;
               }
          }
          gst.Entries[curr_struct] = new Symbol(curr_struct,"struct","global","-",off,0,curr_symbtab);
          table.Entries[curr_struct] = new typeSymbol(curr_struct,"struct","global","-",off,0,typecurr_symbtab);
          curr_struct = "";
          curr_symbtab = new SymbTab();
          typecurr_symbtab = new typeSymbTab();
     }
     ;

function_definition:
      type_specifier fun_declarator
      {
          curr_func = $2->fun_id;
          curr_struct = "";
          fun_return_types[curr_func] = new datatype($1);
          
      } 
      compound_statement
     {
          ast[curr_func] = $4;
          gst.Entries[curr_func] = new Symbol(curr_func,"fun","global",$1,0,0,curr_symbtab);
          table.Entries[curr_func] = new typeSymbol(curr_func,"fun","global",$1,0,0,typecurr_symbtab);
          //string ret_name = $4->seqvec[$4->seqvec.size()-1]->id_name;
          //int ret_type = $4->seqvec[$4->seqvec.size()-1]->type;

         // cout << gst.Entries[curr_func]->symbtab->Entries[ret_name]->type << endl;
         //cout<<ret_name<<" "<<ret_type<<endl;

         // gst.Entries[curr_func]->symbtab->print();
          curr_func = "";
          curr_symbtab = new SymbTab();
          typecurr_symbtab = new typeSymbTab();
          variable_dtypes.clear();
          
     }
     ;

type_specifier:
      VOID
     {
          $$ = "void";
     }
     | INT
     {
          $$ = "int";
     }
     | FLOAT
     {
          $$ = "float";
     }
     | STRUCT IDENTIFIER
     {
          $$ = "struct " + $2;
     }
     ;

fun_declarator:
      IDENTIFIER '(' parameter_list ')'
     {
        $$ = new fun_declarator_class($1,$3);
        int off =12;
          if($3->par_list.size() != 0){
               for( int i=$3->par_list.size()-1;i>=0;i--){
                    string name = $3->par_list[i]->par_dector->dector_str;
                    string type = $3->par_list[i]->par_dector->getType($3->par_list[i]->par_type);
                    int size = $3->par_list[i]->par_dector->getSize($3->par_list[i]->par_type,table);
                    curr_symbtab->Entries[name] = new Symbol(name,"var","param",type,size,off,nullptr);
                    typecurr_symbtab->Entries[name] = new typeSymbol(name,"var","param",type,size,off,nullptr);
                    off += size;
               }
          }

     }
     | IDENTIFIER '(' ')'
     {
          $$ = new fun_declarator_class($1);

     }
     ;

parameter_list:
      parameter_declaration
     {
          $$ = new parameter_list_class();
          $$->par_list.push_back($1);
     }
     | parameter_list ',' parameter_declaration
     {
          $$ = $1;
          $$->par_list.push_back($3);
     }
     ;
parameter_declaration:
      type_specifier declarator
     {
          if($1 == "void" && $2->star == 0){
                   error(@$,"Cannot declare variable of type void");
               }
          variable_dtypes[$2->dector_str] = new datatype($1, $2->star, $2->dector_array);
          $$ = new parameter_declaration_class($1,$2);
     }
     ;

declarator_arr:
      IDENTIFIER
     {
          $$ = new declarator_class($1);
     }
     | declarator_arr '[' INT_CONSTANT ']'
     {
          $$ = $1;
          $$->dector_array.push_back(stoi($3));
     }
     ;
declarator:
      declarator_arr
     {
         $$ = $1;
     }
     | '*' declarator
     {
          $$ = $2;
          $$->star += 1;
     }
     ;

compound_statement:
      '{' '}'
     {
          vector<statement_astnode*> seqvec;
          seq_astnode* new_seq = new seq_astnode(seqvec);
          $$ = new_seq ;
         
          
     }
     | '{' declaration_list '}'
     {
          vector<statement_astnode*> seqvec;
          $$ = new seq_astnode(seqvec);
          int off =0;
          for(auto j: $2->dection_list){
               for(auto i: j->dec_list->dector_list){
                    string name = i->dector_str;
                    string type = i->getType(j->dec_type);
                    int size = i->getSize(j->dec_type,table);
                    off -= size;
                    curr_symbtab->Entries[name] = new Symbol(name,"var","local",type,size,off,nullptr);
                    typecurr_symbtab->Entries[name] = new typeSymbol(name,"var","local",type,size,off,nullptr);
               }
          }

     }
     | '{' statement_list '}'
     {
         $$ = $2;
     }
     | '{' declaration_list statement_list '}'
     {
          $$ = $3;
          int off =0;
          for(auto j: $2->dection_list){
               for(auto i: j->dec_list->dector_list){
                    string name = i->dector_str;
                    string type = i->getType(j->dec_type);
                    int size = i->getSize(j->dec_type,table);
                    off -= size;
                    curr_symbtab->Entries[name] = new Symbol(name,"var","local",type,size,off,nullptr);
                    typecurr_symbtab->Entries[name] = new typeSymbol(name,"var","local",type,size,off,nullptr);
               }
          }

     }
     ;

statement_list:
      statement
     {
          vector<statement_astnode*> seqvec;
          $$ = new seq_astnode(seqvec);
          $$->seqvec.push_back($1);
     }
     | statement_list statement
     {
         $$ = $1;
         $$->seqvec.push_back($2);
     }
     ;

statement:
      ';'
     {
         $$ = new empty_astnode();
     }
     | '{' statement_list '}'
     {
         $$ = $2;
     }
     | selection_statement
     {
         $$ = $1;
     }
     | iteration_statement
     {
        $$ = $1;
     }
     | assignment_statement
     {
         $$ = $1;
     }
     | procedure_call
     {
         $$ = $1;
     }
     | RETURN expression ';'
     {
          if(fun_return_types[curr_func]->isint() && $2->dtype->isfloat()){
               $$ = new return_astnode(new op_unary_astnode("TO_INT",$2));
          }else if(fun_return_types[curr_func]->isfloat() && $2->dtype->isint()){
               $$ = new return_astnode(new op_unary_astnode("TO_FLOAT",$2));
          }else{
               $$ = new return_astnode($2);
               $$->type = $2->type;
               $$->id_name = $2->id_name;
          }
     }
     ;

assignment_expression:
      unary_expression '=' expression
     {    
          if($1->dtype->ptr_count >0 && $1->dtype->dims.size() ==0 && $3->dtype->isint() && !($3->dtype->zero)){
               error(@$,"Cannot assign non zero int to a pointer");
          }
          

          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new assignE_astnode( $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               exp_astnode* exp = new op_unary_astnode("TO_INT", $3);
               $$ = new assignE_astnode( $1, exp);
               $$->dtype = new datatype("int");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {

               exp_astnode* exp = new op_unary_astnode("TO_FLOAT", $3);
               $$ = new assignE_astnode( $1, exp);
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new assignE_astnode( $1, $3);
               $$->dtype = new datatype("float");
          }
          else {
               $$ = new assignE_astnode($1,$3);
               $$->dtype = $1->dtype;
          }


          
     }
     ;

assignment_statement:
      assignment_expression ';'
     {
         $$ = new assignS_astnode($1->aE_exp1,$1->aE_exp2);
     }
     ;

procedure_call:
      IDENTIFIER '(' ')' ';'
     {
          $$ = new proccall_astnode($1);
     }
     | IDENTIFIER '(' expression_list ')' ';'
     {

        
         $$ = new proccall_astnode($1,$3->funcvec);
     }
     ;

expression:
      logical_and_expression
     {
         $$ = $1;
     }
     | expression OR_OP logical_and_expression
     {
          $$ = new op_binary_astnode("OR_OP",$1,$3);
     }
     ;

logical_and_expression: 
     equality_expression
     {
         $$ = $1;
     }
     | logical_and_expression AND_OP equality_expression
     {
          $$ = new op_binary_astnode("AND_OP",$1,$3);
     }
     ;

equality_expression: 
     relational_expression
     {
          $$ = $1;    
     }
     | equality_expression EQ_OP relational_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("EQ_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("EQ_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("EQ_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("EQ_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
          }
     }
     | equality_expression NE_OP relational_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("NE_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("NE_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("NE_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("NE_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
          }
     }
     ;

relational_expression:
      additive_expression
     {
         $$ = $1;
     }
     | relational_expression '<' additive_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("LT_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("LT_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("LT_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("LT_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("LT_OP_INT",$1,$3);
          }
     }
     | relational_expression '>' additive_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("GT_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("GT_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("GT_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("GT_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("GT_OP_INT",$1,$3);
          }
     }
     | relational_expression LE_OP additive_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("LE_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("LE_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("LE_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("LE_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("LE_OP_INT",$1,$3);
          }    
     }
     | relational_expression GE_OP additive_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("GE_OP_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("GE_OP_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("GE_OP_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("GE_OP_FLOAT", $1, $3);
          }
          else {
               $$ = new op_binary_astnode("GE_OP_INT",$1,$3);
          }
     }
     ;

additive_expression: 
     multiplicative_expression
     {
         $$ = $1;
     }
     | additive_expression '+' multiplicative_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("PLUS_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("PLUS_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("PLUS_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("PLUS_FLOAT", $1, $3);
               $$->dtype = new datatype("float");
          }
          else if($1->dtype->ptr_count+$1->dtype->dims.size() >0 && $3->dtype->isint()){
                 $$ = new op_binary_astnode("PLUS_INT",$1,$3);
                 $$->dtype = $1->dtype;
          }
          else if($3->dtype->ptr_count+$3->dtype->dims.size() >0 && $1->dtype->isint()){
                 $$ = new op_binary_astnode("PLUS_INT",$1,$3);
                 $$->dtype = $3->dtype;
          }
          else {
               error(@$,"invalid operands to binary +" );
          }
     }
     | additive_expression '-' multiplicative_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("MINUS_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("MINUS_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("MINUS_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("MINUS_FLOAT", $1, $3);
               $$->dtype = new datatype("float");
          }
          else {
               $$ = new op_binary_astnode("MINUS_INT",$1,$3);
          }
     }
     ;

unary_expression: 
     postfix_expression
     {
         $$ = $1;
     }
     | unary_operator unary_expression
     {
          $$ = new op_unary_astnode($1,$2);
          if($1 =="UMINUS"){
               if (!($2->dtype->isint() || $2->dtype->isfloat())) {
                    error(@$, "Incorrect operand to unary -");
               }
               $$->dtype = $2->dtype;
          }else if($1 == "NOT"){
               $$->dtype = new datatype("int");
          }else if($1 == "DEREF"){
               if($2->dtype->ptr_count + $2->dtype->dims.size() == 0){
                    error(@$,"Invalid operand to *");
               }
               // Adding new code
              vector<int> dims_new = $2->dtype->dims;
              int ptr_count_new  = $2->dtype->ptr_count;
              if (dims_new.size() > 0) {
                dims_new.erase(dims_new.begin());
                }
               else {
                ptr_count_new--;
               }
               $$->dtype = new datatype($2->dtype->btype, ptr_count_new, dims_new);
               // Added new code
               }
          else if ($1 == "ADDRESS") {
               vector<int> dim_vec;
               dim_vec.push_back(1);
               for (auto it : $2->dtype->dims) {
                    dim_vec.push_back(it);
               }
               $$->dtype = new datatype($2->dtype->btype, $2->dtype->ptr_count, dim_vec);
          }
     }
     ;

multiplicative_expression:
      unary_expression
     {
          $$ = $1;
     }
     | multiplicative_expression '*' unary_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("MULT_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("MULT_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
               $$->dtype = new datatype("float");
          }
          else  if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("MULT_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
               $$->dtype = new datatype("float");
          }
          else  if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("MULT_FLOAT", $1, $3);
               $$->dtype = new datatype("float");
          }
          else {
               $$ = new op_binary_astnode("MULT_INT",$1,$3);
          }
     }
     | multiplicative_expression '/' unary_expression
     {
          if ($1->dtype->isint() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("DIV_INT", $1, $3);
          }
          else if ($1->dtype->isint() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("DIV_FLOAT", new op_unary_astnode("TO_FLOAT", $1), $3);
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isint()) {
               $$ = new op_binary_astnode("DIV_FLOAT", $1, new op_unary_astnode("TO_FLOAT", $3));
               $$->dtype = new datatype("float");
          }
          else if ($1->dtype->isfloat() && $3->dtype->isfloat()) {
               $$ = new op_binary_astnode("DIV_FLOAT", $1, $3);
               $$->dtype = new datatype("float");
          }
          else {
               $$ = new op_binary_astnode("DIV_INT",$1,$3);
          }
     }
     ;

// need to get those func types from global symbol table;
postfix_expression: 
     primary_expression
     {
         $$ = $1;
         //cout << $$->id_name << endl;
     }
     | postfix_expression '[' expression ']'
     {
          // Adding code   
          $$ = new arrayref_astnode($1,$3);       
          if($1->dtype->ptr_count + $1->dtype->dims.size() == 0){
               error(@$,"Subscripted value is not a pointer");
          }
          if ($3->dtype->isint() == 0) {
               error(@$, "Array subscript is not an integer");
          }
          vector<int> dims_new = $1->dtype->dims;
          int ptr_count_new  = $1->dtype->ptr_count;
          if (dims_new.size() > 0) {
               dims_new.erase(dims_new.begin());
          }
          else {
               ptr_count_new--;
          }
          $$->dtype = new datatype($1->dtype->btype, ptr_count_new, dims_new);
          // Added code
     }
     | IDENTIFIER '(' ')'
     {
         $$ = new funcall_astnode($1);
         $$->dtype = fun_return_types[$1];
     }
     | IDENTIFIER '(' expression_list ')'
     {
        /////////////////////////////////////////////////////////////////////////////////////////////////////
         map<int,Symbol*> temp = gst.Entries[$1]->symbtab->cus_sort();

         vector<Symbol*> temp2;

         for(auto it = temp.begin(); it != temp.end(); it++){    
              temp2.push_back(it->second);
         }

         reverse(temp2.begin(),temp2.end());
         vector<datatype> vec;

         for(size_t i = 0; i< temp2.size(); i++){
              datatype d("int");
              d.set(temp2[i]->type);
              vec.push_back(d);
         }

          vector<exp_astnode*> rexp = $3->funcvec;
          vector<exp_astnode*> exp_list = $3->funcvec;
          if(exp_list.size() != vec.size()){
               error(@$ , "not a matching number of parameters");
          }

          for(int i=0; i<vec.size(); i++){
               if(exp_list[i]->dtype->dims.size()>0){
                    exp_list[i]->dtype->dims.erase(exp_list[i]->dtype->dims.begin());
                    exp_list[i]->dtype->ptr_count++;
               }

               if(vec[i].dims.size()>0){
                    vec[i].dims.erase(vec[i].dims.begin());
                    vec[i].ptr_count++;
               }

               if(vec[i].stringtype() == exp_list[i]->dtype->stringtype()){
                    
               }
          
                  
                    else{
                     error(@$ , "cannot cast " +vec[i].stringtype() + " to " + exp_list[i]->dtype->stringtype() );
                    }
               
          }

         $$ = new funcall_astnode($1, rexp);
         $$->dtype = fun_return_types[$1];

     }
     | postfix_expression '.' IDENTIFIER
     {
          //Adding
          if(!($1->dtype->ptr_count ==0 && $1->dtype->dims.size() == 0 && $1->dtype->btype.substr(0,6)=="struct")){
              error(@$,"Subscripted value is not struct");
          }
          //cout<<$3<<endl;
          if(gst.Entries[$1->dtype->btype]->symbtab->Entries.count($3) ==0){
               error(@$,"variable not a member of struct");
          }
          //added
          $$ = new member_astnode($1,new identifier_astnode($3));
          $$->dtype = variable_info[$1->dtype->btype][$3];
     }
     | postfix_expression PTR_OP IDENTIFIER
     {   
          //Adding
          if(!($1->dtype->ptr_count + $1->dtype->dims.size() > 0) || !($1->dtype->btype.substr(0,6)=="struct")){
              error(@$,"Subscripted value is not struct pointer");
          }
          //cout<<$3<<endl;
          if(gst.Entries[$1->dtype->btype]->symbtab->Entries.count($3) ==0){
               error(@$,"variable not a member of struct");
          }
          //added
         $$ = new arrow_astnode($1,new identifier_astnode($3));
         $$->dtype = variable_info[$1->dtype->btype][$3];
     }
     | postfix_expression INC_OP
     {
          $$ = new op_unary_astnode("PP",$1);
          $$->dtype = $1->dtype;
     }
     ;

primary_expression: 
     IDENTIFIER
     {   
        $$ = new identifier_astnode($1);  
        // need to get the type of identifier from GST
        
        $$->type = 9;
        $$->id_name.clear();
        $$->id_name = $1;
        if(variable_dtypes.count($1) ==0){
             error(@$,"variable "+$1+" not declared" );
        }
        $$->dtype = variable_dtypes[$1];
        
     }
     | INT_CONSTANT
     {
        $$ = new intconst_astnode($1);
        $$->type = 1;
         $$->id_name.clear();
        $$->id_name = "INTEGER";
        $$->dtype = new datatype("int");
        if($1 == "0"){
             $$->dtype->zero = 1;
        }
     }
     | FLOAT_CONSTANT
     {
        $$ = new floatconst_astnode($1);
        $$->type = 2;
         $$->id_name.clear();
        $$->id_name = "FLOAT";
        $$->dtype = new datatype("float");
     }
     | STRING_LITERAL
     {
        $$ = new stringconst_astnode($1); 
        $$->type = 3;
        $$->dtype = new datatype("string");
     }
     | '(' expression ')'
     {
         $$ = $2;
     }
     ;

expression_list: 
     expression
     {
          $$  = new funcall_astnode();
          $$->funcvec.push_back($1);
     }
     | expression_list ',' expression
     {
         $$ = $1;
         $$->funcvec.push_back($3);
     }
     ;

unary_operator: 
     '-'
     {
          $$ = "UMINUS";
     }
     | '!'
     {
         $$ = "NOT";    
     }
     | '&'
     {
         $$ = "ADDRESS";
     }
     | '*'
     {
         $$ = "DEREF";
     }
     ;

selection_statement: 
     IF '(' expression ')' statement ELSE statement
     {
        $$ = new if_astnode($3,$5,$7);
     }
     ;

iteration_statement: 
     WHILE '(' expression ')' statement
     {
        $$ = new while_astnode($3,$5);
     }
     | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
     {
        $$ = new for_astnode($3,$5,$7,$9);
     }
     ;

declaration_list: 
     declaration
     {
         $$ = new declaration_list_class();
         $$->dection_list.push_back($1);
     }
     | declaration_list declaration
     {
         $$ = $1;
         $$->dection_list.push_back($2);  
     }
     ;

declaration: 
     type_specifier declarator_list ';'
     {
         for (auto it : $2->dector_list) {
            
              if($1 == "void" && it->star == 0){
                   error(@$,"Cannot declare variable of type void");
               }
              variable_dtypes[it->dector_str] = new datatype($1, it->star, it->dector_array);
              if (curr_struct != "") {
                   variable_info[curr_struct][it->dector_str] = new datatype($1, it->star, it->dector_array);
              }
         }
         
         $$ = new declaration_class($1,$2);
     }
     ;

declarator_list: 
     declarator
     {
         $$ = new declarator_list_class();
         $$->dector_list.push_back($1);
     }
     | declarator_list ',' declarator
     {
          $$ = $1;
         $$->dector_list.push_back($3);
     }
     ;

%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message <<  "\n";
   exit(1);
}

