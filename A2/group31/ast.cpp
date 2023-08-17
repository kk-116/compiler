#include "ast.hh"

string datatype::stringtype(){
    string type = this->btype;
    for(int i=0; i<this->ptr_count; i++){
        type += '*';
    }
    for(int i=0; i<this->dims.size(); i++){
        type += '[' + to_string(this->dims[i]) + ']';
    }

    return type;


}

void datatype::set(string s) {
    
    this->dims.clear();
    this->ptr_count = 0;
    this->zero =0;

    if(s[0] == 'i'){
        this->btype = "int";
    }
    if(s[0] == 'f'){
        this->btype = "float";
        
    }
    if(s[0] == 'v'){
        this->btype = "void";
        
    }
    if(s[0] == 's'){
        string type;
        for(int i=0; i<s.length(); i++){
            if(s[i] == '*'){
                break;
            }
            else{
                type += s[i];
            }
        }

        this->btype = type;

    }

    for( size_t i=0; i< s.length(); i++){
        if(s[i] == '*') {
            this->ptr_count++;
        }
    }

    int lbracket = 0;
    for( size_t i=0; i< s.length(); i++){
        string number;

        if(s[i] == ']'){
            this->dims.push_back(stoi(number));
            number = "";
            lbracket = 0;
        }
        
        if(lbracket == 1){
            number += s[i];
        }

        if(s[i] == '['){
            lbracket = 1;
        }
        
    }
}

datatype::datatype(string btype) {
    this->btype = btype;
    this->ptr_count = 0;
    this->zero =0;
}

datatype::datatype(string btype, int ptr_count, vector<int> dims) {
    this->btype =  btype;
    this->ptr_count = ptr_count;
    this->dims = dims;
    this->zero =0;
}

bool datatype::isint() {
    if (this->btype == "int" && this->ptr_count == 0 && this->dims.size() == 0) {
        return 1;
    }
    return 0;
}

bool datatype::isfloat() {
    if (this->btype == "float" && this->ptr_count == 0 && this->dims.size() == 0) {
        return 1;
    }
    return 0;
}

void empty_astnode::print(int blanks){
    cout<<"\"empty\"";
}

empty_astnode::empty_astnode(){
    this->is_empty = 1;
}

void seq_astnode::print(int blanks){
    cout<<"\"seq\": [";
    int count = 0;
    for(auto it:seqvec){
        if(count!=0){
            cout<<",";
        }
        count++;
        if(it->is_empty == 1){
            it->print(0);
        }else{
        cout<<"{";
        it->print(0);
        cout<<"}";
        }
    }
    cout<<"]";
}

// seq_astnode::seq_astnode(){

// }

seq_astnode::seq_astnode(vector<statement_astnode*> seqvec){
    this->dummy = 512;
    this->seqvec = seqvec;
    this->is_empty = 0;
}

void assignS_astnode::print(int blanks){
    cout<<"\"assignS\": {";
    cout<<"\"left\": {";
    this->aS_exp1->print(0);
    cout<<"},";
    cout<<"\"right\": {";
    this->aS_exp2->print(0);
    cout<<"}";
    cout<<"}";
}

assignS_astnode::assignS_astnode(exp_astnode* aS_exp1,exp_astnode* aS_exp2){
    this->aS_exp1 = aS_exp1;
    this->aS_exp2 = aS_exp2;
    this->is_empty = 0;
}

void return_astnode::print(int blanks){
    cout<<"\"return\": {";
    // this->r_exp->print(0);
    // cout<<"\"op_unary\": {";
    // cout<<"\"op\": \""<<"TO_INT"<<"\"";
    // cout<<",";
    // cout<<"\"child\": {";
    this->r_exp->print(0);
    // cout<<"}";
    // cout<<"}";
    cout<<"}";
}

return_astnode::return_astnode(exp_astnode* r_exp){
    this->r_exp = r_exp;
    this->is_empty = 0;
}


void proccall_astnode::print(int blanks){
    cout<<"\"proccall\": {";
    cout<<"\"fname\": {";
    cout<<"\"identifier\": ";
    cout<<"\""<<proc_s<<"\"";
    cout<<"},";
    cout<<"\"params\": [";
    int count = 0;
    for(auto it:procvec){
        if(count!=0){
            cout<<",";
        }
        count++;
        cout<<"{";
        it->print(0);
        cout<<"}";
    }
    cout<<"]";
    cout<<"}";
}

proccall_astnode::proccall_astnode(string proc_s){
    this->proc_s = proc_s;
    this->is_empty = 0;
}
proccall_astnode::proccall_astnode(string proc_s ,vector<exp_astnode*> procvec){
    this->proc_s = proc_s;
    this->procvec =procvec;
    this->is_empty = 0;
}


void if_astnode::print(int blanks){
    cout<<"\"if\": {";
    cout<<"\"cond\": {";
    this->if_exp->print(0);
    cout<<"},";
    cout<<"\"then\": ";
    if(this->if_st1->is_empty == 1){
        this->if_st1->print(0);
    }
    else{
        cout<<"{";
        this->if_st1->print(0);
        cout<<"}";
    }
    cout<<",";
    cout<<"\"else\": ";
    if(this->if_st2->is_empty == 1){
        this->if_st2->print(0);
    }
    else{
        cout<<"{";
        this->if_st2->print(0);
        cout<<"}";
    }
    cout<<"}";
}

if_astnode::if_astnode(exp_astnode* if_exp,statement_astnode* if_st1,statement_astnode* if_st2){
    this->if_exp = if_exp;
    this->if_st1 = if_st1;
    this->if_st2 = if_st2;
    this->is_empty = 0;
}


void while_astnode::print(int blanks){
    cout<<"\"while\": {";
    cout<<"\"cond\": {";
    this->wh_exp->print(0);
    cout<<"},";
    cout<<"\"stmt\": ";
    if(this->wh_st->is_empty == 1){
        this->wh_st->print(0);
    }
    else{
        cout<<"{";
        this->wh_st->print(0);
        cout<<"}";
    }
    cout<<"}";
}

while_astnode::while_astnode(exp_astnode* wh_exp,statement_astnode* wh_st){
    this->wh_exp =wh_exp;
    this->wh_st = wh_st;
    this->is_empty = 0;
}

void for_astnode::print(int blanks){
    cout<<"\"for\": {";
    cout<<"\"init\": {";
    this->f_exp1->print(0);
    cout<<"},";
    cout<<"\"guard\": {";
    this->f_exp2->print(0);
    cout<<"},";
    cout<<"\"step\": {";
    this->f_exp3->print(0);
    cout<<"},";
    cout<<"\"body\": ";
    if(this->f_st->is_empty == 1){
        this->f_st->print(0);
    }
    else{
        cout<<"{";
        this->f_st->print(0);
        cout<<"}";
    }
    cout<<"}";
}

for_astnode::for_astnode(exp_astnode* f_exp1,exp_astnode* f_exp2,exp_astnode* f_exp3,statement_astnode* f_st){
    this->f_exp1 = f_exp1;
    this->f_exp2 = f_exp2;
    this->f_exp3 = f_exp3;
    this->f_st = f_st;
    this->is_empty = 0;
}


void op_binary_astnode::print(int blanks){
    cout<<"\"op_binary\": {";
    cout<<"\"op\": \""<<bin_s<<"\"";
    cout<<",";
    cout<<"\"left\": {";
    this->bin_exp1->print(0);
    cout<<"},";
    cout<<"\"right\": {";
    this->bin_exp2->print(0);
    cout<<"}";
    cout<<"}";
}

op_binary_astnode::op_binary_astnode(string bin_s,exp_astnode* bin_exp1,exp_astnode* bin_exp2){
    this->dtype = new datatype("int");
    this->bin_s = bin_s;
    this->bin_exp1 = bin_exp1;
    this->bin_exp2 = bin_exp2;
}

void op_unary_astnode::print(int blanks){
    cout<<"\"op_unary\": {";
    cout<<"\"op\": \""<<un_s<<"\"";
    cout<<",";
    cout<<"\"child\": {";
    this->un_exp->print(0);
    cout<<"}";
    cout<<"}";
}

op_unary_astnode::op_unary_astnode(string un_s,exp_astnode* un_exp){
    this->dtype = new datatype("int");
    this->un_s = un_s;
    this->un_exp = un_exp;
}

void assignE_astnode::print(int blanks){
    cout<<"\"assignE\": {";
    cout<<"\"left\": {";
    this->aE_exp1->print(0);
    cout<<"},";
    cout<<"\"right\": {";
    this->aE_exp2->print(0);
    cout<<"}";
    cout<<"}";    
}

assignE_astnode::assignE_astnode(exp_astnode* aE_exp1,exp_astnode* aE_exp2){
    this->dtype = new datatype("int");
    this->aE_exp1 = aE_exp1;
    this->aE_exp2 = aE_exp2;
}

void funcall_astnode::print(int blanks){
    cout<<"\"funcall\": {";
    cout<<"\"fname\": {";
    cout<<"\"identifier\": \""<<func_s<<"\"";
    cout<<"},";
    cout<<"\"params\": [";
    int count = 0;
    for(auto it:funcvec){
        if(count!=0){
            cout<<",";
        }
        count++;
        cout<<"{";
        it->print(0);
        cout<<"}";
    }
    cout<<"]";
    cout<<"}";
}

funcall_astnode::funcall_astnode(){
    this->dtype = new datatype("int");
}

funcall_astnode::funcall_astnode(string func_s){
    this->dtype = new datatype("int");
    this->func_s = func_s;
}

funcall_astnode::funcall_astnode(string func_s,vector<exp_astnode*> funcvec){
    this->dtype = new datatype("int");
    this->func_s = func_s;
    this->funcvec = funcvec;
}


void floatconst_astnode::print(int blanks){
    cout<<"\"floatconst\": ";
    cout<<floatconst;
}

floatconst_astnode::floatconst_astnode(float floatconst){
    this->dtype = new datatype("float");
    this->floatconst = floatconst;
}


floatconst_astnode::floatconst_astnode(string floatconst){
    this->dtype = new datatype("float");
    this->floatconst = stof(floatconst);
}


void intconst_astnode::print(int blanks){
    cout<<"\"intconst\": ";
    cout<<intconst;
}

intconst_astnode::intconst_astnode(int intconst){
    this->dtype = new datatype("int");
    this->intconst = intconst;
}

intconst_astnode::intconst_astnode(string intconst){
    this->dtype = new datatype("int");
    this->intconst = stoi(intconst);
}

void stringconst_astnode::print(int blanks){
    cout<<"\"stringconst\": ";
    cout<<stringconst;

}

stringconst_astnode::stringconst_astnode(string stringconst){
    this->dtype = new datatype("string");
    this->stringconst = stringconst;
}

void member_astnode::print(int blanks){
    cout<<"\"member\": {";
    cout<<"\"struct\": {";
    this->mem_exp->print(0);
    cout<<"},";
    cout<<"\"field\": {";
    this->mem_id->print(0);
    cout<<"}";
    cout<<"}";
}

member_astnode::member_astnode(exp_astnode* mem_exp,identifier_astnode* mem_id){
    this->dtype = new datatype("int");
    this->mem_exp  = mem_exp;
    this->mem_id = mem_id;
}

void arrow_astnode::print(int blanks){
    cout<<"\"arrow\": {";
    cout<<"\"pointer\": {";
    this->arrow_exp->print(0);
    cout<<"},";
    cout<<"\"field\": {";
    this->arrow_id->print(0);
    cout<<"}";
    cout<<"}";
}

arrow_astnode::arrow_astnode(exp_astnode* arrow_exp,identifier_astnode* arrow_id){
    this->dtype = new datatype("int");
    this->arrow_exp = arrow_exp;
    this->arrow_id = arrow_id;
}

void identifier_astnode::print(int blanks){
    cout<<"\"identifier\": \""<<id_s<<"\"";
}

identifier_astnode::identifier_astnode(string id_s){
    this->dtype = new datatype("int");
    this->id_s = id_s;
}

void arrayref_astnode::print(int blanks){
    cout<<"\"arrayref\": {";
    cout<<"\"array\": {";
    this->array_exp1->print(0);
    cout<<"},";
    cout<<"\"index\": {";
    this->array_exp2->print(0);
    cout<<"}";
    cout<<"}";
}

arrayref_astnode::arrayref_astnode(exp_astnode* array_exp1,exp_astnode* array_exp2){
    this->dtype = new datatype("int");
    this->array_exp1 = array_exp1;
    this->array_exp2 = array_exp2;
}