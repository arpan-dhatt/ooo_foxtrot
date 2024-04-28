// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfu_logical.h for the primary calling header

#ifndef VERILATED_VFU_LOGICAL_FU_IF_H_
#define VERILATED_VFU_LOGICAL_FU_IF_H_  // guard

#include "verilated.h"


class Vfu_logical__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfu_logical_fu_if final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    CData/*5:0*/ fu_out_inst_id;
    CData/*0:0*/ fu_out_valid;
    CData/*0:0*/ fu_ready;
    VlUnpacked<QData/*63:0*/, 3> op;
    VlUnpacked<CData/*5:0*/, 3> out_prn;
    VlUnpacked<CData/*5:0*/, 3> fu_out_prn;
    VlUnpacked<QData/*63:0*/, 3> fu_out_data;
    VlUnpacked<CData/*0:0*/, 3> fu_out_data_valid;

    // INTERNAL VARIABLES
    Vfu_logical__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfu_logical_fu_if(Vfu_logical__Syms* symsp, const char* v__name);
    ~Vfu_logical_fu_if();
    VL_UNCOPYABLE(Vfu_logical_fu_if);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};

std::string VL_TO_STRING(const Vfu_logical_fu_if* obj);

#endif  // guard
