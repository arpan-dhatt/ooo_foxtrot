    // Arithmetic FU wrapper to expose fu_if.ctrl for verilator

module arith_fuq_wrap #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
    ) (
    input logic clk,
    input logic rst,

    // IQ control
    input logic inst_valid,
    output logic queue_ready,

    // // Input arguments
    // input logic [INST_ID_BITS-1:0] inst_id,
    // input logic [31:0] inst,
    // input logic [63:0] op[MAX_OPERANDS],
    // input logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS],
    // input logic [63:0] pc,
    // input logic inst_valid,
    
    // New Input 
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] raw_instr,
    input logic [63:0] instr_pc,
    input logic prn_input_valid[MAX_OPERANDS],
    input logic prn_input_ready[MAX_OPERANDS], // Ready to read from PRF
    input logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    input logic prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // PRN peek input
    input logic peek_valid,
    input logic [PRN_BITS-1:0] peek_prn,
    input logic [63:0] peek_value,

    // Register File ports
    input logic prf_op[MAX_OPERANDS],
    output logic prf_read_enable[MAX_OPERANDS],
    output logic prf_read_prn[MAX_OPERANDS],

    // // Output arguments
    output logic [PRN_BITS-1:0] fu_out_prn[MAX_OPERANDS],
    output logic [63:0] fu_out_data[MAX_OPERANDS],
    output logic fu_out_data_valid[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0] fu_out_inst_id,
    output logic fu_out_valid
    );

    // Instantiate the fu_if interface
    fu_if #(
        .INST_ID_BITS(INST_ID_BITS),
        .PRN_BITS(PRN_BITS),
        .MAX_OPERANDS(MAX_OPERANDS)
    ) fu_if_inst (
        .clk(clk),
        .rst(rst)
    );

    issue_queue arith_queue (
        .queue_ready(queue_ready),

        // Instruction receive
        .inst_valid(inst_valid),
        .inst_id(inst_id),
        .raw_instr(raw_instr),
        .instr_pc(instr_pc),
        .prn_input_valid(prn_input_valid),
        .prn_input_ready(prn_input_ready),
        .prn_input(prn_input),
        .prn_output_valid(prn_output_valid),
        .prn_output(prn_output),

        // PRN peek
        .peek_valid(peek_valid),
        .peek_prn(peek_prn),
        .peek_value(peek_value),

        // PRF ports
        .prf_op(prf_op),
        .prf_read_enable(prf_read_enable),
        .prf_read_prn(prf_read_prn),


        .ctrl(fu_if_inst.ctrl)
    );

    // Instantiate the fu_arith module
    fu_arith fu_arith_inst (
        .fu(fu_if_inst.fu)
    );

    // Connect the output arguments from the fu_if.fu ports
    assign fu_out_prn = fu_if_inst.fu_out_prn;
    assign fu_out_data = fu_if_inst.fu_out_data;
    assign fu_out_data_valid = fu_if_inst.fu_out_data_valid;
    assign fu_out_inst_id = fu_if_inst.fu_out_inst_id;
    assign fu_out_valid = fu_if_inst.fu_out_valid;

endmodule: arith_fuq_wrap