module fed_stage #(
    parameter MAX_OPERANDS=3,
    parameter ARN_BITS=6,
    parameter FU_COUNT=4
) (
    input logic clk,
    input logic rst,

    output logic mem_rien,           // Memory read enable signal
    output logic [63:0] mem_riaddr,  // Memory read address
    input logic mem_rivalid,         // Indicates when memory read data is valid
    input logic [63:0] mem_ridata,   // Memory read data

    input logic set_pc_valid,
    input logic [63:0] set_pc,

    output logic output_valid,
    output logic [31:0] raw_instr,
    output logic [63:0] instr_pc,
    output logic [FUC_BITS-1:0] fu_choice,
    output logic [ARN_BITS-1:0] arn_inputs[MAX_OPERANDS],
    output logic [ARN_BITS-1:0] arn_outputs[MAX_OPERANDS]
);

localparam FUC_BITS = $clog2(FU_COUNT);

logic [63:0] pc;

logic [FUC_BITS-1:0] ifu_choice;
logic [ARN_BITS-1:0] iarn_inputs[MAX_OPERANDS];
logic [ARN_BITS-1:0] iarn_outputs[MAX_OPERANDS];
inst_decoder #(MAX_OPERANDS) decoder (
    .instr_valid(mem_rivalid),
    .raw_instr(mem_ridata),
    .fu_choice(ifu_choice),
    .arn_inputs(iarn_inputs),
    .arn_outputs(iarn_outputs)
);

// circular buffer for inflight reads
localparam IRFIFO_LEN = 4;
localparam IRFL_BITS = $clog2(IRFIFO_LEN);
logic [63:0] inflight_reads_fifo[IRFIFO_LEN];
logic [IRFL_BITS-1:0] irf_head;
logic [IRFL_BITS-1:0] irf_tail;
logic irf_full;
logic [IRFL_BITS:0] irf_len;

always_comb begin
    if (irf_head == irf_tail) begin
        irf_len = irf_full ? IRFIFO_LEN : 0;
    end else if (irf_head < irf_tail) begin
        irf_len = irf_tail - irf_head;
    end else begin
        irf_len = IRFIFO_LEN - (irf_head - irf_tail);
    end
end

always_ff @(posedge clk)
begin
    output_valid <= mem_rivalid && !rst;
    if (rst) begin
        $display("Resetting FED Stage");
        pc <= 8; // set pc back to 0x8
        // empty inflight reads buffer
        irf_head <= 0;
        irf_tail <= 0;
        irf_full <= 0;
    end else begin
        // send memory request if 
    end
end

endmodule
