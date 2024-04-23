/*
Instruction decoder which chooses FU's and how many and which registers are needed.

Logical Register number explanation:
0-31: actual logical registers (x31 always equals sp)
32: flag register (always set to last lrn_input or lrn_output)
63: zero register (used for instructions which use x31 as XZR)

FU Choice:
0: Logical
1: LSU
2: ALU
3: DPI
*/


module inst_decoder #(
    parameter MAX_OPERANDS = 3
) (
    input logic instr_valid,       // if we have an output
    input logic [31:0] raw_instr,  // raw instruction
    output logic [2:0] fu_choice,   // which functional unit this instr goes to
    output logic [5:0] lrn_inputs[MAX_OPERANDS], // logical registers for input
    output logic [5:0] lrn_outputs[MAX_OPERANDS] // logic registers for output
);

  /* LOGICAL */
  // CSEL
  localparam [10:0] CSEL3121 = 11'b10011010100;
  localparam [1:0] CSEL1110 = 2'b00;

  // CSINC, CSET, CINC
  localparam [10:0] CSINC3121 = 11'b10011010100;
  localparam [1:0] CSINC1110 = 2'b01;

  // CSINV, CSETM, CINV
  localparam [10:0] CSINV3121 = 11'b11011010100;
  localparam [1:0] CSINV1110 = 2'b00;

  // CSNEG, CNEG
  localparam [10:0] CSNEG3121 = 11'b11011010100;
  localparam [1:0] CSNEG1110 = 2'b01;

  // MVN
  localparam [10:0] MVN3121 = 11'b10101010001;
  localparam [10:0] MVN1505 = 11'b00000011111;

  // ORR
  localparam [10:0] ORR3121 = 11'b10101010000;
  localparam [5:0] ORR1510 = 6'b000000;

  // EOR
  localparam [10:0] EOR3121 = 11'b11001010000;
  localparam [5:0] EOR1510 = 6'b000000;

  // AND
  localparam [8:0] AND3123 = 9'b100100100;

  // ANDS, TST
  localparam [10:0] ANDS3121 = 11'b11101010000;
  localparam [5:0] ANDS1510 = 6'b000000;

  // SBFM, ASR
  localparam [8:0] SBFM3123 = 9'b100100110;

  // UBFM, LSL, LSR
  localparam [8:0] UBFM3123 = 9'b110100110;

  /* LSU */
  localparam [10:0] LDUR3121 = 11'b11111000010;
  localparam [10:0] STUR3121 = 11'b11111000000;
  localparam [9:0] LDP3122 = 10'b1010100101;
  localparam [9:0] STP3122 = 10'b1010100100;

  /* ARITH */
  // ADD
  localparam [31:22] ADD_31_22 = 10'b1001000100;

  // ADDS
  localparam [31:21] ADDS_31_21 = 11'b10101011000;
  localparam [15:10] ADDS_15_10 = 6'b000000;

  // SUB
  localparam [31:22] SUB_31_22 = 10'b1101000100;

  // SUBS, CMP
  localparam [31:21] SUBS_31_21 = 11'b11101011000;
  localparam [15:10] SUBS_15_10 = 6'b000000;

  /* REG MOV */
  localparam [31:23] MOVK_3123 = 9'b111100101;
  localparam [31:23] MOVZ_3123 = 9'b110100101;
  localparam ADR_31 = 'b0;
  localparam [28:24] ADR_2824 = 5'b10000;
  localparam ADRP_31 = 'b1;
  localparam [28:24] ADRP_2824 = ADR_2824;


  // sets LRN based on chosen instruction format
  localparam [4:0] M_fmt  = 0;
  localparam [4:0] M2_fmt = 1;
  localparam [4:0] I1_fmt = 2;
  localparam [4:0] I2_fmt = 3;
  localparam [4:0] RC_fmt = 4;
  localparam [4:0] RR_fmt = 6;
  localparam [4:0] RI_fmt = 5;
  localparam [4:0] B1_fmt = 7;
  localparam [4:0] B3_fmt = 8;
  localparam [4:0] B2_fmt = 9;
  localparam [4:0] S_fmt  = 10;
  logic [4:0] instr_format;
  logic zero_reg; // replaces x31 regs with zero LRN
  logic input_flag; // puts flag reg in final LRN input
  logic output_flag; // puts flag reg in final LRN output
  always_comb begin
    lrn_outputs = {0, 0, 0};

    if (instr_format == M_fmt) begin
        lrn_inputs = {
            {zero_reg && raw_instr[9:5] == 31 ? 1'b1 : 1'b0, raw_instr[9:5]},
            0,
            input_flag ? 32 : 0
        };
        lrn_outputs = {
            {zero_reg && raw_instr[4:0] == 31 ? 1'b1 : 1'b0, raw_instr[4:0]},
            0,
            output_flag ? 32 : 0
        };
    end else if (instr_format == M_fmt) begin
        lrn_inputs = {
            {zero_reg && raw_instr[9:5] == 31 ? 1'b1 : 1'b0, raw_instr[9:5]},
            0,
            input_flag ? 32 : 0
        };
    end else if (instr_format == M2_fmt) begin
        lrn_inputs = {
            {zero_reg && raw_instr[9:5] == 31 ? 1'b1 : 1'b0, raw_instr[9:5]},
            0,
            input_flag ? 32 : 0
        };
        lrn_outputs = {
            {1'b0, raw_instr[4:0]},
            {1'b0, raw_instr[14:10]},
            output_flag ? 32 : 0
        };
    end else if (instr_format == I1_fmt || instr_format == I2_fmt) begin
        lrn_inputs = {0, 0, input_flag ? 32 : 0};
        lrn_outputs = {
            {zero_reg && raw_instr[4:0] == 31 ? 1'b1 : 1'b0, raw_instr[4:0]},
            0,
            output_flag ? 32 : 0
        };
    end else if (instr_format == RC_fmt || instr_format == RR_fmt) begin
        lrn_inputs = {
            {zero_reg && raw_instr[9:5] == 31 ? 1'b1 : 1'b0, raw_instr[9:5]},
            {zero_reg && raw_instr[20:16] == 31 ? 1'b1 : 1'b0, raw_instr[20:16]},
            input_flag ? 32 : 0
        };
        lrn_outputs = {
            {zero_reg && raw_instr[4:0] == 31 ? 1'b1 : 1'b0, raw_instr[4:0]},
            0,
            output_flag ? 32 : 0
        };
    end else if (instr_format == RI_fmt) begin
        lrn_inputs = {
            {zero_reg && raw_instr[9:5] == 31 ? 1'b1 : 1'b0, raw_instr[9:5]},
            0,
            input_flag ? 32 : 0
        };
        lrn_outputs = {
            {zero_reg && raw_instr[4:0] == 31 ? 1'b1 : 1'b0, raw_instr[4:0]},
            0,
            output_flag ? 32 : 0
        };
    end else begin
        lrn_inputs = {0, 0, 0};
        lrn_outputs = {0, 0, 0};
        $display("unimplemented instruction format");
    end
  end

  // main logic
  always_comb
  begin
      fu_choice = 0;
      instr_format = 0;
      lrn_inputs = {0, 0, 0};
      lrn_outputs = {0, 0, 0};
      zero_reg = 1'b1;
      input_flag = 0;
      output_flag = 0;
      if (instr_valid) begin
        // CSEL
        if (raw_instr[31:21] == CSEL3121 && raw_instr[11:10] == CSEL1110) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RC_fmt;
            input_flag = 1'b1; // conditional instruction
            output_flag = 1'b0;
        end
        // CSINC, CSET, CINC
        else if (raw_instr[31:21] == CSINC3121 && raw_instr[11:10] == CSINC1110) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RC_fmt;
            input_flag = 1'b1; // conditional instruction
            output_flag = 1'b0;
        end
        // CSINV, CSETM, CINV
        else if (raw_instr[31:21] == CSINV3121 && raw_instr[11:10] == CSINV1110) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RC_fmt;
            input_flag = 1'b1; // conditional instruction
            output_flag = 1'b0;
        end
        // CSNEG, CNEG
        else if (raw_instr[31:21] == CSNEG3121 && raw_instr[11:10] == CSNEG1110) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RC_fmt;
            input_flag = 1'b1; // conditional instruction
            output_flag = 1'b0;
        end
        // MVN
        else if (raw_instr[31:21] == MVN3121 && raw_instr[15:5] == MVN1505) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ORR
        else if (raw_instr[31:21] == ORR3121 && raw_instr[15:10] == ORR1510) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // EOR
        else if (raw_instr[31:21] == EOR3121 && raw_instr[15:10] == EOR1510) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // AND
        else if (raw_instr[31:23] == AND3123) begin
            // TODO: AND should use zero reg for input reg but SP for output reg!
            fu_choice = 3'b000; // Logical FU
            instr_format = RI_fmt;
            zero_reg = 1'b0;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ANDS, TST
        else if (raw_instr[31:21] == ANDS3121 && raw_instr[15:10] == ANDS1510) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b1; // sets flags
        end
        // SBFM, ASR
        else if (raw_instr[31:23] == SBFM3123) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RI_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // UBFM, LSL, LSR
        else if (raw_instr[31:23] == UBFM3123) begin
            fu_choice = 3'b000; // Logical FU
            instr_format = RI_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // LDUR
        else if (raw_instr[31:21] == LDUR3121) begin
            fu_choice = 3'b001; // LSU FU
            instr_format = M_fmt;
            zero_reg = 1'b0;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // STUR
        else if (raw_instr[31:21] == STUR3121) begin
            fu_choice = 3'b001; // LSU FU
            instr_format = M_fmt;
            zero_reg = 1'b0;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // LDP
        else if (raw_instr[31:22] == LDP3122) begin
            fu_choice = 3'b001; // LSU FU
            instr_format = M2_fmt;
            zero_reg = 1'b0;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // STP
        else if (raw_instr[31:22] == STP3122) begin
            fu_choice = 3'b001; // LSU FU
            instr_format = M2_fmt;
            zero_reg = 1'b0;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ADD
        else if (raw_instr[31:22] == ADD_31_22) begin
            fu_choice = 3'b010; // Arithmetic FU
            instr_format = RI_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ADDS
        else if (raw_instr[31:21] == ADDS_31_21 && raw_instr[15:10] == ADDS_15_10) begin
            fu_choice = 3'b010; // Arithmetic FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b1; // sets flags
        end
        // SUB
        else if (raw_instr[31:22] == SUB_31_22) begin
            fu_choice = 3'b010; // Arithmetic FU
            instr_format = RI_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // SUBS, CMP
        else if (raw_instr[31:21] == SUBS_31_21 && raw_instr[15:10] == SUBS_15_10) begin
            fu_choice = 3'b010; // Arithmetic FU
            instr_format = RR_fmt;
            input_flag = 1'b0;
            output_flag = 1'b1; // sets flags
        end
        // MOVK
        else if (raw_instr[31:23] == MOVK_3123) begin
            fu_choice = 3'b011; // Register Move FU
            instr_format = I1_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // MOVZ
        else if (raw_instr[31:23] == MOVZ_3123) begin
            fu_choice = 3'b011; // Register Move FU
            instr_format = I1_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ADR
        else if (raw_instr[31] == ADR_31 && raw_instr[28:24] == ADR_2824) begin
            fu_choice = 3'b011; // Register Move FU
            instr_format = I2_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
        // ADRP
        else if (raw_instr[31] == ADRP_31 && raw_instr[28:24] == ADRP_2824) begin
            fu_choice = 3'b011; // Register Move FU
            instr_format = I2_fmt;
            input_flag = 1'b0;
            output_flag = 1'b0;
        end
      end else begin
        fu_choice = 0;
        instr_format = 0;
        zero_reg = 0;
        input_flag = 0;
        output_flag = 0;
        lrn_inputs = {0, 0, 0};
        lrn_outputs = {0, 0, 0};
      end
  end
endmodule
