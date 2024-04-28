// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary model header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef VERILATED_VFU_LSU_H_
#define VERILATED_VFU_LSU_H_  // guard

#include "verilated.h"

class Vfu_lsu__Syms;
class Vfu_lsu___024root;
class Vfu_lsu_fu_if;


// This class is the main interface to the Verilated model
class alignas(VL_CACHE_LINE_BYTES) Vfu_lsu VL_NOT_FINAL : public VerilatedModel {
  private:
    // Symbol table holding complete model state (owned by this class)
    Vfu_lsu__Syms* const vlSymsp;

  public:

    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(&clk,0,0);
    VL_IN8(&rst,0,0);
    VL_IN8(&inst_id,5,0);
    VL_IN8(&inst_valid,0,0);
    VL_IN8(&mem_rvalid,0,0);
    VL_OUT8(&fu_out_inst_id,5,0);
    VL_OUT8(&fu_out_valid,0,0);
    VL_OUT8(&fu_ready,0,0);
    VL_OUT8(&mem_ren,0,0);
    VL_OUT8(&mem_wen,0,0);
    VL_IN(&inst,31,0);
    VL_IN64(&pc,63,0);
    VL_IN64(&mem_rdata,63,0);
    VL_OUT64(&mem_raddr,63,0);
    VL_OUT64(&mem_waddr,63,0);
    VL_OUT64(&mem_wdata,63,0);
    VL_IN64((&op)[3],63,0);
    VL_IN8((&out_prn)[3],5,0);
    VL_OUT8((&fu_out_prn)[3],5,0);
    VL_OUT64((&fu_out_data)[3],63,0);
    VL_OUT8((&fu_out_data_valid)[3],0,0);

    // CELLS
    // Public to allow access to /* verilator public */ items.
    // Otherwise the application code can consider these internals.
    Vfu_lsu_fu_if* const __PVT__fu_lsu_wrap__DOT__fu_if_inst;

    // Root instance pointer to allow access to model internals,
    // including inlined /* verilator public_flat_* */ items.
    Vfu_lsu___024root* const rootp;

    // CONSTRUCTORS
    /// Construct the model; called by application code
    /// If contextp is null, then the model will use the default global context
    /// If name is "", then makes a wrapper with a
    /// single model invisible with respect to DPI scope names.
    explicit Vfu_lsu(VerilatedContext* contextp, const char* name = "TOP");
    explicit Vfu_lsu(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    virtual ~Vfu_lsu();
  private:
    VL_UNCOPYABLE(Vfu_lsu);  ///< Copying not allowed

  public:
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    /// Are there scheduled events to handle?
    bool eventsPending();
    /// Returns time at next time slot. Aborts if !eventsPending()
    uint64_t nextTimeSlot();
    /// Trace signals in the model; called by application code
    void trace(VerilatedTraceBaseC* tfp, int levels, int options = 0) { contextp()->trace(tfp, levels, options); }
    /// Retrieve name of this model instance (as passed to constructor).
    const char* name() const;

    // Abstract methods from VerilatedModel
    const char* hierName() const override final;
    const char* modelName() const override final;
    unsigned threads() const override final;
    /// Prepare for cloning the model at the process level (e.g. fork in Linux)
    /// Release necessary resources. Called before cloning.
    void prepareClone() const;
    /// Re-init after cloning the model at the process level (e.g. fork in Linux)
    /// Re-allocate necessary resources. Called after cloning.
    void atClone() const;
  private:
    // Internal functions - trace registration
    void traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options);
};

#endif  // guard
