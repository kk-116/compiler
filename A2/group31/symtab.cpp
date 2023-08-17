#include "symtab.hh"


// SymTab::SymTab() {}
// SymTab::~SymTab() {}

// void SymTab::addSymbol(const string& name , const string& type, int offset){
//     Symbol symbol;
//     symbol.name = name;
//     symbol.type = type;
//     symbol.offset = offset;
//     Entries.insert(make_pair(name,&symbol));
// }

// Symbol* SymTab::getSymbol(const string& name) {
//     auto it = Entries.find(name);
//     if(it!= Entries.end()){
//         return (it->second);
//     }else {
//         return nullptr;
//     }
// }

map<int,Symbol*> SymbTab::cus_sort(){
    map<int,Symbol*> temp;
    for(auto &it: this->Entries){
        if(it.second->scope == "param"){
                temp[it.second->offset] = it.second;
        }
    }
    return temp;
}

void SymbTab::print(){
    cout<<"[";
    for (auto it = this->Entries.begin(); it != this->Entries.end(); ++it){
        if(it != this->Entries.begin()){
            cout<<",";
        }
        cout<<"[";
        cout<<"\""<<it->second->name<<"\""<<",";
        cout<<"\""<<it->second->varfun<<"\""<<",";
        cout<<"\""<<it->second->scope<<"\""<<",";
        cout<<it->second->size<<",";
        if(it->second->varfun =="struct" && it->second->scope =="global"){
            cout<<"\"-\""<<",";
        }
        else{
            cout<<it->second->offset<<",";
        }
        cout<<"\""<<it->second->type<<"\"";
        cout<<"]";
    }
    cout<<"]";
}

void SymbTab::printgst(){
    this->print();
}

Symbol::Symbol(string name,string varfun,string scope,string type,int size,int offset,SymbTab* symbtab){
    this->name = name;
    this->varfun = varfun;
    this->type = type;
    this->scope = scope;
    this->size = size;
    this->offset = offset;
    this->symbtab = symbtab;
}