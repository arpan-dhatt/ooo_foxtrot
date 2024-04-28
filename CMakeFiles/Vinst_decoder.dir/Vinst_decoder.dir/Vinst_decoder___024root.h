// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vinst_decoder.h for the primary calling header

#ifndef VERILATED_VINST_DECODER___024ROOT_H_
#define VERILATED_VINST_DECODER___024ROOT_H_  // guard

#include "verilated.h"


class Vinst_decoder__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vinst_decoder___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(instr_valid,0,0);
    VL_OUT8(fu_choice,1,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    VL_IN(raw_instr,31,0);
    IData/*31:0*/ __VactIterCount;
    VL_OUT8(arn_inputs[3],5,0);
    VL_OUT8(arn_outputs[3],5,0);
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vinst_decoder__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vinst_decoder___024root(Vinst_decoder__Syms* symsp, const char* v__name);
    ~Vinst_decoder___024root();
    VL_UNCOPYABLE(Vinst_decoder___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
