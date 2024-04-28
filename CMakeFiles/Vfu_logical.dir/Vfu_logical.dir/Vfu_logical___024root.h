// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfu_logical.h for the primary calling header

#ifndef VERILATED_VFU_LOGICAL___024ROOT_H_
#define VERILATED_VFU_LOGICAL___024ROOT_H_  // guard

#include "verilated.h"
class Vfu_logical_fu_if;


class Vfu_logical__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfu_logical___024root final : public VerilatedModule {
  public:
    // CELLS
    Vfu_logical_fu_if* __PVT__fu_logical_wrap__DOT__fu_if_inst;

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    VL_IN8(inst_id,5,0);
    VL_IN8(inst_valid,0,0);
    VL_OUT8(fu_out_inst_id,5,0);
    VL_OUT8(fu_out_valid,0,0);
    VL_OUT8(fu_ready,0,0);
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__tmask_and;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__wmask_and;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__tmask_or;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__wmask_or;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__levels;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__s;
    CData/*5:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__r;
    CData/*6:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__andbd__DOT__diff;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    VL_IN(inst,31,0);
    IData/*31:0*/ __VactIterCount;
    VL_IN64(pc,63,0);
    QData/*63:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__dec_wmask;
    QData/*63:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT___dec_tmask;
    QData/*63:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__ANDint;
    QData/*63:0*/ fu_logical_wrap__DOT__fu_logical_inst__DOT__BFMout;
    VL_IN64(op[3],63,0);
    VL_IN8(out_prn[3],5,0);
    VL_OUT8(fu_out_prn[3],5,0);
    VL_OUT64(fu_out_data[3],63,0);
    VL_OUT8(fu_out_data_valid[3],0,0);
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfu_logical__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfu_logical___024root(Vfu_logical__Syms* symsp, const char* v__name);
    ~Vfu_logical___024root();
    VL_UNCOPYABLE(Vfu_logical___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
