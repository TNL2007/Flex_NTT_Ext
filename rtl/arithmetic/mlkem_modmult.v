module mlkem_modmult #(
    parameter WIDTH = 12,
    parameter Q     = 3329
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] result,
    output reg              fault_mult
);

// ----------------------------------------------------------------------------
// 2-Cycle Pipelined Modular Multiplier for ML-KEM (Q = 3329)
//   Stage 1: Dedicated DSP48 multiplier (prod_reg <= a * b)
//   Stage 2: Fast LUT Barrett reduction (rem_val < 2*Q -> conditional sub)
//   Integrated: Low-Cost Modulo-7 Arithmetic Residue Checker (Layer 1 Defense)
// ----------------------------------------------------------------------------

localparam [15:0] BARRETT_V = 16'd20158;

// Stage 1 Register: DSP48 inferred with output register
(* use_dsp = "yes" *) reg [2*WIDTH-1:0] prod_reg;

// Modulo-7 Residue Prediction for Input Operands:
// 2^3 = 8 = 1 mod 7 -> a mod 7 = (a[2:0] + a[5:3] + a[8:6] + a[11:9]) mod 7
wire [4:0] a_sum3 = a[2:0] + a[5:3] + a[8:6] + a[11:9];
wire [4:0] b_sum3 = b[2:0] + b[5:3] + b[8:6] + b[11:9];
wire [2:0] a_res7 = a_sum3 % 7;
wire [2:0] b_res7 = b_sum3 % 7;
wire [2:0] expected_res7 = (a_res7 * b_res7) % 7;
reg  [2:0] expected_res7_q;

always @(posedge clk) begin
    if (!rst_n) begin
        prod_reg           <= {(2*WIDTH){1'b0}};
        expected_res7_q    <= 3'd0;
    end else begin
        prod_reg           <= a * b;
        expected_res7_q    <= expected_res7;
    end
end

// Stage 2 Barrett reduction in LUT logic:
// q_approx = (prod_reg * 20158) >> 26 (max quotient is 3326 -> 12 bits)
(* use_dsp = "no" *) wire [11:0] q_approx = (prod_reg * 38'd20158) >> 26;

// Low 13 bits of q_approx * 3329: 3329 = 4096 - 768 + 1
// (q_approx << 12) - (q_approx << 9) - (q_approx << 8) + q_approx
(* use_dsp = "no" *) wire [12:0] q_times_q = ({q_approx[0], 12'd0})
                                           - ({q_approx[3:0], 9'd0})
                                           - ({q_approx[4:0], 8'd0})
                                           + ({1'b0, q_approx});

// Remainder: prod_reg - q_times_q in range [0, 6657]
(* use_dsp = "no" *) wire [12:0] rem_val = prod_reg[12:0] - q_times_q;

// Final reduction into [0, Q-1]
(* use_dsp = "no" *) wire [12:0] rem_sub = rem_val - {1'b0, Q[WIDTH-1:0]};

// Modulo-7 Residue Evaluation of prod_reg:
wire [5:0] prod_sum3 = prod_reg[2:0]   + prod_reg[5:3]   + prod_reg[8:6]   + prod_reg[11:9]
                     + prod_reg[14:12] + prod_reg[17:15] + prod_reg[20:18] + prod_reg[23:21];
wire [2:0] actual_prod_res7 = prod_sum3 % 7;

always @(posedge clk) begin
    if (!rst_n) begin
        result     <= {WIDTH{1'b0}};
        fault_mult <= 1'b0;
    end else begin
        if (rem_val >= {1'b0, Q[WIDTH-1:0]})
            result <= rem_sub[WIDTH-1:0];
        else
            result <= rem_val[WIDTH-1:0];
            
        // Check residue consistency on every multiplier pipeline retirement
        if (prod_reg != 24'd0 && actual_prod_res7 != expected_res7_q)
            fault_mult <= 1'b1;
        else
            fault_mult <= 1'b0;
    end
end

endmodule