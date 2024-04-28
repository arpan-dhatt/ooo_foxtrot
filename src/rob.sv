module rob #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3
) (
    input logic clk,
    input logic rst,

    input logic inst_valid,
    input logic [32:0] inst,
    input logic [63:0] inst_lrn_input[MAX_OPERANDS],
    input logic [63:0] inst_lrn_output[MAX_OPERANDS],

    output logic rob_full
);

localparam ROB_STATE_ISSUE = 0;
localparam ROB_STATE_EXECUTE = 1;
localparam ROB_STATE_WRITE = 2;
localparam ROB_STATE_COMMIT = 3;

typedef struct {
    logic [1:0] state;
    logic [32:0] inst;
    logic [63:0] lrn_input[MAX_OPERANDS];
    logic [63:0] lrn_output[MAX_OPERANDS];
} ROBEntry;

// circular buffer
ROBEntry buffer[1 << INST_ID_BITS];
logic [INST_ID_BITS-1:0] head = 0;
logic [INST_ID_BITS-1:0] tail = 0;

always_ff @(posedge clk)
begin
    if (rst) begin
        // reset queue
        head <= 0;
        tail <= 0;
        rob_full <= 0;
    end else if (inst_valid && !rob_full) begin
        // insert stuff into buffer
        buffer[head].state <= ROB_STATE_ISSUE;
        buffer[head].inst <= inst;
        buffer[head].lrn_input[0] <= inst_lrn_input[0];
        buffer[head].lrn_input[1] <= inst_lrn_input[1];
        buffer[head].lrn_input[2] <= inst_lrn_input[2];
        buffer[head].lrn_output[0] <= inst_lrn_output[0];
        buffer[head].lrn_output[1] <= inst_lrn_output[1];
        buffer[head].lrn_output[2] <= inst_lrn_output[2];

        head <= head + 1;
        rob_full <= head + 1 == tail;
    end
end


endmodule
