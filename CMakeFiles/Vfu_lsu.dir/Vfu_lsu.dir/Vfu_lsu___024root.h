// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfu_lsu.h for the primary calling header

#ifndef VERILATED_VFU_LSU___024ROOT_H_
#define VERILATED_VFU_LSU___024ROOT_H_  // guard

#include "verilated.h"
class Vfu_lsu_fu_if;


class Vfu_lsu__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfu_lsu___024root final : public VerilatedModule {
  public:
    // CELLS
    Vfu_lsu_fu_if* __PVT__fu_lsu_wrap__DOT__fu_if_inst;

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    VL_IN8(inst_id,5,0);
    VL_IN8(inst_valid,0,0);
    VL_IN8(mem_rvalid,0,0);
    VL_OUT8(fu_out_inst_id,5,0);
    VL_OUT8(fu_out_valid,0,0);
    VL_OUT8(fu_ready,0,0);
    VL_OUT8(mem_ren,0,0);
    VL_OUT8(mem_wen,0,0);
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_read;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_write;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_ldp;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__second_ldp;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_ldp_read;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_stp;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__second_stp;
    CData/*0:0*/ fu_lsu_wrap__DOT__fu_lsu_inst__DOT__pending_stp_write;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    VL_IN(inst,31,0);
    IData/*31:0*/ __VactIterCount;
    VL_IN64(pc,63,0);
    VL_IN64(mem_rdata,63,0);
    VL_OUT64(mem_raddr,63,0);
    VL_OUT64(mem_waddr,63,0);
    VL_OUT64(mem_wdata,63,0);
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
    Vfu_lsu__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfu_lsu___024root(Vfu_lsu__Syms* symsp, const char* v__name);
    ~Vfu_lsu___024root();
    VL_UNCOPYABLE(Vfu_lsu___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
