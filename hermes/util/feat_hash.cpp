#include <assert.h>
#include "../inc/hermes.h"
#include "../inc/util/state_info.h"

uint32_t process_PC(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)                  { return 0; }
uint32_t process_Offset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)              { return 0; }
uint32_t process_Page(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)                { return 0; }
uint32_t process_Addr(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)                { return 0; }
uint32_t process_FirstAccess(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)         { return 0; }
uint32_t process_PC_Offset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)           { return 0; }
uint32_t process_PC_Page(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)             { return 0; }
uint32_t process_PC_Addr(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)             { return 0; }
uint32_t process_PC_FirstAccess(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)      { return 0; }
uint32_t process_Offset_FirstAccess(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)  { return 0; }
uint32_t process_CLOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)            { return 0; }
uint32_t process_PC_CLOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)         { return 0; }
uint32_t process_CLWordOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)        { return 0; }
uint32_t process_PC_CLWordOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)     { return 0; }
uint32_t process_CLDWordOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)       { return 0; }
uint32_t process_PC_CLDwordOffset(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)    { return 0; }
uint32_t process_LastNLoadPCs(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)        { return 0; }
uint32_t process_LastNPCs(state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)            { return 0; }

uint32_t perceptron_pred_t::generate_index_from_feature(feature_type_t feature, state_info_t *state, uint64_t metadata, int32_t hash_type, uint32_t weight_array_size)
{
    if(state == NULL) return 0;
    
    switch(feature)
    {
        case feature_type_t::PC:                    return process_PC(state, metadata, hash_type, weight_array_size);
        case feature_type_t::Offset:                return process_Offset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::Page:                  return process_Page(state, metadata, hash_type, weight_array_size);
        case feature_type_t::Addr:                  return process_Addr(state, metadata, hash_type, weight_array_size);
        case feature_type_t::FirstAccess:           return process_FirstAccess(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_Offset:             return process_PC_Offset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_Page:               return process_PC_Page(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_Addr:               return process_PC_Addr(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_FirstAccess:        return process_PC_FirstAccess(state, metadata, hash_type, weight_array_size);
        case feature_type_t::Offset_FirstAccess:    return process_Offset_FirstAccess(state, metadata, hash_type, weight_array_size);
        case feature_type_t::CLOffset:              return process_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_CLOffset:           return process_PC_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::CLWordOffset:          return process_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_CLWordOffset:       return process_PC_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::CLDWordOffset:         return process_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::PC_CLDWordOffset:      return process_PC_CLWordOffset(state, metadata, hash_type, weight_array_size);
        case feature_type_t::LastNLoadPCs:          return process_LastNLoadPCs(state, metadata, hash_type, weight_array_size);
        case feature_type_t::LastNPCs:              return process_LastNPCs(state, metadata, hash_type, weight_array_size);
        default:                                    assert(false);
    }

    return 0;
}