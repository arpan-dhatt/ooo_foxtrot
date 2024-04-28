#include <verilated.h>
#include <iostream>
#include <vector>
#include <cstring>
#include <sstream>
#include <fstream>

#include "Vfed_stage.h"
#include "support/memory.h"

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <test_directory_path>" << std::endl;
        return 1;
    }

    std::string directory_path = argv[1];
    std::string elf_file_path = directory_path + "/prog.elf";

    auto* const contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    auto* const fed = new Vfed_stage{contextp};

    // Create memory instance
    constexpr size_t MEMORY_SIZE = 4 * 1024;  // 4 KiB
    constexpr size_t MEMORY_LATENCY = 0;  // 10 cycles latency
    Memory memory(MEMORY_SIZE, MEMORY_LATENCY);

    // Load memory contents from file if it exists
    if (std::ifstream(elf_file_path).good()) {
        std::cout << "Loading ELF file:" << elf_file_path << std::endl;
        memory.load_elf(elf_file_path);
    } else {
        throw std::invalid_argument("ELF does not exist");
    }

    // Reset
    fed->clk = 0;
    fed->eval();
    fed->rst = 1;
    fed->clk = 1;
    fed->eval();
    fed->rst = 0;
    fed->clk = 0;
    fed->eval();

    std::ostringstream mmio_output;

    int i = 0;
    while (i < 10) {
        // Cycle clock
        fed->clk ^= 1;
        fed->eval();
        fed->clk ^= 1;
        fed->eval();

        // Handle memory reads
        if (fed->mem_ren && fed->mem_raddr < MEMORY_SIZE) {
            memory.read(fed->mem_raddr);
        }

        // Update memory
        memory.update();

        // Set the read data and mem_rvalid signal
        auto read_data = memory.get_read_data();
        if (read_data.has_value()) {
            fed->mem_rvalid = 1;
            fed->mem_rdata = read_data.value();
        } else {
            fed->mem_rvalid = 0;
        }

        // Print the output signals
        printf("output_valid: %d\n", fed->output_valid);
        printf("raw_instr   : 0x%08x\n", fed->raw_instr);
        printf("instr_pc    : 0x%016llx\n", fed->instr_pc);
        printf("fu_choice   : %d\n", fed->fu_choice);

        i += 1;
    }

    std::cout << std::endl;

    fed->final();
    delete fed;
    delete contextp;

    return 0;
}