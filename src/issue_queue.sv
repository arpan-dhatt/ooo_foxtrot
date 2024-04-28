module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3, 
                     parameter QUEUE_SIZE = 4) // power of 2
    (
    input logic clk,
    input logic rst,

    // Issue queue control
    input logic queue_inst_valid,
    output logic queue_full,

    // Single instruction receive (From renamer)
    input logic [INST_ID_BITS-1:0] inst_id,  // Instruction ID
    input logic [31:0] inst,  // Instruction
    input logic [PRN_BITS-1:0] op_prn[MAX_OPERANDS],  // Input operand prns
    input logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS],  // Output physical register numbers
    input logic [63:0] pc,  // Program counter

    // Active prn status update (From all FUs)
    input logic result_valid,
    input logic [PRN_BITS-1:0] result_prn,
    // input logic [INST_ID_BITS-1:0] result_inst_id, // TODO: Might be the inst_id of the dependency instead of prn
    input logic [63:0] result_value,

    // FU control interface
    fu_if.ctrl ctrl

    );


    typedef struct packed {
        logic [1:0] state; // Ready (All deps satisfied), Waiting (Not all deps satisfied), Empty
        logic [INST_ID_BITS-1:0] inst_id;
        logic [31:0] inst;

        // Operand metadata and values
        logic                   op_valid[MAX_OPERANDS]; // Status for a single operand
        logic [PRN_BITS-1:0]    op_prn[MAX_OPERANDS]; // Which prn is it waiting on 
        // logic [INST_ID_BITS-1:0] op_inst_id; // TODO: Might be the inst_id of the dependency instead of prn
        logic [63:0]            op[MAX_OPERANDS]; // Value of a satisfied operand 

        // Additional pass-through data
        logic [PRN_BITS-1:0] out_prn[MAX_OPERANDS];  // Output physical register numbers
        logic [63:0] pc;  // Program counter
    } IQentry;

    localparam EMPTY_STATE = 2'b00;
    localparam WAITING_STATE = 2'b01;
    localparam READY_STATE = 2'b11;


    IQentry queue[0: QUEUE_SIZE - 1];

    always_comb begin
        for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            // Determine state of entry
            //queue[i].state[0] = queue[i].op_valid.or();
            //queue[i].state[1] = queue[i].op_valid.and();

        end

        queue_full = entry_count == QUEUE_SIZE;
        
    end

    logic [$clog2(QUEUE_SIZE) - 1: 0] entry_count;
    logic [$clog2(QUEUE_SIZE) - 1: 0] index;

    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            // TODO zero out entry correctly
                queue[i] <= '0;
                entry_count <= 0;
            end
        end else begin
        
            // Handle instruction receive
            if(queue_inst_valid && !queue_full) begin
                for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
                    if(queue[i].state == EMPTY_STATE) begin
                        // TODO insert

                        

                        entry_count <= entry_count + 1;
                        break;
                    end
                end
            end

            // Handle prn status update
            if(result_valid) begin
                
            end

            // Issue instruction to attached fu if one is Ready (zeroing out old entry)
                // Loop through entries checking for Ready state
            if(ctrl.fu_ready) begin
                for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
                    if(queue[(index + i) % QUEUE_SIZE].state == READY_STATE) begin
                        // inst_id, inst, op, out_prn, pc, inst_valid,

                        ctrl.inst_id <= queue[(index + i) % QUEUE_SIZE].inst_id;
                        ctrl.inst <= queue[(index + i) % QUEUE_SIZE].inst;
                        ctrl.op <= queue[(index + i) % QUEUE_SIZE].op;
                        ctrl.out_prn <= queue[(index + i) % QUEUE_SIZE].out_prn;
                        ctrl.pc <= queue[(index + i) % QUEUE_SIZE].pc;

                        ctrl.inst_valid <= 1'b1;

                        index <= (index + i) % QUEUE_SIZE; // Round robin

                        queue[(index + i) % QUEUE_SIZE] <= '0; // Empty the entry
                        break;
                    end
                end
            end
        end
    end

endmodule: issue_queue