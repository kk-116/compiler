#ifndef AST_HH
#define AST_HH

#include <iostream>
using namespace std;
#include <vector>
#include <string>
#include "type.hh"

class datatype {
    public :
    string btype;
    int ptr_count;
    vector<int> dims;
    int zero;
    datatype(string btype);
    datatype(string btype, int ptr_count, vector<int> dims);
    bool isint();
    bool isfloat();
    void set(string s);
    string stringtype();

    
};

class abstract_astnode
{
public:
virtual void print(int blanks) = 0 ;

};

class statement_astnode : public abstract_astnode {
public:
// statement_astnode();
int is_empty;
int type;
string id_name;
statement_astnode(){
    type = 0;
    id_name = "default";
}
};

class exp_astnode : public abstract_astnode {
// public:
// exp_astnode();
public:
int type;
string id_name;
datatype* dtype;
exp_astnode(){
    type = 0;
    id_name = "default";
}
};

class ref_astnode : public exp_astnode {
// public:
// ref_astnode();
};

class empty_astnode : public statement_astnode {
public:
empty_astnode();
void print(int blanks);
};

class seq_astnode : public statement_astnode {
public:
// seq_astnode();
seq_astnode(vector<statement_astnode*> seqvec);
int dummy;
void print(int blanks);
vector<statement_astnode*> seqvec;

};

class assignS_astnode : public statement_astnode {
public:
assignS_astnode();
assignS_astnode(exp_astnode* aS_exp1,exp_astnode* aS_exp2);
void print(int blanks) ;
exp_astnode* aS_exp1;
exp_astnode* aS_exp2;
};

class return_astnode : public statement_astnode {
public:
return_astnode();
return_astnode(exp_astnode* r_exp);
void print(int blanks) ;
exp_astnode* r_exp;
};

class if_astnode : public statement_astnode {
public:
if_astnode();
if_astnode(exp_astnode* if_exp,statement_astnode* if_st1,statement_astnode* if_st2);
void print(int blanks) ;
exp_astnode* if_exp;
statement_astnode* if_st1;
statement_astnode* if_st2;
};

class while_astnode : public statement_astnode {
public:
while_astnode();
while_astnode(exp_astnode* wh_exp,statement_astnode* wh_st);
void print(int blanks) ;
exp_astnode* wh_exp;
statement_astnode* wh_st;
};

class for_astnode : public statement_astnode {
public:
for_astnode();
for_astnode(exp_astnode* f_exp1,exp_astnode* f_exp2,exp_astnode* f_exp3,statement_astnode* f_st);
void print(int blanks) ;
exp_astnode* f_exp1;
exp_astnode* f_exp2;
exp_astnode* f_exp3;
statement_astnode* f_st;
};

class proccall_astnode : public statement_astnode {
public:
proccall_astnode();
proccall_astnode(string proc_s);
proccall_astnode(string proc_s ,vector<exp_astnode*> procvec);
void print(int blanks) ;
string proc_s;
vector<exp_astnode*> procvec;
};

class identifier_astnode : public ref_astnode {
public:
identifier_astnode();
identifier_astnode(string id_s);
void print(int blanks) ;
string id_s;
};

class arrayref_astnode : public ref_astnode {
public:
arrayref_astnode();
arrayref_astnode(exp_astnode* array_exp1,exp_astnode* array_exp2);
void print(int blanks) ;
exp_astnode* array_exp1;
exp_astnode* array_exp2;
};

class member_astnode : public ref_astnode {
public:
member_astnode();
member_astnode(exp_astnode* mem_exp,identifier_astnode* mem_id);
void print(int blanks) ;
exp_astnode* mem_exp;
identifier_astnode* mem_id;
};

class arrow_astnode : public ref_astnode {
public:
arrow_astnode();
arrow_astnode(exp_astnode* arrow_exp,identifier_astnode* arrow_id);
void print(int blanks) ;
exp_astnode* arrow_exp;
identifier_astnode* arrow_id;
};

class op_binary_astnode : public exp_astnode {
public:
op_binary_astnode();
op_binary_astnode(string bin_s,exp_astnode* bin_exp1,exp_astnode* bin_exp2);
void print(int blanks) ;
string bin_s;
exp_astnode* bin_exp1;
exp_astnode* bin_exp2;
};

class op_unary_astnode : public exp_astnode {
public:
op_unary_astnode();
op_unary_astnode(string un_s,exp_astnode* un_exp);
void print(int blanks) ;
string un_s;
exp_astnode* un_exp;
};

class assignE_astnode : public exp_astnode {
public:
assignE_astnode();
assignE_astnode(exp_astnode* aE_exp1,exp_astnode* aE_exp2);
void print(int blanks) ;
exp_astnode* aE_exp1;
exp_astnode* aE_exp2;
};

class funcall_astnode : public exp_astnode {
public:
funcall_astnode();
funcall_astnode(string func_s);
funcall_astnode(string func_s,vector<exp_astnode*> funcvec);
void print(int blanks) ;
string func_s;
vector<exp_astnode*> funcvec;
};

class intconst_astnode : public exp_astnode {
public:
intconst_astnode();
intconst_astnode(int intconst);
intconst_astnode(string intconst);
void print(int blanks) ;
int intconst;
};

class floatconst_astnode : public exp_astnode {
public:
floatconst_astnode();
floatconst_astnode(float floatconst);
floatconst_astnode(string floatconst);
void print(int blanks) ;
float floatconst;
};

class stringconst_astnode : public exp_astnode {
public:
stringconst_astnode();
stringconst_astnode(string stringconst);
void print(int blanks) ;
string stringconst;
};



#endif