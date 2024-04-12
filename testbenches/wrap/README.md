# Wrapper Modules

Some of our modules in our CPU use SystemVerilog interfaces in their ports. Verilator doesn't support the top-level
module using interfaces, so we need to wrap those modules and expose the interface's logic again. `fu_logical_wrap.sv`
essentially repeats the definitions in `fu_if.ctrl` so our testbench can control the FU.

For some FU's you might be able to copy the `fu_logical_wrap.sv` (e.g. `fu_arith_wrap.sv`) and change the module
it's wrapping (near the bottom of the wrapper module). If your FU uses more ports than just the basic interface, like
the LSU, you can also expose those through the wrapper.