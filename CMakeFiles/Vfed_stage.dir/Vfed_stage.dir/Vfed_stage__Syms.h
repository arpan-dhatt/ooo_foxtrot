// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VFED_STAGE__SYMS_H_
#define VERILATED_VFED_STAGE__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vfed_stage.h"

// INCLUDE MODULE CLASSES
#include "Vfed_stage___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vfed_stage__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vfed_stage* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vfed_stage___024root           TOP;

    // CONSTRUCTORS
    Vfed_stage__Syms(VerilatedContext* contextp, const char* namep, Vfed_stage* modelp);
    ~Vfed_stage__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
