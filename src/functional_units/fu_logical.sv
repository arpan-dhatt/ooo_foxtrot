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
  localparam [10:0] ANDS1510 = 11'b00000000000;

  // SBFM, ASR
  localparam [8:0] SBFM3123 = 9'b100100110;

  // UBFM, LSL, LSR
  localparam [8:0] UBFM3123 = 9'b110100110;

  always_ff @(posedge fu.clk)
  begin
    if (fu.rst) begin
      // set outputs invalid and ready to 1
      fu.fu_out_valid <= 0;
      fu.fu_ready <= 1;
    end
    else if (fu.inst[31:21] == CSEL3121 && fu.inst[11:10] == CSEL1110) begin
      // CSEL
      if (fu.inst[15:12] == fu.op[2][3:0]) begin
        // copy from Xn
        fu.fu_out_data[0] <= fu.op[0];
      end else begin
        // copy from Xm
        fu.fu_out_data[0] <= fu.op[1];
      end
      // Xd is in out_prn 0
      fu.fu_out_prn[0] <= fu.out_prn[0];
      fu.fu_out_data_valid <= {1, 0 ,0};
      fu.fu_out_valid <= fu.inst_valid;
      fu.fu_out_inst_id <= fu.inst_id;
      fu.fu_out_valid <= 1;
    end
  end

endmodule
