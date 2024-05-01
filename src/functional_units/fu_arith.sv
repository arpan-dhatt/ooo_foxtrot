

module fu_arith (
    fu_if.fu fu
);

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
  localparam [4:0] CMP_04_00 = 5'b11111;


  logic [63:0] a, b, s;
  logic n, z, c, v;
  logic setcond, setrd;
  always_comb begin // TODO for power efficiency, add a check for inst_valid
    a = fu.op[0];
    if(fu.inst[31:22] == ADD_31_22) begin // ADD
      b = {{52{1'b0}}, fu.inst[21:10]}; //imm12 + Xn
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31:21] == ADDS_31_21 && fu.inst[15:10] == ADDS_15_10) begin // ADDS
      b = fu.op[1]; // Xn + Xm
      setcond = 1'b1;
      setrd = 1'b1;
    end else if (fu.inst[31:22] == SUB_31_22) begin // SUB
      b = ~{{52{1'b0}}, fu.inst[21:10]} + 1;
      setcond = 1'b0;
      setrd = 1'b1;
    end else if (fu.inst[31:21] == SUBS_31_21 && fu.inst[15:10] == SUBS_15_10) begin // SUBS, CMP
      b = ~fu.op[1] + 1; // Xn - Xm = Xn + (~XM + 1)
      setcond = 1'b1;
      setrd = 1'(fu.inst[4:0] != CMP_04_00);
    end else begin
      // Invalid instruction, shouldn't happen but make verilator happy
      {b, setcond, setrd} = '0;
    end
    {c, s} = a + b;
    n = s[63];
    z = ~(|s);
    v = a[63]^b[63]^s[63]^c;
  end

  always_ff @(posedge fu.clk)
  begin
    if (fu.rst) begin
      fu.fu_out_valid <= 0;
      fu.fu_ready <= 1;
    end else if (fu.inst_valid) begin
      fu.fu_out_data[0] <= s;
      fu.fu_out_data[2] <= {{60{1'b0}}, n, z, c, v};

      fu.fu_out_prn <= fu.out_prn;
      fu.fu_out_data_valid <= fu.out_prn_valid;
      fu.fu_out_prn_valid <= fu.out_prn_valid;

      // Output 0 will not be valid on a cmp
      fu.fu_out_data_valid[0] <= setrd;
      fu.fu_out_data_valid[1] <= 1'b0;
      fu.fu_out_data_valid[2] <= setcond;

      fu.fu_out_valid <= fu.inst_valid;
      fu.fu_out_inst_id <= fu.inst_id;
      fu.fu_out_valid <= 1;
    end else begin
      fu.fu_out_valid <= 0;
    end
  end

endmodule
