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
  localparam [9:0] AND3122 = 10'b1001001000;

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

  // SBFM UBFM calculation
  always_comb
  begin
    
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
      end else if (fu.inst[31:22] == AND3122) begin
        // AND
        // use decoded wmask
        fu.fu_out_data[0] <= fu.op[0] & dec_wmask;
      end else if (fu.inst[31:21] == ANDS3121 && fu.inst[15:10] == ANDS1510) begin
        // ANDS, TST
        fu.fu_out_data[0] <= fu.op[0] & fu.op[1]; // Xd <= Xn & Xm
      end else if (fu.inst[31:23] == SBFM3123) begin
        // SBFM, ASR
        if (fu.inst[15:10] >= fu.inst[21:16]) begin
          fu.fu_out_data[0] <= ({64{fu.op[0][fu.inst[21:16]]}} << (64 - (fu.inst[15:10] - fu.inst[21:16] + 1))) | (fu.op[0] >> fu.inst[21:16]);
        end else begin
          fu.fu_out_data[0] <= ({64{fu.op[0][fu.inst[15:10]]}} << (64 - fu.inst[21:16])) | (fu.op[0] << (64 - fu.inst[15:10] - 1));
        end
      end else if (fu.inst[31:23] == UBFM3123) begin
        // UBFM, LSL, LSR
        if (fu.inst[15:10] >= fu.inst[21:16]) begin
          fu.fu_out_data[0] <= (fu.op[0] >> fu.inst[21:16]) & ((1 << (fu.inst[15:10] - fu.inst[21:16] + 1)) - 1);
        end else begin
          fu.fu_out_data[0] <= (fu.op[0] << (64 - fu.inst[21:16])) & ((1 << (fu.inst[15:10] + 1)) - 1);
        end
      end
      

      // everything does the same stuff below here
      fu.fu_out_prn[0] <= fu.out_prn[0];
      fu.fu_out_data_valid <= {1, 0 ,0};
      fu.fu_out_valid <= fu.inst_valid;
      fu.fu_out_inst_id <= fu.inst_id;
      fu.fu_out_valid <= 1;
    end
  end

endmodule
