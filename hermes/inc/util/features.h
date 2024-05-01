#ifndef FEATURE_NAMES_H
#define FEATURE_NAMES_H

#include <string>

typedef enum {
    PC = 0,                     
    Offset,                     
    Page,                       
    Addr,                       
    FirstAccess,                
    PC_Offset,                  
    PC_Page,                    
    PC_Addr,                    
    PC_FirstAccess,             
    Offset_FirstAccess,         
    CLOffset,                   
    PC_CLOffset,                
    CLWordOffset,               
    PC_CLWordOffset,            
    CLDWordOffset,              
    PC_CLDWordOffset,           
    LastNLoadPCs,               
    LastNPCs,                   
    num_feature_types           
} feature_type_t;

extern std::string feature_names[num_feature_types];
#endif