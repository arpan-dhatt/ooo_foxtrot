// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfed_stage.h for the primary calling header

#ifndef VERILATED_VFED_STAGE___024ROOT_H_
#define VERILATED_VFED_STAGE___024ROOT_H_  // guard

#include "verilated.h"


class Vfed_stage__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfed_stage___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    VL_OUT8(mem_ren,0,0);
    VL_IN8(mem_rvalid,0,0);
    VL_IN8(set_pc_valid,0,0);
    VL_OUT8(output_valid,0,0);
    VL_OUT8(fu_choice,1,0);
    CData/*0:0*/ fed_stage__DOT__irb_valid;
    CData/*1:0*/ fed_stage__DOT__ifu_choice;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    VL_OUT(raw_instr,31,0);
    IData/*31:0*/ fed_stage__DOT__iraw_instr;
    IData/*31:0*/ __VactIterCount;
    VL_OUT64(mem_raddr,63,0);
    VL_IN64(mem_rdata,63,0);
    VL_IN64(set_pc,63,0);
    VL_OUT64(instr_pc,63,0);
    QData/*63:0*/ fed_stage__DOT__pc;
    QData/*63:0*/ fed_stage__DOT__irb;
    VL_OUT8(arn_inputs[3],5,0);
    VL_OUT8(arn_outputs[3],5,0);
    VlUnpacked<CData/*5:0*/, 3> fed_stage__DOT__iarn_inputs;
    VlUnpacked<CData/*5:0*/, 3> fed_stage__DOT__iarn_outputs;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfed_stage__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfed_stage___024root(Vfed_stage__Syms* symsp, const char* v__name);
    ~Vfed_stage___024root();
    VL_UNCOPYABLE(Vfed_stage___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
