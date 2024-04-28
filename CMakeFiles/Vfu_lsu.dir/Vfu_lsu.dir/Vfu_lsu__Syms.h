// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VFU_LSU__SYMS_H_
#define VERILATED_VFU_LSU__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vfu_lsu.h"

// INCLUDE MODULE CLASSES
#include "Vfu_lsu___024root.h"
#include "Vfu_lsu_fu_if.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vfu_lsu__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vfu_lsu* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vfu_lsu___024root              TOP;
    Vfu_lsu_fu_if                  TOP__fu_lsu_wrap__DOT__fu_if_inst;

    // CONSTRUCTORS
    Vfu_lsu__Syms(VerilatedContext* contextp, const char* namep, Vfu_lsu* modelp);
    ~Vfu_lsu__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
