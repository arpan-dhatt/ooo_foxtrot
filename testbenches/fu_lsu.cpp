#include <verilated.h>
#include <sstream>
#include <cassert>
#include <vector>
#include <array>
#include <fstream>
#include <iostream>

#include "Vfu_lsu.h"
#include "support/memory.h"
#include "support/fu_test.h"

#define EXIT_ON_ERROR

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <test_directory_path>"
                  << std::endl;
        return 1;
    }

    std::string directory_path = argv[1];
    std::string elf_file_path = directory_path + "/prog.elf";

    auto *const contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    auto *const fu = new Vfu_lsu{contextp};

    // Use dummy memory array to load our ELF into (has instructions we're using)
    // Create memory instance
    constexpr size_t MEMORY_SIZE = 4 * 1024;  // 4 KiB
    constexpr size_t MEMORY_LATENCY = 10;  // 10 cycles latency
    Memory memory(MEMORY_SIZE, MEMORY_LATENCY);

    if (std::ifstream(elf_file_path).good()) {
        std::cout << "Loading ELF file:" << elf_file_path
                  << std::endl;
        memory.load_elf(elf_file_path);
    } else {
        throw std::invalid_argument("ELF file doesn't exist");
    }

    // Reset module
    fu->clk = 0;
    fu->eval();
    fu->rst = 1;
    fu->clk = 1;
    fu->eval();
    fu->rst = 0;
    fu->clk = 0;
    fu->eval();

    std::vector<testcase> tc = {
        {testcase_input({0x1000, 0x1, 0x1}, {1, 0, 0}),
         testcase_output({0x5}, {true, false, false})},
    }

    int i = 0;
    uint64_t pc = 0x8;
    uint32_t inst = *(uint32_t *) (memory.data + pc);
    while (inst != 0xd4400000) {
        std::cout << std::dec << "Instr [tc: " << i << "][pc: 0x" << std::hex << pc << "] " << inst << " ";

        // didn't have a corresponding testcase for this instruction from ELF file
        if (i >= testcases.size()) {
            std::cout << "ABORTED (testcases vector exhausted)" << std::endl;
            break;
        }

        // set input ports for fu
        testcases[i].input.insert(fu, inst, pc);

        // cycle clock once to insert this instruction
        fu->clk ^= 1;
        fu->eval();
        fu->clk ^= 1;
        fu->eval();

        // cycle clock until fu_out_valid
        while (!fu->fu_out_valid) {
            // set inst_valid to false to not keep inserting same instruction
            fu->inst_valid = false;
            fu->clk ^= 1;
            fu->eval();
            fu->clk ^= 1;
            fu->eval();
        }

#ifndef EXIT_ON_ERROR
        try {
#endif
            testcases[i].output.check(fu, testcases[i].input);
            std::cout << "SUCCESS" << std::endl;
#ifndef EXIT_ON_ERROR
        } catch (const std::runtime_error& err) {
            std::cout << "FAILURE" << std::endl;
        }
#endif

        // advance to next instruction
        pc += 0x4;
        i += 1;
        inst = *(uint32_t *) (memory.data + pc);
    }

    delete fu;
    delete contextp;
}