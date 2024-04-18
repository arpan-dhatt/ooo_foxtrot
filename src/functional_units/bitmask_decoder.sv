// bitmask decoder for AND immediate

module bitmask_decoder #(
    parameter int M = 64
)(
    input  logic       immN,
    input  logic [5:0] imms,
    input  logic [5:0] immr,
    input  logic       immediate,
    output logic [M-1:0] wmask,
    output logic [M-1:0] tmask
);

    logic [5:0] tmask_and, wmask_and;
    logic [5:0] tmask_or, wmask_or;
    logic [5:0] levels;
    logic [7:0] len;
    logic [5:0] s, r;
    logic [6:0] diff;

    always_latch begin
        // Compute log2 of element size
        // 2^len must be in range [2, M]
        len = 8'(1 << $clog2({immN, ~imms}));
        if (len < 8'd1) begin
            wmask = 'x;
            tmask = 'x;
        end else begin
            assert (M >= (1 << len));

            // Determine s, r and s - r parameters
            levels = (1 << len) - 1;

            // For logical immediates an all-ones value of s is reserved
            // since it would generate a useless all-ones result (many times)
            if (immediate && ((imms & levels) == levels)) begin
                wmask = 'x;
                tmask = 'x;
            end else begin
                s = imms & levels;
                r = immr & levels;
                diff = s - r; // 6-bit subtract with borrow

                // Compute "top mask"
                tmask_and = diff[5:0] | ~levels;
                tmask_or  = diff[5:0] & levels;

                tmask = {M{1'b1}};
                tmask = ((tmask 
                        & {32{tmask_and[0], 1'b1}}) 
                        | {32{1'b0, tmask_or[0]}});
                tmask = ((tmask 
                        & {16{{2{tmask_and[1]}}, {2{1'b1}}}}) 
                        | {16{{2{1'b0}}, {2{tmask_or[1]}}}});
                tmask = ((tmask 
                        & {8{{4{tmask_and[2]}}, {4{1'b1}}}}) 
                        | {8{{4{1'b0}}, {4{tmask_or[2]}}}});
                tmask = ((tmask 
                        & {4{{8{tmask_and[3]}}, {8{1'b1}}}}) 
                        | {4{{8{1'b0}}, {8{tmask_or[3]}}}});
                tmask = ((tmask 
                        & {2{{16{tmask_and[4]}}, {16{1'b1}}}}) 
                        | {2{{16{1'b0}}, {16{tmask_or[4]}}}});
                tmask = ((tmask 
                        & {1{{32{tmask_and[5]}}, {32{1'b1}}}}) 
                        | {1{{32{1'b0}}, {32{tmask_or[5]}}}});

                // Compute "wraparound mask"
                wmask_and = immr | ~levels;
                wmask_or  = immr & levels;

                wmask = {M{1'b0}};
                wmask = ((wmask 
                        & {32{{1{1'b1}}, {1{wmask_and[0]}}}}) 
                        | {32{{1{wmask_or[0]}}, {1{1'b0}}}});
                wmask = ((wmask 
                        & {16{{2{1'b1}}, {2{wmask_and[1]}}}}) 
                        | {16{{2{wmask_or[1]}}, {2{1'b0}}}});
                wmask = ((wmask 
                        & {8{{4{1'b1}}, {4{wmask_and[2]}}}}) 
                        | {8{{4{wmask_or[2]}}, {4{1'b0}}}});
                wmask = ((wmask 
                        & {4{{8{1'b1}}, {8{wmask_and[3]}}}}) 
                        | {4{{8{wmask_or[3]}}, {8{1'b0}}}});
                wmask = ((wmask 
                        & {2{{16{1'b1}}, {16{wmask_and[4]}}}}) 
                        | {2{{16{wmask_or[4]}}, {16{1'b0}}}});
                wmask = ((wmask 
                        & {1{{32{1'b1}}, {32{wmask_and[5]}}}}) 
                        | {1{{32{wmask_or[5]}}, {32{1'b0}}}});

                if (diff[6]) // borrow from s - r
                    wmask = wmask & tmask;
                else
                    wmask = wmask | tmask;

                wmask = wmask[M-1:0];
                tmask = tmask[M-1:0];
            end
        end
    end

endmodule
