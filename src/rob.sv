module rob #(
    parameter INST_ID_BITS = 6,
    parameter PRN_BITS = 6,
    parameter MAX_OPERANDS = 3,
    parameter FU_COUNT = 4
) (
    input logic clk,
    input logic rst,

    // Renamer dispatch
    input logic inst_valid,
    output logic inst_ready,
    input logic [63:0] pc,
    // Note that these mappings are what was ovewritten by this instruction, not what it actually maps to
    input logic mapping_inputs_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] mapping_inputs_prn[MAX_OPERANDS],
    input logic [32:0] mapping_inputs_arn[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0]new_inst_id,

    // Freed prns for the renamer
    output logic freed_prns_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] freed_prns[MAX_OPERANDS],

    // From FUs
    input logic fu_out_inst_valid[FU_COUNT],
    input logic [INST_ID_BITS-1:0] fu_out_inst_ids[FU_COUNT]
);

localparam ROB_STATE_ISSUED = 0;
localparam ROB_STATE_COMMITED = 1;
localparam ROB_STATE_RETIRE = 2;

typedef struct {
    logic [1:0] state;
    logic [63:0] pc;
    logic mapping_valid[MAX_OPERANDS];
    logic [PRN_BITS-1:0] mapping_prn[MAX_OPERANDS];
    logic [32:0] mapping_arn[MAX_OPERANDS];
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
        inst_ready <= 0;
    end else begin
        if (inst_valid && inst_ready) begin
            // insert stuff into buffer
            buffer[head].state <= ROB_STATE_ISSUED;
            buffer[head].pc <= pc;
            for (int i = 0; i < MAX_OPERANDS; i++) begin
                buffer[head].mapping_valid[i] <= mapping_inputs_valid[i];
                buffer[head].mapping_prn[i] <= mapping_inputs_prn[i];
                buffer[head].mapping_arn[i] <= mapping_inputs_arn[i];
            end

            new_inst_id <= head;

            head <= head + 1;
            inst_ready <= head + 1 != tail;
        end
        if (tail != head && buffer[tail].state == ROB_STATE_COMMITED) begin
            // commit
            for (int i = 0; i < MAX_OPERANDS; i++) begin
                freed_prns_valid[i] <= buffer[tail].mapping_valid[i];
                freed_prns[i] <= buffer[tail].mapping_prn[i];
            end
            $display("Committing instruction at %0d", buffer[tail].pc);

            tail <= tail + 1;
            inst_ready <= 1;
        end
        for (int i = 0; i < FU_COUNT; i++) begin
            if (fu_out_inst_valid[i]) begin
                buffer[fu_out_inst_ids[i]].state <= ROB_STATE_COMMITED;
            end
        end
    end
end


endmodule
