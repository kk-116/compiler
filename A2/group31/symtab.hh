#ifndef SYMTAB_HH
#define SYMTAB_HH

#include <string>
#include <cstring>
#include <iostream>
#include <algorithm>
#include <vector>
using namespace std;
#include<map>
// #include "type.hh"


class SymbTab;

struct Symbol {
    string name;
    string varfun;
    string type;
    string scope;
    int size;
    int offset;
    SymbTab* symbtab;
    Symbol(string name,string varfun,string scope,string type,int size,int offset,SymbTab* symbtab);
};

class SymbTab {
public:
   
    // void addSymbol(const string& name , const string& type, int offset);
    // Symbol* getSymbol(const string& name);
    void print();
    void printgst();
    map<string,Symbol*> Entries;
    map<int,Symbol*> cus_sort();
};

#endif