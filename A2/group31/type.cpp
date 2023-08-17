#include "type.hh"

// #include <stdexcept>
 #include <sstream>

// Type::Type(string name){
//     this->name = name;
// }

// string Type::getType(){
//     return this->name;
// }

// bool Type::isCompat(Type* other) {
//     if(this==ther){
//         return true;
//     }
//     for(Type* type : compat){
//         if(type->isCompat(other)){
//             return true;
//         }
//     }
//     return false;
// }

// void Type::addCompat(Type* type) {
//     compat.push_back(type);
// }


// Type::Type(datatype t)
//     : m_datatype(t),m_size(0),m_struct_name("")
// {
//     if(t==CHAR_TYPE){
//         m_size =1;
//     }
// }

// Type::Type(datatype t,int size)
//     : m_datatype(t),m_size(size),m_struct_name("")
// {
//     if(t!=CHAR_TYPE){
//         throw invalid_argument("Size argument valid only for char type");
//     }
// }

// Type::Type(datatype t,string s)
//     : m_datatype(t),m_size(0),m_struct_name(s)
// {
//     if(t!=STRUCT_TYPE){
//         throw invalid_argument("struct name argument valid only for struct type");

//     }
// }

// Type::Type(const Type& other)
//     : m_datatype(other.m_datatype),m_size(other.m_size),m_struct_name(other.m_struct_name)
// {
// }

// Type& Type::operator=(const Type& other)
// {
//     if(this != &other){
//         m_datatype = other.m_datatype;
//         m_struct_name = other.m_struct_name;
//         m_size = other.m_size;
//     }
//     return *this;
// }

// bool Type::operator==(const Type& other) const
// {
    
//     if(m_datatype != other.m_datatype){return false;}
//     if(m_datatype == datatype::CHAR_TYPE){return true;}
//     if(m_datatype == datatype::STRUCT_TYPE){
//         return m_struct_name ==other.m_struct_name;
//     }
//     return true;
// }

// bool Type::operator!=(const Type& other) const
// {
    
//     return !(*this == other);
// }

// bool Type::is_void() const{
//     return m_datatype == datatype::VOID_TYPE;
// }

// bool Type::is_int() const{
//     return m_datatype == datatype::INT_TYPE;
// }

// bool Type::is_float() const{
//     return m_datatype == datatype::FLOAT_TYPE;
// }

// bool Type::is_bool() const{
//     return m_datatype == datatype::BOOL_TYPE;
// }

// bool Type::is_char() const{
//     return m_datatype == datatype::CHAR_TYPE;
// }

// bool Type::is_array() const{
//     return m_size>0;
// }

// bool Type::is_struct() const{
//     return !m_struct_name.empty();
// }

// int Type::get_size() const{
//     return m_size;
// }

// datatype Type::get_datatype() const{
//     return m_datatype;
// }

// string Type::get_struct_name() const{
//     return m_struct_name;
// }

// string Type::to_string() const{
//     switch(m_datatype){
//         case VOID_TYPE:
//             return "void";
//         case INT_TYPE:
//             return "int";
//         case FLOAT_TYPE:
//             return "float";
//         case BOOL_TYPE:
//             return "bool";
//         case CHAR_TYPE:
//             return "char";
//         default:
//             return m_struct_name
//     }
// }

typeSymbol::typeSymbol(string name,string varfun,string scope,string type,int size,int offset,typeSymbTab* symbtab){
    this->name = name;
    this->varfun = varfun;
    this->type = type;
    this->scope = scope;
    this->size = size;
    this->offset = offset;
    this->symbtab = symbtab;
}

fun_declarator_class::fun_declarator_class(string fun_id){
    this->fun_id = fun_id;
}

fun_declarator_class::fun_declarator_class(string fun_id,parameter_list_class* fun_list){
    this->fun_id = fun_id;
    this->fun_list = fun_list;
}

parameter_declaration_class::parameter_declaration_class(string par_type,declarator_class* par_dector){
    this->par_type = par_type;
    this->par_dector = par_dector;
}

declarator_class::declarator_class(string dector_str){
    this->dector_str =  dector_str;
}

declaration_class::declaration_class(string dec_type,declarator_list_class* dec_list){
    this->dec_type = dec_type;
    this->dec_list = dec_list;
}

string declarator_class::getType(string type_s){
    string type = "" +type_s;
    for(long unsigned int i=0;i<this->star;i++){
        type += "*";
    }
    for(long unsigned int i=0;i<this->dector_array.size();i++){
        type += "[" + to_string(dector_array[i]) + "]";
    }
    return type;
}

int declarator_class::getSize(string type_s,typeSymbTab table){
    
    int size1 = 4;
    string s = getType(type_s);
    string star = "*";
    bool point = 0;
    bool normal = 0;
    size_t f = s.find(star);
    if(f != string::npos){
        point = 1;
    }

    if(point ==0 && (type_s == "int" || type_s == "float" || type_s == "struct")){
        normal =1;
    }
    if (point == 0 && normal == 0 ){

        string s1;
        size_t pos = s.find('[');
        if(pos != string::npos){
            s1 = s.substr(0,pos);
        }else{
            s1 =s;
        }
        int count = 0;
        stringstream ss(s1);
        string word;
        string check = "";
        while(ss >> word){
         if(count == 0){
             check += word + " ";
         }
         else if(count == 1){
             check += word;
         }
         count++;
        }

    for(auto &itr: table.Entries){
         if(check ==itr.first){
            size1 = itr.second->size;
         }
    }
   
    }
       
    for(long unsigned int i=0;i<this->dector_array.size();i++){
        size1 = size1 * dector_array[i];
    }
    return size1;
}

declaration_class::declaration_class(){}
declarator_class::declarator_class(){}
declarator_list_class::declarator_list_class(){}
declaration_list_class::declaration_list_class(){}
parameter_declaration_class::parameter_declaration_class(){}
parameter_list_class::parameter_list_class(){}
fun_declarator_class::fun_declarator_class(){}