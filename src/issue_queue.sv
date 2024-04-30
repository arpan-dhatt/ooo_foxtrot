module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3,
                     parameter QUEUE_SIZE = 4, // power of 2
                     parameter FU_COUNT = 4)
    (
    // Issue queue control
    input logic inst_valid,
    output logic queue_ready,

    // Single instruction receive (From renamer)
    input logic [INST_ID_BITS-1:0] inst_id,
    input logic [31:0] raw_instr,
    input logic [63:0] instr_pc,
    input logic prn_input_valid[MAX_OPERANDS],
    input logic prn_input_ready[MAX_OPERANDS], // Ready to read from PRF
    input logic [PRN_BITS-1:0] prn_input[MAX_OPERANDS],
    input logic prn_output_valid[MAX_OPERANDS],
    input logic [PRN_BITS-1:0] prn_output[MAX_OPERANDS],

    // Active prn status update (From all FUs)
    input logic set_prn_ready[FU_COUNT][MAX_OPERANDS],
    input logic [PRN_BITS-1:0] set_prn[FU_COUNT][MAX_OPERANDS],

    // FU control interface
    fu_if.ctrl ctrl,

    // Phy register file interface
    // outputs: enable, prn, inputs: prf_op,
    input logic [63:0] prf_op[MAX_OPERANDS],
    output logic prf_read_enable[MAX_OPERANDS],
    output logic [PRN_BITS - 1:0] prf_read_prn[MAX_OPERANDS]
    );


    typedef struct {
        logic valid;
        logic [INST_ID_BITS-1:0] inst_id;
        logic [31:0] inst;

        // Operand metadata and values
        logic                   op_valid[MAX_OPERANDS]; // Which operands are actually utilized
        logic                   op_ready[MAX_OPERANDS]; // Which operands are satisfied
        logic [PRN_BITS-1:0]    op_prn[MAX_OPERANDS]; // Which prn is it waiting on

        // Additional pass-through data
        logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS];  // Output physical register numbers
        logic [63:0] pc;  // Program counter
    } IQentry;


    // This is separate from the queue entry because it is assigned combinatorally
    logic entries_ready[0: QUEUE_SIZE - 1];
    IQentry queue[0: QUEUE_SIZE - 1];

    logic [$clog2(QUEUE_SIZE) - 1: 0]empty_slot;

    logic has_ready_instruction;
    IQentry ready_instruction;
    logic [$clog2(QUEUE_SIZE) - 1: 0]ready_instruction_i;
    always_comb begin
        // Keep track of which queue entries are ready (and valid)
        for(int i = 0; i < QUEUE_SIZE; i++) begin
            entries_ready[i] = queue[i].valid && MAX_OPERANDS'(queue[i].op_ready) == MAX_OPERANDS'(queue[i].op_valid);
        end

        // Find the first ready instruction
        has_ready_instruction = 0;
        ready_instruction_i = 0;
        ready_instruction = queue[ready_instruction_i];
        for(int i = 0; i < QUEUE_SIZE; i++) begin
            if(!has_ready_instruction && entries_ready[i]) begin
                // inst_id, inst, op, out_prn, pc, inst_valid,
                // ready_instruction.inst_id = queue[i].inst_id;
                // ready_instruction.inst = queue[i].inst;
                // ready_instruction.out_prn = queue[i].out_prn;
                // ready_instruction.op_valid = queue[i].op_valid;
                // ready_instruction.op_prn = queue[i].op_prn;
                // ready_instruction.pc = queue[i].pc;
                ready_instruction_i = 2'(i);
                has_ready_instruction = 1;
            end
        end

        // Ensures that operands in prf are ready when we hit insertion
        for (int i = 0; i < MAX_OPERANDS; i++) begin
            if (has_ready_instruction) begin
                prf_read_enable[i] = ready_instruction.op_ready[i];
                prf_read_prn[i] = ready_instruction.op_prn[i];
            end else begin
                prf_read_enable[i] = 0;
                prf_read_prn[i] = PRN_BITS'(0);
            end
        end

        // Is there an open spot in the queue and what is the idx
        queue_ready = 0;
        empty_slot = 0;
        for (int i = 0; i < QUEUE_SIZE; i++) begin
            if (!queue_ready && !queue[i].valid) begin
                queue_ready = 1;
                empty_slot = $clog2(QUEUE_SIZE)'(i);
            end
        end

    end

    always_ff @(posedge ctrl.clk) begin
        if(ctrl.rst) begin
            for(int i = 0; i < QUEUE_SIZE; i++) begin
                queue[i] <= '0;
            end
        end else begin

            // Handle instruction insert
            if(inst_valid && queue_ready) begin
                queue[empty_slot].valid <= 1;
                queue[empty_slot].inst_id <= inst_id;
                queue[empty_slot].inst <= raw_instr;

                for (int i = 0; i < MAX_OPERANDS; i++) begin
                    queue[empty_slot].op_valid[i] <= prn_input_valid[i];
                    queue[empty_slot].op_ready[i] <= prn_input_ready[i];
                    queue[empty_slot].op_prn[i] <= prn_input[i];

                    queue[empty_slot].out_prn[i] <= prn_output[i];
                end
                queue[empty_slot].pc <= instr_pc;
            end

            // Handle prn status update
            for(int i = 0; i < QUEUE_SIZE; i++) begin
                for(int k = 0; k < FU_COUNT; k++) begin
                    for(int j = 0; j < MAX_OPERANDS; j++) begin
                        if(queue[i].valid && queue[i].op_valid[j] && queue[i].op_prn[j] == set_prn[k][j] && set_prn_ready[k][j]) begin
                            queue[i].op_ready[j] <= 1'b1;
                        end
                    end
                end
            end

            // Issue instruction to attached fu if one is Ready (zeroing out old entry)
                // Loop through entries checking for Ready state
            if(ctrl.fu_ready && has_ready_instruction) begin
                //  inst_id, inst, op, out_prn, pc, inst_valid,
                ctrl.inst_id <= ready_instruction.inst_id;
                ctrl.inst <= ready_instruction.inst;
                ctrl.op <= prf_op; // TODO Might need to handle 0 register
                for (int i = 0; i < MAX_OPERANDS; i++) begin
                    ctrl.out_prn[i] <= ready_instruction.out_prn[i];
                end
                ctrl.pc <= ready_instruction.pc;

                ctrl.inst_valid <= 1'b1;

                queue[ready_instruction_i].valid <= 0; // Empty the entry
            end else begin
                ctrl.inst_valid <= '0;
            end
        end
    end

endmodule: issue_queue
