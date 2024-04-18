// Logical functional unit

module fu_logical (
    fu_if.fu fu
);

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

  // AND immediate bitmask decoder
  logic [63:0] dec_wmask, _dec_tmask;
  bitmask_decoder #(64) andbd (
    .immN(fu.inst[22]),
    .imms(fu.inst[15:10]),
    .immr(fu.inst[21:16]),
    .immediate(1'b1),
    .wmask(dec_wmask),
    .tmask(_dec_tmask)
  );

  // ANDS intermediate value to deal with condition codes
  logic [63:0] ANDint;
  always_comb begin
    assign ANDint = fu.op[0] & fu.op[1];
  end

  // SBFM/ASR calculation
  // SBFM/UBFM/ASR/LSL/LSR calculation
  logic [63:0] BFMout;
  logic [5:0] imm6r, imm6s;
  logic [6:0] bitfield_size;
  logic [7:0] bitfield_pos;
  logic [63:0] bitfield_mask, bitfield, sign_extended_bitfield;
  logic sign_bit;
  always_comb begin
    // Extract the immediate values from the instruction
    assign imm6r = fu.inst[16:11];
    assign imm6s = fu.inst[10:5];

    // Determine the bitfield size by subtracting imm6r from imm6s and adding 1
    assign bitfield_size = imm6s - imm6r + 1;

    // Create a mask for extracting the bitfield
    // The mask is created by shifting 1 to the left by bitfield_size and then subtracting 1
    assign bitfield_mask = (1 << bitfield_size) - 1;

    // Extract the bitfield from the source register using the mask and shift
    // First, shift the source register (fu.op[0]) right by imm6r to align the bitfield
    // Then, apply the bitfield_mask using a bitwise AND operation to extract the bitfield
    assign bitfield = (fu.op[0] >> imm6r) & bitfield_mask;

    // Determine the position to place the bitfield in the destination register
    // If imm6s is greater than or equal to imm6r, the bitfield is placed at the LSB of the destination register
    // If imm6s is less than imm6r, the bitfield is placed at position 64 - imm6r of the destination register
    assign bitfield_pos = (imm6s >= imm6r) ? 0 : (7'd64 - 7'(imm6r));

    // Sign-extend the bitfield for SBFM
    assign sign_bit = bitfield[bitfield_size-1];
    assign sign_extended_bitfield = (sign_bit ? ~((1 << bitfield_size) - 1) : 0) | bitfield;

    // Assign the bitfield to the BFMout variable based on the instruction type
    if (fu.inst[31:23] == SBFM3123) begin
      // SBFM instruction
      assign BFMout = sign_extended_bitfield << bitfield_pos;
    end else begin
      // UBFM/LSL/LSR instruction
      assign BFMout = bitfield << bitfield_pos;
    end
  end

  always_ff @(posedge fu.clk)
  begin
    if (fu.rst) begin
      // set outputs invalid and ready to 1
      fu.fu_out_valid <= 0;
      fu.fu_ready <= 1;
    end else if (fu.inst_valid) begin
      // input instruction is valid
      if (fu.inst[31:21] == CSEL3121 && fu.inst[11:10] == CSEL1110) begin
        // CSEL
        if (fu.inst[15:12] == fu.op[2][3:0]) begin
          // copy from Xn
          fu.fu_out_data[0] <= fu.op[0];
        end else begin
          // copy from Xm
          fu.fu_out_data[0] <= fu.op[1];
        end
        // Xd is in out_prn 0
      end else if (fu.inst[31:21] == CSINC3121 && fu.inst[11:10] == CSINC1110) begin
        // CSINC, CSET, CSINC
        if (fu.inst[15:12] == fu.op[2][3:0]) begin
          // copy from Xn
          fu.fu_out_data[0] <= fu.op[0];
        end else begin
          // copy from Xn and add 1
          fu.fu_out_data[0] <= fu.op[1] + 1;
        end
      end else if (fu.inst[31:21] == CSINV3121 && fu.inst[11:10] == CSINV1110) begin
        // CSINV, CSETM, CINV
        if (fu.inst[15:12] == fu.op[2][3:0]) begin
          // copy from Xn
          fu.fu_out_data[0] <= fu.op[0];
        end else begin
          // copy from ~Xn
          fu.fu_out_data[0] <= ~fu.op[1];
        end
      end else if (fu.inst[31:21] == CSNEG3121 && fu.inst[11:10] == CSNEG1110) begin
        // CSNEG, CNEG
        if (fu.inst[15:12] == fu.op[2][3:0]) begin
          // copy from Xn
          fu.fu_out_data[0] <= fu.op[0];
        end else begin
          // copy from -Xn (two's complement)
          fu.fu_out_data[0] <= ~fu.op[1] + 1;
        end
        fu.fu_out_prn[0] <= fu.out_prn[0];
      end else if (fu.inst[31:21] == MVN3121 && fu.inst[15:05] == MVN1505) begin
        // MVN
        fu.fu_out_data[0] <= ~fu.op[0]; // copy ~Xm to Xd
      end else if (fu.inst[31:21] == ORR3121 && fu.inst[15:10] == ORR1510) begin
        // ORR
        fu.fu_out_data[0] <= fu.op[0] | fu.op[1]; // Xd <= Xn | Xm
      end else if (fu.inst[31:21] == EOR3121 && fu.inst[15:10] == EOR1510) begin
        // EOR
        fu.fu_out_data[0] <= fu.op[0] ^ fu.op[1]; // Xd <= Xn ^ Xm
      end else if (fu.inst[31:23] == AND3123) begin
        // AND
        // use decoded wmask
        fu.fu_out_data[0] <= fu.op[0] & dec_wmask;
      end else if (fu.inst[31:21] == ANDS3121 && fu.inst[15:10] == ANDS1510) begin
        // ANDS, TST
        fu.fu_out_data[0] <= ANDint; // Xd <= Xn & Xm
        // set condition flgas
        fu.fu_out_data[2] <= {
          {60{1'b0}},
          ANDint[63], // N
          ~(|(ANDint)), // Z
          1'b0, // C
          1'b0 // V
        };
      end else if (fu.inst[31:23] == SBFM3123) begin
        // SBFM, ASR
        $display("BFM Instruction:\n");
        $display("  imm6r: %0d\n", imm6r);
        $display("  imm6s: %0d\n", imm6s);
        $display("  bitfield_size: %0d\n", bitfield_size);
        $display("  bitfield_pos: %0d\n", bitfield_pos);
        $display("  bitfield_mask: 0x%016x\n", bitfield_mask);
        $display("  bitfield: 0x%016x\n", bitfield);
        $display("  sign_bit: %0b\n", sign_bit);
        $display("  sign_extended_bitfield: 0x%016x\n", sign_extended_bitfield);
        fu.fu_out_data[0] <= BFMout;
      end else if (fu.inst[31:23] == UBFM3123) begin
        // UBFM, LSL, LSR
        $display("BFM Instruction:\n");
        $display("  imm6r: %0d\n", imm6r);
        $display("  imm6s: %0d\n", imm6s);
        $display("  bitfield_size: %0d\n", bitfield_size);
        $display("  bitfield_pos: %0d\n", bitfield_pos);
        $display("  bitfield_mask: 0x%016x\n", bitfield_mask);
        $display("  bitfield: 0x%016x\n", bitfield);
        $display("  sign_bit: %0b\n", sign_bit);
        $display("  sign_extended_bitfield: 0x%016x\n", sign_extended_bitfield);
        fu.fu_out_data[0] <= BFMout;
      end

      // everything does the same stuff below here
      fu.fu_out_prn <= fu.out_prn;
      // ANDS will set flags so set fu_out_data_valid[2] to 1 in that case
      fu.fu_out_data_valid <= {1, 0, 1'(fu.inst[31:21] == ANDS3121 && fu.inst[15:10] == ANDS1510)};
      fu.fu_out_valid <= fu.inst_valid;
      fu.fu_out_inst_id <= fu.inst_id;
      fu.fu_out_valid <= 1;
    end
  end

endmodule
