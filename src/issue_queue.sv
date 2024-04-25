module issue_queue #(parameter INST_ID_BITS = 6,
                     parameter PRN_BITS = 6,
                     parameter MAX_OPERANDS = 3,
                     parameter QUEUE_SIZE = 5)
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


    IQentry queue[0: QUEUE_SIZE - 1];

    always_comb begin
        for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            // Determine state of queue
        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < QUEUE_SIZE - 1; i++) begin
            // TODO zero out entry
            end
        end else begin
        
            // Handle instruction receive
            if(queue_inst_valid && !queue_full) begin
            end

            // Handle prn status update
            if(result_valid) begin
            end

            // Issue instruction to attached fu if one is satisfied (zeroing out old entry)
                // Loop through entries checking for Ready state
        end
    end

endmodule: issue_queue