// Arithmetic FU wrapper to expose fu_if.ctrl for verilator

module arith_fuq_wrap #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3,
    parameter FU_COUNT = 4,
    parameter FU_INDEX = 2
    ) (
    input logic clk,
    input logic rst,

    // IQ control
    input logic inst_valid,
    output logic queue_ready,
    
    // Input from instruction router
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] raw_instr,
    input logic [63:0] instr_pc,
    input logic prn_input_valid[MAX_OPERANDS],
    input logic prn_input_ready[MAX_OPERANDS], // Ready to read from PRF
    input logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    input logic prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // 
    input logic set_prn_ready[FU_COUNT - 1][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] set_prn[FU_COUNT - 1][MAX_OPERANDS],

    // register file ports
    input logic [63:0] prf_op[max_operands],
    output logic prf_read_enable[max_operands],
    output logic [PRN_BITS-1:0] prf_read_prn[max_operands],

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

    logic full_set_prn_ready[FU_COUNT][MAX_OPERANDS];
    logic [PRN_BITS-1:0] full_set_prn[FU_COUNT][MAX_OPERANDS];
    always_comb begin
        for(int i = 0; i < FU_COUNT; i++) begin
            if(i == FU_INDEX) begin
                full_set_prn[i] = fu_arith_inst.fu.fu_out_prn;
                full_set_prn_ready[i] = fu_arith_inst.fu.fu_out_data_valid;
                
            end else begin
                full_set_prn[i] = set_prn[i - (i>FU_INDEX)];
                full_set_prn_ready[i] = set_prn_ready[i - (i>FU_INDEX)];
            end
        end
    end

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
        .set_prn_ready(full_set_prn_ready),
        .set_prn(full_set_prn),

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