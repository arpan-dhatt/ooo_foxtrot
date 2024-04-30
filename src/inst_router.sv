module inst_router #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4,
                     parameter FUC_BITS = 2)
    (
    input logic clk,
    input logic rst,

    // Instruction passthrough
    input logic input_inst_valid,
    input logic [INST_ID_BITS-1:0] input_inst_id,
    input logic [31:0] input_raw_instr,
    input logic [63:0] input_instr_pc,
    input logic [FUC_BITS-1:0] input_fu_choice,
    input logic input_prn_input_valid[MAX_OPERANDS],
    input logic input_prn_input_ready[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_input[MAX_OPERANDS],
    input logic input_prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] input_prn_output[MAX_OPERANDS]

    // LSU memory read/write passthrough
    output logic mem_ren,           // Memory read enable signal
    output logic [63:0] mem_raddr,  // Memory read address
    input logic mem_rvalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_rdata,   // Memory read data
    output logic mem_wen,           // Memory write enable signal
    output logic [63:0] mem_waddr,  // Memory write address
    output logic [63:0] mem_wdata,  // Memory write data
    // To LSU, for when to retire stores
    input logic retire_inst_valid,
    input logic [INST_ID_BITS-1:0] retire_inst_id,
    // If we flushed instead of retired
    input logic retire_inst_flush,


    // prn ready bits from all functional units
    output logic set_prn_ready[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] set_prn[FU_COUNT][MAX_OPERANDS],

    // whether each functional unit queue has space for another instruction
    output logic queue_ready[FU_COUNT],

    // Register File ports per functional unit
    input logic [63:0] prf_op[FU_COUNT][MAX_OPERANDS],
    output logic prf_read_enable[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_read_prn[FU_COUNT][MAX_OPERANDS],
    // register file write ports
    output logic [63:0] prf_write_data[FU_COUNT][MAX_OPERANDS],
    output logic prf_write_enable[FU_COUNT][MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prf_write_prn[FU_COUNT][MAX_OPERANDS],

    // out instruction_ids for each functional unit
    output logic fu_out_inst_valid[FU_COUNT]
    output logic [INST_ID_BITS-1:0] fu_out_inst_ids[FU_COUNT]
);

typedef struct {
    logic inst_valid,
    logic [INST_ID_BITS-1:0] inst_id,
    logic [31:0] raw_instr,
    logic [63:0] instr_pc,
    logic prn_input_valid[MAX_OPERANDS],
    logic prn_input_ready[MAX_OPERANDS],
    logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    logic prn_output_valid[MAX_OPERANDS],
    logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS]
} DemuxChannel;
logic DemuxChannel inst_demux[FU_COUNT]; 

// instruction routing
always_comb begin
    for (int i = 0; i < FU_COUNT; i++) begin
        if (input_inst_valid) begin
            if (input_fu_choice == i) begin
                inst_demux[i].inst_valid = input_inst_valid;
                inst_demux[i].inst_id = input_inst_id;
                inst_demux[i].raw_instr = input_raw_instr;
                inst_demux[i].instr_pc = input_instr_pc;
                inst_demux[i].prn_input_valid = input_prn_input_valid;
                inst_demux[i].prn_input_ready = input_prn_input_ready;
                inst_demux[i].prn_input = input_prn_input;
                inst_demux[i].prn_output_valid = input_prn_output_valid;
                inst_demux[i].prn_output = input_prn_output;
            end else begin
                inst_demux[i].inst_valid = '0;
            end
        end
    end
end

endmodule: inst_router