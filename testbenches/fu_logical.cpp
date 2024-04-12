#include <verilated.h>

#include "Vfu_logical.h"

int main(int argc, char** argv) {
    auto* const contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    auto* const fu = new Vfu_logical{contextp};

    delete fu;
    delete contextp;
}