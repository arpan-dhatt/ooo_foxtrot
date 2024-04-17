#include <verilated.h>
#include <sstream>
#include <cassert>
#include <vector>
#include <array>
#include <fstream>
#include <iostream>

#include "Vfu_logical.h"
#include "support/memory.h"
#include "support/fu_test.h"

// #define EXIT_ON_ERROR

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

    auto *const fu = new Vfu_logical{contextp};

    // Use dummy memory to get all of our instructions
    // Create memory instance
    constexpr size_t MEMORY_SIZE = 4 * 1024;  // 4 KiB
    constexpr size_t MEMORY_LATENCY = 10;  // 10 cycles latency
    Memory memory(MEMORY_SIZE, MEMORY_LATENCY);

    // Load memory contents from file if it exists
    if (std::ifstream(elf_file_path).good()) {
        std::cout << "Loading ELF file (ignoring .bin file):" << elf_file_path
                  << std::endl;
        memory.load_elf(elf_file_path);
    } else {
        throw std::invalid_argument("ELF file doesn't exist");
    }

    // Reset
    fu->clk = 0;
    fu->eval();
    fu->rst = 1;
    fu->clk = 1;
    fu->eval();
    fu->rst = 0;
    fu->clk = 0;
    fu->eval();

    // mapping instruction inputs and expected outputs
    // third operand is always the flag register
    std::vector<testcase> testcases = {
        {testcase_input({0x1, 0xD, 0xB}, {1, 0, 0}), // CSEL
         testcase_output({1, 0, 0}, {0x1, 0x0, 0x0}, {true, false, false})},
        {testcase_input({0x2, 0xF, 0xB}, {1, 0, 0}), // CSEL
         testcase_output({1, 0, 0}, {0xF, 0x0, 0x0}, {true, false, false})},
        {testcase_input({0x1, 0xD, 0x0}, {1, 0, 0}), // CSEL
         testcase_output({1, 0, 0}, {0x1, 0x0, 0x0}, {true, false, false})},
    };

    // while loop through instructions starting at 0x8 until halt is reached
    int i = 0;
    uint64_t pc = 0x8;
    uint32_t inst = *(uint32_t *) (memory.data + pc);
    while (inst != 0xd4400000) {
        std::cout << "Instr [0x" << std::hex << pc << "] " << inst << " ";

        if (i >= testcases.size()) {
            std::cout << "ABORTED (testcases vector exhausted)" << std::endl;
            break;
        }

        // set values in fu
        testcases[i].input.insert(fu, inst, pc);

        // cycle clock once to insert this instruction
        fu->clk ^= 1;
        fu->eval();
        fu->clk ^= 1;
        fu->eval();

        // cycle clock until fu_out_valid)
        while (!fu->fu_out_valid) {
            // set inst valid to false to not keep inserting same instruction
            fu->inst_valid = false;
            fu->clk ^= 1;
            fu->eval();
            fu->clk ^= 1;
            fu->eval();
        }

        try {
            testcases[i].output.check(fu, testcases[i].input, inst);
            std::cout << "SUCCESS" << std::endl;
        } catch (const std::runtime_error& err) {
#ifdef EXIT_ON_ERROR
            throw err;
#endif
            std::cout << "FAILURE" << std::endl;
        }

        // advance to next instruction
        pc += 0x4;
        i += 1;
        inst = *(uint32_t *) (memory.data + pc);
    }

    delete fu;
    delete contextp;
}