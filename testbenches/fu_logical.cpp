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

    auto *const fu = new Vfu_logical{contextp};

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

    // mapping instruction inputs and expected outputs
    // third operand is always the flag register
    std::vector<testcase> testcases = {
        // CSEL
        {testcase_input({0x1, 0xD, 0xB}, {1, 0, 0}),
         testcase_output({0x1}, {true, false, false})},
        {testcase_input({0x2, 0xF, 0xB}, {1, 0, 0}),
         testcase_output({0xF}, {true, false, false})},
        {testcase_input({0x1, 0xD, 0x0}, {1, 0, 0}),
         testcase_output({0x1}, {true, false, false})},

         // CSINC
        {testcase_input({0x1, 0xD, 0xB}, {1, 0, 0}),
         testcase_output({0x1}, {true, false, false})},
        {testcase_input({0x2, 0xA, 0xB}, {1, 0, 0}),
         testcase_output({0xB}, {true, false, false})},
        {testcase_input({0x1, 0xD, 0x0}, {1, 0, 0}),
         testcase_output({0x1}, {true, false, false})},

         // CSINV
        {testcase_input({0x0, 0x0, 0xB}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},
        {testcase_input({0x0, 0x0, 0xB}, {1, 0, 0}),
         testcase_output({~(uint64_t)0}, {true, false, false})},
        {testcase_input({0x0, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},

         // CSNEG
        {testcase_input({0xA, 0x2, 0xB}, {1, 0, 0}),
         testcase_output({0xA}, {true, false, false})},
        {testcase_input({0xC, 0x4, 0xB}, {1, 0, 0}),
         testcase_output({~(uint64_t)0x4 + 1}, {true, false, false})},
        {testcase_input({0xB, 0x6, 0x0}, {1, 0, 0}),
         testcase_output({0xB}, {true, false, false})},

         // MVN
        {testcase_input({0xA, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({~(uint64_t)0xA}, {true, false, false})},
        {testcase_input({0xC, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({~(uint64_t)0xC}, {true, false, false})},
        {testcase_input({0xB, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({~(uint64_t)0xB}, {true, false, false})},

         // ORR
        {testcase_input({0b1010, 0b0101, 0x0}, {1, 0, 0}),
         testcase_output({0b1111}, {true, false, false})},
        {testcase_input({0xC, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0xC}, {true, false, false})},
        {testcase_input({0x0, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},

        // EOR
        {testcase_input({0b1010, 0b0101, 0x0}, {1, 0, 0}),
         testcase_output({0b1111}, {true, false, false})},
        {testcase_input({0b1111, 0xF, 0x0}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},
        {testcase_input({0x0, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},

        // AND
        {testcase_input({0xAB, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0xAB}, {true, false, false})},
        {testcase_input({0xAB, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0xA0}, {true, false, false})},
        {testcase_input({0xAB, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x0B}, {true, false, false})},

         // ANDS
        {testcase_input({~(uint64_t)0x0, ~(uint64_t)0x0, 0x0}, {1, 0, 15}),
         testcase_output({~(uint64_t)0, 0, 0b1000}, {true, false, true})},
        {testcase_input({0xAB, 0x0, 0x0}, {1, 0, 15}),
         testcase_output({0x00, 0, 0b0100}, {true, false, true})},
        {testcase_input({0xAB, 0x0B, 0x0}, {1, 0, 15}),
         testcase_output({0x0B, 0, 0b0000}, {true, false, true})},

         // SBFM (just testing ASR)
        {testcase_input({~(uint64_t)0x0, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({~(uint64_t)0x0}, {true, false, false})},
        {testcase_input({0x87654321, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x876543}, {true, false, false})},
        {testcase_input({0x1, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x0}, {true, false, false})},

         // UBFM (just testing LSL, LSR)
        {testcase_input({0xF, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0xF0}, {true, false, false})},
        {testcase_input({0xF00, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0xF0}, {true, false, false})},
        {testcase_input({0x1, 0x0, 0x0}, {1, 0, 0}),
         testcase_output({0x1llu << 31}, {true, false, false})},
    };

    // while loop through instructions starting at 0x8 until halt is reached
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