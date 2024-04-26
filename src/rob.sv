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
    input logic [5:0] mapping_inputs_arn[MAX_OPERANDS],
    output logic [INST_ID_BITS-1:0]new_inst_id,

    // Freed prns for the renamer
    output logic freed_prns_valid[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] freed_prns[MAX_OPERANDS],

    // From FUs
    input logic fu_out_inst_valid[FU_COUNT],
    input logic [INST_ID_BITS-1:0] fu_out_inst_ids[FU_COUNT],

    // To LSU, for when to retire stores
    output logic retire_inst_valid,
    output logic [INST_ID_BITS-1:0] retire_inst_id,
    // If we flushed instead of retired
    output logic retire_inst_flush,

    // From control flow to trigger a flush
    input logic start_flush,
    input logic [INST_ID_BITS-1:0] start_flush_to,

    // To the remap file, for undoing mappings because of a flush
    output logic reset_valid[MAX_OPERANDS],
    output logic [5:0] arn_reset[MAX_OPERANDS],
    output logic [PRN_BITS-1:0] prn_reset[MAX_OPERANDS],

    // For when we are flushing, we don't want to rename until we reset our mappings
    output logic stall_rename
);

localparam ROB_STATE_ISSUED = 0;
localparam ROB_STATE_COMMITED = 1;
localparam ROB_STATE_FLUSHED = 2;

typedef struct {
    logic [1:0] state;
    logic [63:0] pc;
    logic mapping_valid[MAX_OPERANDS];
    logic [PRN_BITS-1:0] mapping_prn[MAX_OPERANDS];
    logic [5:0] mapping_arn[MAX_OPERANDS];
} ROBEntry;

// circular buffer
ROBEntry buffer[1 << INST_ID_BITS];
logic [INST_ID_BITS-1:0] head = 0;
logic [INST_ID_BITS-1:0] tail = 0;
logic is_full;

function logic is_id_less_than(logic [INST_ID_BITS-1:0] id1, logic [INST_ID_BITS-1:0] id2);
    if (id1 == id2)
        return 0;
    else if (head > tail)
        return (id1 < id2) && (id1 >= tail || id2 < head);
    else
        return (id1 < id2) && (id1 >= tail && id2 < head);
endfunction

// Are we moving backwards to reset mappings?
logic is_flushing;
// Flush this instruction and all that come after
logic [INST_ID_BITS-1:0] flush_to_id;
logic [INST_ID_BITS-1:0] flush_pointer;
logic [INST_ID_BITS-1:0] flush_start;

assign inst_ready = !start_flush && !is_flushing && !is_full;
assign stall_rename = start_flush || is_flushing;

always_ff @(posedge clk)
begin
    if (rst) begin
        // reset queue
        head <= 0;
        tail <= 0;
        is_full <= 0;
        is_flushing <= 0;
        flush_to_id <= 0;
        flush_pointer <= 0;
        flush_start <= 0;

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
            is_full <= head + 1 == tail;
        end
        if (tail != head && (!is_flushing || tail != flush_to_id) && buffer[tail].state == ROB_STATE_COMMITED) begin
            // Retire
            for (int i = 0; i < MAX_OPERANDS; i++) begin
                freed_prns_valid[i] <= buffer[tail].mapping_valid[i];
                freed_prns[i] <= buffer[tail].mapping_prn[i];
            end
            $display("Retiring instruction at %0d", buffer[tail].pc);

            retire_inst_id <= tail;
            retire_inst_valid <= 1;
            retire_inst_flush <= 0;

            tail <= tail + 1;
            is_full <= 0;
        end
        for (int i = 0; i < FU_COUNT; i++) begin
            if (fu_out_inst_valid[i]) begin
                buffer[fu_out_inst_ids[i]].state <= ROB_STATE_COMMITED;
            end
        end

        if (start_flush) begin
            if (!is_flushing) begin
                is_flushing <= 1;
                flush_pointer <= head - 1;
                flush_start <= head - 1;
                flush_to_id <= start_flush_to;
                // We encode the flush target in the PC field, because if we
                // have to flush from an earlier instruction again after
                // finishing this one, we want to skip all the instructions we
                // already flushed.
                buffer[head - 1].pc <= {58'b0, start_flush_to};
            end else if (is_id_less_than(start_flush_to, flush_to_id)) begin
                flush_to_id <= start_flush_to;
                // Update the new end of this flush block
                buffer[flush_start].pc <= {58'b0, start_flush_to};
            end
        end
        if (is_flushing) begin
            if (buffer[flush_pointer].state == ROB_STATE_FLUSHED) begin
                // If we already flushed the instruction, we want to skip that block and move on
                // The end of the flush block should have been encoded in the PC
                // In the case of our implementation, this will likely never happen anyways
                flush_pointer <= buffer[flush_pointer].pc[5:0] - 1;
            end else begin
                buffer[flush_pointer].state <= ROB_STATE_FLUSHED;

                // Reset mappings
                // We free registers later through the normal retire process,
                // since issued instructions could still write to them
                for (int i = 0; i < MAX_OPERANDS; i++) begin
                    reset_valid[i] <= buffer[flush_pointer].mapping_valid[i];
                    arn_reset[i] <= buffer[flush_pointer].mapping_arn[i];
                    prn_reset[i] <= buffer[flush_pointer].mapping_prn[i];
                end

                // Flush from LSU
                // TODO: Instructions waiting in issue queue need to be dealt with
                retire_inst_id <= flush_pointer;
                retire_inst_valid <= 1;
                retire_inst_flush <= 1;
            end

            if (flush_pointer == flush_to_id && (!start_flush || is_id_less_than(start_flush_to, flush_to_id))) begin
                is_flushing <= 0;
            end else begin
                flush_pointer <= flush_pointer - 1;
            end
        end
    end
end


endmodule
