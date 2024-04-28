// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VFU_LOGICAL__SYMS_H_
#define VERILATED_VFU_LOGICAL__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vfu_logical.h"

// INCLUDE MODULE CLASSES
#include "Vfu_logical___024root.h"
#include "Vfu_logical_fu_if.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vfu_logical__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vfu_logical* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vfu_logical___024root          TOP;
    Vfu_logical_fu_if              TOP__fu_logical_wrap__DOT__fu_if_inst;

    // CONSTRUCTORS
    Vfu_logical__Syms(VerilatedContext* contextp, const char* namep, Vfu_logical* modelp);
    ~Vfu_logical__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
