#ifndef TYPE_HH
#define TYPE_HH


#include <string>
#include <string.h>
#include <cstring>
#include<iostream>
#include<vector>
#include <map>
using namespace std;

// enum datatype { VOID_TYPE,INT_TYPE,FLOAT_TYPE,BOOL_TYPE,CHAR_TYPE};

// class Type {
// public:
//     Type(string name);
//     string getType();
//     bool isCompat(Type* other);
//     void addCompat(Type* type);
// private:
//     string name;
//     vector<Type*> compat;
// }

// class Type {
// public:
//     Type(datatype t);
//     Type(datatype t,int size);
//     Type(datatype t,string s);
//     Type(const Type& other);
//     Type operator=(const Type& other);
//     bool operator==(const Type& other) const;
//     bool operator!=(const Type& other) const;
//     bool is_void() const;
//     bool is_int() const;
//     bool is_float() const;
//     bool is_bool() const;
//     bool is_array() const;
//     bool is_char() const;
//     bool is_struct() const;

//     int get_size() const;
//     datatype get_datatype() const;
//     string get_struct_name() const;
//     string to_string() const;

// private:
//     datatype m_datatype;
//     int m_size;
//     string m_struct_name;
// };



struct typeSymbTab;

struct typeSymbol {
    string name;
    string varfun;
    string type;
    string scope;
    int size;
    int offset;
    typeSymbTab* symbtab;
    typeSymbol(string name,string varfun,string scope,string type,int size,int offset,typeSymbTab* symbtab);
};

struct typeSymbTab {
    map<string,typeSymbol*> Entries;
};


class declarator_class{
    public:
    string dector_str;
    vector<int> dector_array;
    long unsigned int star = 0;
    declarator_class();
    declarator_class(string dector_str);
    string getType(string type_s);
    int getSize(string type_s,typeSymbTab table);
};

class declarator_list_class{
    public:
    vector<declarator_class*>dector_list;
    declarator_list_class();
};
class declaration_class{
    public:
    string dec_type;
    declarator_list_class* dec_list;
    declaration_class();
    declaration_class(string dec_type,declarator_list_class* dec_list);
};

class declaration_list_class{
    public:
    vector<declaration_class*>dection_list;
    declaration_list_class();
};

class parameter_declaration_class{
    public:
    string par_type;
    declarator_class* par_dector;    
    parameter_declaration_class();
    parameter_declaration_class(string par_type,declarator_class* par_dector);

};

class parameter_list_class{
    public:
    vector<parameter_declaration_class*> par_list;
    parameter_list_class();
};


class fun_declarator_class{
    public:
    string fun_id;
    parameter_list_class* fun_list;
    fun_declarator_class();
    fun_declarator_class(string fun_id);
    fun_declarator_class(string fun_id,parameter_list_class* fun_list);
};


#endif