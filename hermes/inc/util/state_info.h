#ifndef STATE_INFO_H
#define STATE_INFO_H

#include <cstdint> 
#include <string> 
#include <iomanip>

class state_info_t {
public:
    uint64_t pc;                    // Program counter
    uint64_t last_n_load_pc_sig;    // Last signal for loading
    uint64_t last_n_pc_sig;         // Last program counter signal
    uint32_t data_index;            // Index of the data
    uint64_t vaddr;                 // Virtual address
    uint64_t vpage;                 // Virtual page
    uint32_t voffset;               // Virtual offset
    bool first_access;              // Flag indicating if it's the first access
    uint32_t v_cl_offset;           // Cache line offset
    uint32_t v_cl_word_offset;      // Cache line word offset
    uint32_t v_cl_dword_offset;     // Cache line double-word offset

    state_info_t()
        : pc(0),
          last_n_load_pc_sig(0),
          last_n_pc_sig(0),
          data_index(0),
          vaddr(0),
          vpage(0),
          voffset(0),
          first_access(false),
          v_cl_offset(0),
          v_cl_word_offset(0),
          v_cl_dword_offset(0) {}

    std::string to_string() {
        std::stringstream ss;

        ss  << "PC: "       << std::setw(8)     << std::hex << pc       << std::dec
            << " data_id: " << std::setw(2)     << data_index
            << " vaddr: "   << std::setw(12)    << std::hex << vaddr    << std::dec
            << " vpage: "   << std::setw(12)    << std::hex << vpage    << std::dec
            << " voffset: " << std::setw(2)     << voffset
            << " fa: "      << std::setw(1)     << first_access
            << " vclo: "    << std::setw(2)     << v_cl_offset  
            << " vclwo: "   << std::setw(2)     << v_cl_word_offset
            << " vcldwo: "  << std::setw(2)     << v_cl_dword_offset;

        return ss.str();
    }
};

#endif